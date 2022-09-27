provider "aws"{
  region = "ap-south-1"
  access key = "access_key"
  secret key = "secret_key"
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



