variable "aws_region" {
  default = "us-east-1"
}

variable "aws_zone" {
  default = "us-east-1d"
}

variable "vault_url" {
  default = "https://releases.hashicorp.com/vault/1.8.1/vault_1.8.1_linux_amd64.zip"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR of the VPC"
  default     = "192.168.100.0/24"
}

variable "consul_url" {
  default = "https://releases.hashicorp.com/consul/1.12.0/consul_1.12.0_linux_amd64.zip"
}
