

# Create EC2 instance for hosting Bitwarden

resource "aws_instance" "ec2_bitwarden" {
  ami                         = var.ami_id
  instance_type               = var.ec2_instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public-subnet-1.id
  vpc_security_group_ids      = [aws_security_group.bitwarden-security-group.id]
  key_name                    = aws_key_pair.bitwarden-ssh.key_name

  tags = {
    Name = "Bitwarden"
    createdby = "oye"
  }
  user_data = file("userdata.sh")
}

# Create EBS volume for storing all Bitwarden data.  Using 50GB to allow for enough storage.

resource "aws_ebs_volume" "ebs_bitwarden" {
  availability_zone = var.aws_availability_zone
  size              = 20
  encrypted         = true
  tags = {
    Name = "Bitwarden EBS Volume"
  }
}

# Attach EBS volume to EC2 instance

resource "aws_volume_attachment" "bitwarden_disk" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.ebs_bitwarden.id
  instance_id = aws_instance.ec2_bitwarden.id
}

# Add SSH Public Key for CLI Access

resource "aws_key_pair" "bitwarden-ssh" {
  key_name   = "bitwarden-public-ssh"
  public_key = file(var.ssh_key_file)
}

