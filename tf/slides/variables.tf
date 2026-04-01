variable "aws_region" {
  type        = string
  description = "AWS region (e.g. ap-south-1 for Mumbai)"
  default     = "ap-south-1"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Local path to your SSH private key (for ssh command only; not uploaded to AWS)"
  default     = "~/.ssh/ashupednekar"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Public key path; must exist (create with: ssh-keygen -y -f ~/.ssh/ashupednekar > ~/.ssh/ashupednekar.pub)"
  default     = "~/.ssh/ashupednekar.pub"
}

variable "instance_type" {
  type        = string
  description = "2 vCPU, 4 GiB (t3.medium)"
  default     = "t3.medium"
}

variable "project_name" {
  type    = string
  default = "slides"
}

variable "ssh_user" {
  type        = string
  description = "Default login user for the AMI (Ubuntu: ubuntu)"
  default     = "ubuntu"
}
