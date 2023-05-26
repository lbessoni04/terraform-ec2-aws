terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_default_vpc" "default_vpc" {
    tags = {
        Name = "default vpc"
    }
}

resource "aws_security_group" "ec2_security_group" {
    name = "ec2 security group"
    description = "allow access to ports 22 and 80"
    vpc_id = aws_default_vpc.default_vpc.id

    ingress {
        description     = "http access"
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    ingress {
        description     = "ssh access"
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["190.105.162.223/32"]
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = -1
        cidr_blocks     = ["0.0.0.0/0"]
    }

    tags = {
        Name = "ec2 security group"
    }
}

resource "aws_instance" "app_server" {
  ami           = "ami-0715c1897453cabd1"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  key_name = "ec2_keypair"
  user_data = file("install_website.sh")


  tags = {
    Name = "ExampleAppServerInstance"
  }
}

output "public_ipv4_address" {
    value = aws_instance.app_server.public_ip
}