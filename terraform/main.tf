# ----------------------------------------------------
# 1. Configuração do Backend Remoto (OCI Object Storage)
#    Armazena o estado da infraestrutura (terraform.tfstate)
# ----------------------------------------------------
terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }

  # Seu backend OCI Object Storage
  backend "oci" {
    bucket_name = "terraform-state-querizallan" # Nome do Bucket que você criou
    namespace   = "gr2km3pgjkez"                 # SEU NAMESPACE
    region      = "sa-saopaulo-1"                # Sua Região
    key         = "meu-app-prod/terraform.tfstate"
  }
}

# ----------------------------------------------------
# 2. Definição do Provedor OCI (Autenticação de API)
# ----------------------------------------------------
provider "oci" {
  # Variáveis de autenticação injetadas via Secrets do GitHub Actions
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = "oci_api_key.pem" # Arquivo criado no runner do GitHub
  region           = var.region
}

# ----------------------------------------------------
# 3. Data Source: Encontrar a Imagem Ubuntu (Base da VM)
# ----------------------------------------------------
# Busca a imagem do Ubuntu 22.04 mais recente disponível no seu compartimento
data "oci_core_images" "ubuntu_image" {
  compartment_id = var.compartment_ocid # OCID do Compartimento (Seu Tenancy OCID)
  operating_system = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape          = "VM.Standard.E3.Flex" # Formato da máquina

  filter {
    name = "display_name"
    values = ["^.*-22.04-.*-v[0-9]{4}.*$"] 
    regex = true
  }
}

# ----------------------------------------------------
# 4. Cloud-Init Script (Bootstrap)
# ----------------------------------------------------
# Carrega o script 'cloud-init.yaml' (instala Docker/Git)
data "template_file" "cloud_init" {
  template = file("cloud-init.yaml")
}

# ----------------------------------------------------
# 5. Recurso: OCI Compute Instance (VM de Produção)
# ----------------------------------------------------
resource "oci_core_instance" "ci_cd_server" {
  # O seu Compartment OCID (que é o seu Tenancy OCID, conforme coletado)
  compartment_id = var.compartment_ocid 
  display_name   = "ci-cd-server-iac"
  shape          = "VM.Standard.E3.Flex"
  
  source_details {
    source_type = "image"
    source_id   = sort(data.oci_core_images.ubuntu_image.images.*.id)[0]
  }

  # Configuração da Placa de Rede (VNIC)
  create_vnic_details {
    # Seu OCI_SUBNET_OCID (ocid1.subnet.oc1.sa-saopaulo-1.aaaaaaaap3d7fqhjnjymfndu4zrnpexjw77djg33wiywp76jsm7jrycu32oq)
    subnet_id        = var.subnet_ocid 
    assign_public_ip = true # Essencial para acesso SSH e deploy
  }

  # Injeção da Chave SSH Pública para o usuário 'ubuntu' (metadata)
  # O conteúdo da chave pública será passado via Secret SSH_PUBLIC_KEY
  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys 
    user_data           = base64encode(data.template_file.cloud_init.rendered)
  }
}