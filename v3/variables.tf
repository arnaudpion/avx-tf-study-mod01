variable "aws_region" {
  description = "AWS Region used for the AWS Provider"
  type        = string
  default     = "eu-central-1"
}

variable "vpc_count" {
  description = "Number of VPC to deploy, between 0 and 255"
  type        = number
  default     = 2
}

# Define the VPC peerings
locals {
  # Create all peerings based on list of all VPCs
  peerings = flatten([
    for vpc in aws_vpc.vpc : [
      #The slice below creates a new list with the remaining vpc excluding itself. E.g. based on resource aws_vpc.vpc = ["vpc1","vpc2","vpc3","vpc4","vpc5","vpc6"] and we arrive at vpc = "vpc3" in the for loop for example, the sliced list will result in: ["vpc4","vpc5","vpc6"]
      for peer_vpc in slice(aws_vpc.vpc, index(aws_vpc.vpc, vpc) + 1, length(aws_vpc.vpc)) : {
        vpc1_id          = vpc.id
        vpc2_id          = peer_vpc.id
        vpc_peering_name = "${vpc.tags["Name"]}-${peer_vpc.tags["Name"]}"
      }
    ]
  ])

  # Create map for consumption in peerings 'for_each'
  peerings_map = {
    for peering in local.peerings : "${peering.vpc1_id}:${peering.vpc2_id}" => peering
  }

  # Identify the IP address allowed to connect to instances
  my_ip_address = "${chomp(data.http.icanhazip.body)}/32"
}
