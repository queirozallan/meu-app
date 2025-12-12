# ----------------------------------------------------
# 1. Configuração do Terraform (Provedores)
# ----------------------------------------------------
terraform {
  # O bloco 'backend "oci" {}' FOI REMOVIDO (Configurado via CLI no cicd.yml).
  
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
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path 
  region           = var.region
}

# ----------------------------------------------------
# 3. Data Source: Encontrar o Availability Domain e a Imagem
# ----------------------------------------------------

# Data Source para pegar o primeiro Availability Domain disponível (Requisito OCI)
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_images" "ubuntu_image" {
  # Revertendo para o compartimento de trabalho, pois o filtro de Tenancy falhou.
  compartment_id           = var.compartment_ocid 
  
  operating_system         = "Canonical Ubuntu"
  
  # Filtro Essencial: Garante que estamos buscando imagens da Oracle (PLATFORM)
  filter {
    name = "image_source_type"
    values = ["PLATFORM"]
  }
  
  # Filtro para garantir que pegamos a mais nova
  sort_by    = "TIMECREATED"
  sort_order = "DESC"

  filter {
    name  = "lifecycle_state"
    values = ["AVAILABLE"]
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
  # CORREÇÃO: Adiciona o Availability Domain (Requisito OCI)
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  
  compartment_id = var.compartment_ocid
  display_name   = "ci-cd-server-iac"
  shape          = "VM.Standard.E3.Flex" # <-- O shape é aplicado AQUI, no recurso.
  
  source_details {
    source_type = "image"
    # source_id agora acessa o primeiro elemento da lista que deve ser populada.
    source_id   = data.oci_core_images.ubuntu_image.images[0].id 
  }

  create_vnic_details {
    subnet_id        = var.subnet_ocid
    assign_public_ip = true 
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
    user_data           = base64encode(data.template_file.cloud_init.rendered)
  }

  # CORREÇÃO: Adiciona timeouts para evitar o travamento por limite de tempo
  timeouts {
    create = "30m" 
    update = "30m"
    delete = "30m"
  }
}