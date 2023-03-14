output "public_ip" {
  value = aws_instance.ec2_bitwarden.public_ip
}

output "private_ip" {
  value = aws_instance.ec2_bitwarden.private_ip
}