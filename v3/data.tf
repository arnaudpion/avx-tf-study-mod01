data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "aws-linux2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "http" "icanhazip" {
  url = "http://ipv4.icanhazip.com"
}
