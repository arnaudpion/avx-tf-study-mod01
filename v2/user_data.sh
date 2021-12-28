#! /bin/bash
yum update -y
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && sudo yum install -y iperf
yum install -y iperf3
yum install -y httpd.x86_64
systemctl start httpd.service
systemctl enable httpd.service
echo “AVIATRIX ROCKS ! Hello from $(hostname -f)” > /var/www/html/index.html