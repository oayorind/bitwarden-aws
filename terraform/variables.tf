

variable "aws_region" {
  default     = "us-west-2"
  description = "AWS Region to Deploy to"
  type        = string
}

variable "aws_availability_zone" {
  default     = "us-west-2a"
  description = "AWS AZ to Deploy to"
  type        = string
}

variable "aws_profile_name" {
  default     = "default"
  description = "AWS profile to use"
  type        = string
}

variable "vpc-cidr" {
  default     = "10.0.0.0/16"
  description = "VPC CIDR Block"
  type        = string
}

variable "Public_Subnet_1" {
  default     = "10.0.1.0/24"
  description = "Public_Subnet_1"
  type        = string
}
variable "Private_Subnet_1" {
  default     = "10.0.2.0/24"
  description = "Private_Subnet_1"
  type        = string
}

variable "ssh_location" {
  default     = ["0.0.0.0/0"]
  description = "Use to restrict IP for SSH access"
  type        = list(any)
}

variable "ami_id" {
  # Using Debian 11 x64 by default  
  default     = "ami-050406429a71aaa64"
  description = "AMI ID of image to deploy"
  type        = string
}

variable "ec2_instance_type" {
  # Using t3.medium as default based on Bitwarden recommended requirements:  https://bitwarden.com/help/install-on-premise-linux/
  default     = "t3.medium"
  description = "EC2 Instance Type"
  type        = string
}

variable "ssh_key_file" {
  default     = "../id_rsa.pub"
  description = "Location of SSH public key to add to EC2 instance"
  type        = string
}
