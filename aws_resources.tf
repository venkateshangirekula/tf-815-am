resource "aws_vpc" "tf-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "tf-vpc"
  }
}
resource "aws_subnet" "tf-subnet" {
  vpc_id     = aws_vpc.tf-vpc.id
  cidr_block = "10.0.1.0/24"
availability_zone = "ap-south-1a"
map_public_ip_on_launch = "true"
  tags = {
    Name = "tf-subnet"
  }
}
resource "aws_internet_gateway" "tf-igw" {
  vpc_id = aws_vpc.tf-vpc.id

  tags = {
    Name = "tf-gateway"
  }
}
resource "aws_route_table" "tf-rtb" {
  vpc_id = aws_vpc.tf-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-igw.id
  }

  tags = {
    Name = "tf-route-table"
  }
}
resource "aws_route_table_association" "tf-rt-sn" {
  subnet_id      = aws_subnet.tf-subnet.id
  route_table_id = aws_route_table.tf-rtb.id
}
resource "aws_security_group" "tf-sg" {
  name        = "allow-tf"
  description = "Allow SSH - HTTP inbound traffic"
  vpc_id      = aws_vpc.tf-vpc.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

 ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf-sg"
  }
}
resource "aws_instance" "tf-ec2" {
  ami           = "ami-0a7cf821b91bcccbc"
  instance_type = "t2.medium"
  key_name = "test.newkp"
  subnet_id = aws_subnet.tf-subnet.id
  vpc_security_group_ids = [aws_security_group.tf-sg.id]
  user_data = file("ecomm.sh")

  tags = {
    Name = "ecomm-server"
  }
}
