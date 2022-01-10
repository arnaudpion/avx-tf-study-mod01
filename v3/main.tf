# Deploy VPCs
resource "aws_vpc" "vpc" {
  count      = var.vpc_count
  cidr_block = "10.${count.index + 1}.0.0/16"
  tags = {
    Name = "vpc${count.index + 1}"
  }
}


# Deploy 2 subnets in each VPC named <vpcname>-subnet1 and <vpcname>-subnet2
resource "aws_subnet" "vpc_subnet1" {
  count      = var.vpc_count
  vpc_id     = aws_vpc.vpc[count.index].id
  cidr_block = cidrsubnet(aws_vpc.vpc[count.index].cidr_block, 8, 0)
  tags = {
    Name = "${aws_vpc.vpc[count.index].tags["Name"]}-subnet1"
  }
}

resource "aws_subnet" "vpc_subnet2" {
  count      = var.vpc_count
  vpc_id     = aws_vpc.vpc[count.index].id
  cidr_block = cidrsubnet(aws_vpc.vpc[count.index].cidr_block, 8, 1)
  tags = {
    Name = "${aws_vpc.vpc[count.index].tags["Name"]}-subnet2"
  }
}


# Add Internet Gateway in each VPC to make subnets public and access EC2 instances
resource "aws_internet_gateway" "igw" {
  count  = var.vpc_count
  vpc_id = aws_vpc.vpc[count.index].id
  tags = {
    Name = "${aws_vpc.vpc[count.index].tags["Name"]}-igw"
  }
}


# Deploy a routing table in each VPC
resource "aws_route_table" "vpc_rt" {
  count  = var.vpc_count
  vpc_id = aws_vpc.vpc[count.index].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[count.index].id
  }

  tags = {
    Name = "${aws_vpc.vpc[count.index].tags["Name"]}-rt"
  }
}


# Attach (associate) the subnets to the created routing table
resource "aws_route_table_association" "subnet1_rt_asso" {
  count          = var.vpc_count
  subnet_id      = aws_subnet.vpc_subnet1[count.index].id
  route_table_id = aws_route_table.vpc_rt[count.index].id
}

resource "aws_route_table_association" "subnet2_rt_asso" {
  count          = var.vpc_count
  subnet_id      = aws_subnet.vpc_subnet2[count.index].id
  route_table_id = aws_route_table.vpc_rt[count.index].id
}


# Peer the VPC’s together
resource "aws_vpc_peering_connection" "vpc_to_vpc_peering" {
  for_each    = local.peerings_map
  peer_vpc_id = each.value.vpc2_id
  vpc_id      = each.value.vpc1_id
  auto_accept = true
  tags = {
    #Name = "VPC Peering between ${each.value.vpc1_id} and ${each.value.vpc2_id}"
    Name = "${each.value.vpc_peering_name}"
  }
}


# Security Groups for EC2 Instances in Spoke VPCs in AWS
resource "aws_security_group" "sg" {
  count       = var.vpc_count
  name        = "vpc${aws_vpc.vpc[count.index].tags["Name"]}-sg"
  description = "Allow SSH from My IP as well as traffic from Private IP addresses"
  vpc_id      = aws_vpc.vpc[count.index].id

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
    Name = "${aws_vpc.vpc[count.index].tags["Name"]}-sg"
  }
}


# Deploy AWS Linux 2 EC2 instance in each subnet
resource "aws_instance" "subnet1_ec2" {
  count                       = var.vpc_count
  ami                         = data.aws_ami.aws-linux2.id
  instance_type               = "t3.nano"
  key_name                    = "aviatrix-lab-aws"
  vpc_security_group_ids      = [aws_security_group.sg[count.index].id]
  subnet_id                   = aws_subnet.vpc_subnet1[count.index].id
  associate_public_ip_address = true
  private_ip                  = cidrhost(aws_subnet.vpc_subnet1[count.index].cidr_block, 5)
  user_data                   = file("user_data.sh")
  tags = {
    Name = "${aws_vpc.vpc[count.index].tags["Name"]}-subnet1-vm"
  }
}

resource "aws_instance" "subnet2_ec2" {
  count                       = var.vpc_count
  ami                         = data.aws_ami.aws-linux2.id
  instance_type               = "t3.nano"
  key_name                    = "aviatrix-lab-aws"
  vpc_security_group_ids      = [aws_security_group.sg[count.index].id]
  subnet_id                   = aws_subnet.vpc_subnet2[count.index].id
  associate_public_ip_address = true
  private_ip                  = cidrhost(aws_subnet.vpc_subnet2[count.index].cidr_block, 5)
  user_data                   = file("user_data.sh")
  tags = {
    Name = "${aws_vpc.vpc[count.index].tags["Name"]}-subnet2-vm"
  }
}
