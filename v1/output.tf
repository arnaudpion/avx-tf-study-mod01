output "subnet_list" {
  description = "List of subnets created"
  value       = [aws_subnet.vpc1_subnet1, aws_subnet.vpc1_subnet2, aws_subnet.vpc2_subnet1, aws_subnet.vpc2_subnet1]
}
