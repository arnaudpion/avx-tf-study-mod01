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
