output "instance_ip_consul_1" {
  value = aws_instance.consul[0].private_ip
}

output "instance_ip_consul_2" {
  value = aws_instance.consul[1].private_ip
}

output "instance_ip_consul_3" {
  value = aws_instance.consul[2].private_ip
}

output "instance_ip_vault" {
  value = aws_instance.vault[0].public_ip
}
