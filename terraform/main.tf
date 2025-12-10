terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }

  backend "oci" {
    bucket_name = "terraform-state-querizallan" # SEU Bucket
    namespace   = "gr2km3pgjkez"                 # SEU Namespace
    region      = "sa-saopaulo-1"
    key         = "meu-app-prod/terraform.tfstate"
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = "oci_api_key.pem" 
  region           = var.region
}

data "oci_core_images" "ubuntu_image" {
  compartment_id = var.compartment_ocid # Seu Compartimento/Root
  operating_system = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape          = "VM.Standard.E3.Flex"

  filter {
    name = "display_name"
    values = ["^.*-22.04-.*-v[0-9]{4}.*$"] 
    regex = true
  }
}

data "template_file" "cloud_init" {
  template = file("cloud-init.yaml")
}

resource "oci_core_instance" "ci_cd_server" {
  compartment_id = var.compartment_ocid
  display_name   = "ci-cd-server-iac"
  shape          = "VM.Standard.E3.Flex"
  
  source_details {
    source_type = "image"
    source_id   = sort(data.oci_core_images.ubuntu_image.images.*.id)[0]
  }

  create_vnic_details {
    subnet_id        = var.subnet_ocid # Sua Subnet Pública
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys # Sua Chave Pública SSH
    user_data           = base64encode(data.template_file.cloud_init.rendered)
  }
}