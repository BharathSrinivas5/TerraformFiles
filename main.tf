provider "aws"{
  region = "ap-south-1"
}



resource "aws_vpc" "bb-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "bb-vpc"
  }
}

resource "aws_internet_gateway" "bb-igw" {
  vpc_id = aws_vpc.bb-vpc.id

  tags = {
    Name = "bb-igw"
  }
}

resource "aws_subnet" "bb-pub-sn" {
  vpc_id     = aws_vpc.bb-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "bb-pub-sn"
  }
}

resource "aws_subnet" "bb-prv-sn" {
  vpc_id     = aws_vpc.bb-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "bb-prv-sn"
  }
}

resource "aws_route_table" "bb-rtb" {
    vpc_id = aws_vpc.bb-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.bb-igw.id
    }
    tags = {
        Name = "bb-rtb"
    }
}

resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id      = aws_subnet.bb-pub-sn.id
  route_table_id = aws_route_table.bb-rtb.id
}


resource "aws_security_group" "bb-sg" {
  name   = "bb-sg"
  vpc_id = aws_vpc.bb-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "bb-sg"
  }
}

data "aws_ami" "amazon-linux-image" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

output "ami_id" {
  value = data.aws_ami.amazon-linux-image.id
}

resource "aws_instance" "bb-app-server" {
  ami                         = data.aws_ami.amazon-linux-image.id
  instance_type               = "t2.micro"
  key_name                    = "newkeyprac"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.bb-pub-sn.id
  vpc_security_group_ids      = [aws_security_group.bb-sg.id]
  availability_zone			  = "us-east-2b"
  tags = {
    Name = "bb-app-server"
  }
 user_data = <<EOF
#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install nginx1 -y 
sudo systemctl enable nginx
sudo systemctl start nginx
              EOF
}
