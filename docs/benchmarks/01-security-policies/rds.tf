resource "aws_db_instance" "db_pg" {
  identifier             = "security-db"
  allocated_storage      = 4
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = "db.t3.micro"
  username               = "postgres"
  password               = "postgres"
  vpc_security_group_ids = [aws_security_group.no_ingress_sg.id]
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.db_group.name
}
