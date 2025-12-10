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