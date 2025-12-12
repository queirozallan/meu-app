# Variáveis de Configuração da Autenticação OCI (Secrets)
variable "tenancy_ocid" {
  description = "OCID da tenancy OCI."
  type        = string
}

variable "user_ocid" {
  description = "OCID do usuário que possui a chave de assinatura de API."
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint da chave de assinatura de API."
  type        = string
}

# 🚨 VARIÁVEL ADICIONADA: O caminho da chave privada (oci_api_key.pem)
variable "private_key_path" {
  description = "Caminho do arquivo da chave privada OCI (gerado no runner)."
  type        = string
}

# Variáveis de Localização e Recurso
variable "region" {
  description = "Região da OCI onde os recursos serão criados."
  type        = string
  default     = "sa-saopaulo-1" 
}

variable "compartment_ocid" {
  description = "OCID do Compartimento onde a VM e os recursos serão criados."
  type        = string
}

# Variável de Rede (Subnet existente)
variable "subnet_ocid" {
  description = "OCID de uma Subnet pública existente para anexar a VM."
  type        = string
}

# Variável para a Chave Pública SSH (injetada na VM)
variable "ssh_authorized_keys" {
  description = "Conteúdo da chave pública SSH para acesso à VM."
  type        = string
}