variable "aws_region" {
  description = "AWS Region used for the AWS Provider"
  type        = string
  default     = "eu-central-1"
}

locals {
  my_ip_address = "${chomp(data.http.icanhazip.body)}/32"
}
