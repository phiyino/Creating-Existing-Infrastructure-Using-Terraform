# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}
# Create aws server using ec2 instance in private subnet az1
resource "aws_instance" "mysql-server-az1" {
  ami           = var.ami_az1_id
  instance_type = "t2.micro"
  key_name      = "terraform"

  subnet_id                   = var.private_subnet_az1_id 
  vpc_security_group_ids      = [var.database_security_group_id]
  associate_public_ip_address = false
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  user_data = <<-EOF
  #!/bin/bash
sudo amazon-linux-extras install epel -y
sudo yum install https://dev.mysql.com/get/mysql80-community-release-el7-5.noarch.rpm
sudo yum install mysql-community-server -y
systemctl enable mysqld 
systemctl start mysqld
cat /var/log/mysqld.log | grep "A temporary password" 
sudo mysql_secure_installation

EOF

tags = {

"Name" = "mysql-server-az1"

}

}

# Create aws server using ec2 instance in private subnet az2
resource "aws_instance" "mysql-server-az2" {
  ami           = var.ami_az2_id
  instance_type = "t2.micro"
  key_name      = "terraform"

  subnet_id                   = var.private_subnet_az2_id 
  vpc_security_group_ids      = [var.database_security_group_id]
  associate_public_ip_address = false
  availability_zone = data.aws_availability_zones.available_zones.names[1]

  user_data = <<-EOF
  #!/bin/bash
sudo amazon-linux-extras install epel -y
sudo yum install https://dev.mysql.com/get/mysql80-community-release-el7-5.noarch.rpm
sudo yum install mysql-community-server -y
systemctl enable mysqld 
systemctl start mysqld
cat /var/log/mysqld.log | grep "A temporary password" 
sudo mysql_secure_installation

EOF

tags = {

"Name" = "mysql-server-az2"

}

}