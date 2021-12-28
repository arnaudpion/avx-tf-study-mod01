# Deploy 2 VPC’s named vpc1 and vpc2 
resource "aws_vpc" "vpc1" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "vpc1"
  }
}

resource "aws_vpc" "vpc2" {
  cidr_block = "10.2.0.0/16"
  tags = {
    Name = "vpc2"
  }
}

# Deploy a routing table in each VPC
resource "aws_route_table" "vpc1_rt" {
  vpc_id = aws_vpc.vpc1.id
  route {
    cidr_block                = "10.2.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc1_to_vpc2_peering.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc1_igw.id
  }
  tags = {
    Name = "${lookup(aws_vpc.vpc1.tags, "Name")}-rt"
  }
}

resource "aws_route_table" "vpc2_rt" {
  vpc_id = aws_vpc.vpc2.id
  route {
    cidr_block                = "10.1.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc1_to_vpc2_peering.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc2_igw.id
  }
  tags = {
    Name = "${lookup(aws_vpc.vpc2.tags, "Name")}-rt"
  }
}

# Deploy 2 subnets in each VPC named <vpcname>-subnet1 and <vpcname>-subnet2
resource "aws_subnet" "vpc1_subnet1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.1.1.0/24"
  tags = {
    Name = "${lookup(aws_vpc.vpc1.tags, "Name")}-subnet1"
  }
}

resource "aws_subnet" "vpc1_subnet2" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.1.2.0/24"
  tags = {
    Name = "${lookup(aws_vpc.vpc1.tags, "Name")}-subnet2"
  }
}

resource "aws_subnet" "vpc2_subnet1" {
  vpc_id     = aws_vpc.vpc2.id
  cidr_block = "10.2.1.0/24"
  tags = {
    Name = "${lookup(aws_vpc.vpc2.tags, "Name")}-subnet1"
  }
}

resource "aws_subnet" "vpc2_subnet2" {
  vpc_id     = aws_vpc.vpc2.id
  cidr_block = "10.2.2.0/24"
  tags = {
    Name = "${lookup(aws_vpc.vpc2.tags, "Name")}-subnet2"
  }
}

# Attach (associate) the subnets to the created routing table
resource "aws_route_table_association" "vpc1_subnet1_rt_asso" {
  subnet_id      = aws_subnet.vpc1_subnet1.id
  route_table_id = aws_route_table.vpc1_rt.id
}

resource "aws_route_table_association" "vpc1_subnet2_rt_asso" {
  subnet_id      = aws_subnet.vpc1_subnet2.id
  route_table_id = aws_route_table.vpc1_rt.id
}

resource "aws_route_table_association" "vpc2_subnet1_rt_asso" {
  subnet_id      = aws_subnet.vpc2_subnet1.id
  route_table_id = aws_route_table.vpc2_rt.id
}

resource "aws_route_table_association" "vpc2_subnet2_rt_asso" {
  subnet_id      = aws_subnet.vpc2_subnet2.id
  route_table_id = aws_route_table.vpc2_rt.id
}

# Peer the VPC’s together
resource "aws_vpc_peering_connection" "vpc1_to_vpc2_peering" {
  peer_vpc_id = aws_vpc.vpc2.id
  vpc_id      = aws_vpc.vpc1.id
  auto_accept = true
  tags = {
    Name = "VPC Peering between vpc1 and vpc2"
  }
}

# Add Internet Gateway in each VPC to make subnets public and access EC2 instances
resource "aws_internet_gateway" "vpc1_igw" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "${lookup(aws_vpc.vpc1.tags, "Name")}-igw"
  }
}

resource "aws_internet_gateway" "vpc2_igw" {
  vpc_id = aws_vpc.vpc2.id
  tags = {
    Name = "${lookup(aws_vpc.vpc2.tags, "Name")}-igw"
  }
}

# Security Groups for EC2 Instances in Spoke VPCs in AWS
resource "aws_security_group" "vpc1_sg" {
  name        = "vpc1-sg"
  description = "Allow SSH from My IP as well as traffic from Private IP addresses"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip_address]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["10.0.0.0/8"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "vpc1-sg"
  }
}

resource "aws_security_group" "vpc2_sg" {
  name        = "vpc2-sg"
  description = "Allow SSH from My IP as well as traffic from Private IP addresses"
  vpc_id      = aws_vpc.vpc2.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip_address]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["10.0.0.0/8"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "vpc2-sg"
  }
}

# Deploy AWS Linux 2 EC2 instance in each subnet
resource "aws_instance" "vpc1_subnet1_ec2" {
  ami                         = data.aws_ami.aws-linux2.id
  instance_type               = "t3.nano"
  key_name                    = "aviatrix-lab-aws"
  vpc_security_group_ids      = [aws_security_group.vpc1_sg.id]
  subnet_id                   = aws_subnet.vpc1_subnet1.id
  associate_public_ip_address = true
  private_ip                  = cidrhost(aws_subnet.vpc1_subnet1.cidr_block, 5)
  user_data                   = file("user_data.sh")
  tags = {
    Name = "vpc1-subnet1-vm"
  }
}

resource "aws_instance" "vpc1_subnet2_ec2" {
  ami                         = data.aws_ami.aws-linux2.id
  instance_type               = "t3.nano"
  key_name                    = "aviatrix-lab-aws"
  vpc_security_group_ids      = [aws_security_group.vpc1_sg.id]
  subnet_id                   = aws_subnet.vpc1_subnet2.id
  associate_public_ip_address = true
  private_ip                  = cidrhost(aws_subnet.vpc1_subnet2.cidr_block, 5)
  user_data                   = file("user_data.sh")
  tags = {
    Name = "vpc1-subnet2-vm"
  }
}

resource "aws_instance" "vpc2_subnet1_ec2" {
  ami                         = data.aws_ami.aws-linux2.id
  instance_type               = "t3.nano"
  key_name                    = "aviatrix-lab-aws"
  vpc_security_group_ids      = [aws_security_group.vpc2_sg.id]
  subnet_id                   = aws_subnet.vpc2_subnet1.id
  associate_public_ip_address = true
  private_ip                  = cidrhost(aws_subnet.vpc2_subnet1.cidr_block, 5)
  user_data                   = file("user_data.sh")
  tags = {
    Name = "vpc2-subnet1-vm"
  }
}

resource "aws_instance" "vpc2_subnet2_ec2" {
  ami                         = data.aws_ami.aws-linux2.id
  instance_type               = "t3.nano"
  key_name                    = "aviatrix-lab-aws"
  vpc_security_group_ids      = [aws_security_group.vpc2_sg.id]
  subnet_id                   = aws_subnet.vpc2_subnet2.id
  associate_public_ip_address = true
  private_ip                  = cidrhost(aws_subnet.vpc2_subnet2.cidr_block, 5)
  user_data                   = file("user_data.sh")
  tags = {
    Name = "vpc2-subnet2-vm"
  }
}
