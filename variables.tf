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

variable "consul_server1" {
  default = aws_instance.consul[0].public_ip
}

variable "consul_server2" {
  default = aws_instance.consul[1].public_ip
}

variable "consul_server3" {
  default = aws_instance.consul[2].public_ip
}

variable "vault_server" {
  default = aws_instance.vault[0].private_ip
}
