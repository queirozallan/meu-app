# ----------------------------------------------------
# 1. Configuração do Terraform (Provedores e Backend Remoto)
# ----------------------------------------------------
terraform {
  # Configuração do Backend Remoto (State na OCI Object Storage)
  backend "oci" {
    bucket      = "terraform-state-querizallan"  # Seu Bucket Name
    namespace   = "gr2km3pgjkez"                 # Seu Namespace do Object Storage
    region      = "sa-saopaulo-1"                # Sua Região
    key         = "terraform.tfstate"            # Nome do arquivo de estado dentro do bucket
  }
  
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }

}

# ----------------------------------------------------
# 2. Definição do Provedor OCI (Autenticação)
# ----------------------------------------------------
provider "oci" {
  # Variáveis de autenticação injetadas via Secrets do GitHub
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = "oci_api_key.pem" # Arquivo criado no runner
  region           = var.region
}

# ----------------------------------------------------
# 3. Data Source: Encontrar a Imagem Ubuntu
# ----------------------------------------------------
data "oci_core_images" "ubuntu_image" {
  compartment_id = var.compartment_ocid
  operating_system = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape          = "VM.Standard.E3.Flex"

  filter {
    name = "display_name"
    values = ["^.*-22.04-.*-v[0-9]{4}.*$"] 
    regex = true
  }
}

# ----------------------------------------------------
# 4. Data Source: Cloud-Init Script
# ----------------------------------------------------
data "template_file" "cloud_init" {
  template = file("cloud-init.yaml")
}

# ----------------------------------------------------
# 5. Recurso: OCI Compute Instance (VM de Produção)
# ----------------------------------------------------
resource "oci_core_instance" "ci_cd_server" {
  compartment_id = var.compartment_ocid
  display_name   = "ci-cd-server-iac"
  shape          = "VM.Standard.E3.Flex"
  
  source_details {
    source_type = "image"
    source_id   = sort(data.oci_core_images.ubuntu_image.images.*.id)[0]
  }

  create_vnic_details {
    subnet_id        = var.subnet_ocid
    assign_public_ip = true 
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
    user_data           = base64encode(data.template_file.cloud_init.rendered)
  }
}