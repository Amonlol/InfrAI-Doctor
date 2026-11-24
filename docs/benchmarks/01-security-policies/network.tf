resource "aws_vpc" "main_network" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "main_subnet" {
  vpc_id                  = aws_vpc.main_network.id
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"
}

resource "aws_security_group" "no_ingress_sg" {
  name        = "no-ingress"
  description = "Security group without ingress rules"
  vpc_id      = aws_vpc.main_network.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_all" {
  name        = "allow-all"
  description = "Security group without ingress rules"
  vpc_id      = aws_vpc.main_network.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "db_group" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.main_subnet.id]
}
