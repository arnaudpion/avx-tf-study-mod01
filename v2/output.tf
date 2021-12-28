output "ec2_info" {
  description = "Instances created with their public and private IP addresses"
  value = tomap({
    "${lookup(aws_instance.vpc1_subnet1_ec2.tags, "Name")}" = [aws_instance.vpc1_subnet1_ec2.public_ip, aws_instance.vpc1_subnet1_ec2.private_ip],
    "${lookup(aws_instance.vpc1_subnet2_ec2.tags, "Name")}" = [aws_instance.vpc1_subnet2_ec2.public_ip, aws_instance.vpc1_subnet2_ec2.private_ip],
    "${lookup(aws_instance.vpc2_subnet1_ec2.tags, "Name")}" = [aws_instance.vpc2_subnet1_ec2.public_ip, aws_instance.vpc2_subnet1_ec2.private_ip],
    "${lookup(aws_instance.vpc2_subnet2_ec2.tags, "Name")}" = [aws_instance.vpc2_subnet2_ec2.public_ip, aws_instance.vpc2_subnet2_ec2.private_ip],
  })
}
