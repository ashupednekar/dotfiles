output "public_ip" {
  value       = aws_instance.this.public_ip
  description = "Public IPv4; login user is ubuntu (Docker installed via cloud-init on first boot)"
}

output "private_ip" {
  value = aws_instance.this.private_ip
}

output "instance_id" {
  value = aws_instance.this.id
}

output "ssh_hint" {
  value = "ssh -i ${pathexpand(var.ssh_private_key_path)} ${var.ssh_user}@${aws_instance.this.public_ip}"
}
