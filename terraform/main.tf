# ----------------------------------------------------
# 1. Configuração do Terraform (Provedores)
# ----------------------------------------------------
terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

# ----------------------------------------------------
# 2. Provedor OCI (Autenticação)
# ----------------------------------------------------
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# ----------------------------------------------------
# 3. Data Sources: AD & Imagem Oracle Linux
# ----------------------------------------------------

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# 🔧 Correção: pega QUALQUER Oracle Linux Gen2 mais recente
data "oci_core_images" "oracle_linux" {
  compartment_id = var.compartment_ocid

  filter {
    name   = "display_name"
    values = ["Oracle-Linux-*-Gen2"]
    regex  = true
  }

  sort_by    = "TIMECREATED"
  sort_order = "DESC"
}

# ----------------------------------------------------
# 4. Cloud-Init
# ----------------------------------------------------
data "template_file" "cloud_init" {
  template = file("cloud-init.yaml")
}

# ----------------------------------------------------
# 5. Criação da Instância (VM)
# ----------------------------------------------------
resource "oci_core_instance" "ci_cd_server" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name

  compartment_id = var.compartment_ocid
  display_name   = "ci-cd-server-iac"
  shape          = "VM.Standard.E3.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 4
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.oracle_linux.images[0].id
  }

  create_vnic_details {
    subnet_id        = var.subnet_ocid
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
    user_data           = base64encode(data.template_file.cloud_init.rendered)
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

# ----------------------------------------------------
# 6. Network Outputs (IP público)
# ----------------------------------------------------
data "oci_core_vnic_attachments" "vnic_attachments" {
  compartment_id = var.compartment_ocid
  instance_id    = oci_core_instance.ci_cd_server.id
}

data "oci_core_vnic" "vnic" {
  vnic_id = data.oci_core_vnic_attachments.vnic_attachments.vnic_attachments[0].vnic_id
}

output "server_public_ip" {
  description = "IP Público do servidor provisionado na OCI."
  value       = data.oci_core_vnic.vnic.public_ip_address
}
