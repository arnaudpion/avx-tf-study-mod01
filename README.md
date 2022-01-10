# avx-tf-study-mod01
Aviatrix Terraform Study Group - Module 1

* Deploy 2 VPC’s named vpc1 and vpc2
* Deploy a routing table in each VPC
* Deploy 2 subnets in each VPC named <vpcname>-subnet1 and <vpcname>-subnet2
* Attach (associate) the subnets to the created routing table
* Peer the VPC’s together
 
All of this is AWS native. No Aviatrix involved yet.
 
Some hints can be found here:
* AWS Provider usage: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
* AWS VPC resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
* AWS Subnet resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
* AWS Route table resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
* AWS Route table association resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association

Versions details :
* v1: MVP
* v2: add EC2 instances in each subnet. Subnets are public, to allow for external access to instances as well as the download of packages
* v3: allows to define the number of VPCs to be deployed. Route tables are incomplete (no routes to other VPCs through peerings). Run terraform plan command with the '-target "aws_vpc.vpc"' and do a first apply before applying the whole configuration