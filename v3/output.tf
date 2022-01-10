output "ec2_info" {
  description = "Instances created with their public and private IP addresses (Subnet 1)"
  value = {
    for ec2 in concat(aws_instance.subnet1_ec2, aws_instance.subnet2_ec2) : "${ec2.tags["Name"]}" => [ec2.public_ip, ec2.private_ip]
    }
}
