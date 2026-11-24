variable "listen_port" {
  description = "The port the listener server will use for network traffic"
  type        = number
  default     = 8080
}

resource "aws_instance" "listener_server" {
  ami                    = "ami-12345678" # Floci EC2 placeholder
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.main_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  user_data              = <<-EOF
                            #!/bin/bash
                            yum update -y && yum install -y nc
                            nc -lk -p ${var.listen_port}
                            EOF
}

resource "aws_instance" "attacker_server" {
  ami                    = "ami-12345678" # Floci EC2 placeholder
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.main_subnet.id
  vpc_security_group_ids = [aws_security_group.no_ingress_sg.id]
  user_data              = <<-EOF
                            #!/bin/bash
                            yum update -y && yum install -y nc
                            EOF
}
