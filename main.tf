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
   
    region = "eu-central-1"
}
# data "aws_vpc" "default_vpc" {

#   default = true

# }
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  
  tags = {
    Name = "exam_vpc"
  }
}
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    Name = "exam_igw"
  }
}
resource "aws_subnet" "public_subnet" {
  count      = var.subnet_count.public
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_cidr_block

  tags = {
    Name = "public_subnet"
  }
}
resource "aws_subnet" "private_subnets" {
  count      = var.subnet_count.private
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_cidr_block[count.index]

  tags = {
    Name = "private_subnet${count.index}"
  }
}
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
}
resource "aws_route_table_association" "public" {
  count          = var.subnet_count.public
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id
}
resource "aws_route_table_association" "private" {
  count          = var.subnet_count.private
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.private_subnets[count.index].id
}
locals {
    ingress_rules = [
        {
            port        = 22
            description = "Port 22"
        },
        {
            port        = 80
            description = "Port 80"
        }
        ]
}
resource "aws_instance" "instance" {
    ami                    = var.ami-id
    instance_type          = var.instance_type
    key_name               = aws_key_pair.generated_key.key_name
    vpc_security_group_ids = [aws_security_group.security.id]
    iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
    user_data              = file("./bootstrap")
    subnet_id              = aws_subnet.public_subnet[0].id

    tags = {
      Name = "VM"
    }
}
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "VM-key"
  public_key = tls_private_key.example.public_key_openssh
}
resource "local_file" "private_key" {
    content  = tls_private_key.example.private_key_pem
    filename = "VM-key.pem"
}
resource "aws_security_group" "security" {
    name       = "VM-sg"
    vpc_id     = aws_vpc.vpc.id
    dynamic "ingress" {
        for_each = local.ingress_rules 

        content {
            description = ingress.value.description
            from_port   = ingress.value.port
            to_port     = ingress.value.port
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }
     egress {
     from_port        = 0
     to_port          = 0
     protocol         = "-1"
     cidr_blocks      = ["0.0.0.0/0"]
     ipv6_cidr_blocks = ["::/0"]
    }

    tags = {
        Name = "VM-sg"
    }
}
resource "aws_db_instance" "db-test" {
  allocated_storage      = 21
  db_name                = ""
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  username               = "DevOpsDB"
  password               = "DevOpsDB"
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.DB-sg.id]
  port                   = 3306
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_grp.id
}
resource "aws_security_group" "DB-sg" {
    name       = "rds-sg"
    vpc_id     = aws_vpc.vpc.id
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = [aws_security_group.security.id]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]

    }
    tags = {
        Name = "rds-sg"
    }
}
resource "aws_s3_bucket" "b" {
  bucket = var.s3_bucket
}
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.b.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
resource "aws_iam_role_policy_attachment" "attach-s3" {
  count      = 2
  role       = aws_iam_role.ec2-role.name
  policy_arn = count.index != 0 ? "arn:aws:iam::aws:policy/AmazonRDSFullAccess" : "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_role" "ec2-role" {
    name = "db-s3-access"
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}
resource "aws_iam_instance_profile" "ec2_profile" {
  name  = "ec2-s3-db-access"
  role  = aws_iam_role.ec2-role.name
}
resource "aws_ecr_repository" "ecr" {
  name                 = "danutblaj"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
resource "aws_db_subnet_group" "db_subnet_grp" {
  name = "db-subnet-group"
  subnet_ids = [for subnet in aws_subnet.private_subnets : subnet.id]
}
resource "aws_eip" "tutorial_web_eip" {
  instance = aws_instance.instance.id
  vpc      = true

  tags = {
    Name = "instance-eip"
  }
}
