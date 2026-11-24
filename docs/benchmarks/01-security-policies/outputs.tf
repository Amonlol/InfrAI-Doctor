output "listener_instance_id" {
  value = "floci-aws-ec2-${aws_instance.listener_server.id}"
}

output "attacker_instance_id" {
  value = "floci-aws-ec2-${aws_instance.attacker_server.id}"
}

output "listener_sg_id" {
  value = "floci-aws-sg-${aws_instance.listener_server.id}"
}

output "attacker_sg_id" {
  value = "floci-aws-sg-${aws_instance.attacker_server.id}"
}

output "db_instance_id" {
  value = "floci-aws-rds-${aws_db_instance.db_pg.id}"
}

output "listener_ip" {
  value = aws_instance.listener_server.private_ip
}

output "listener_port" {
  value = var.listen_port
}

output "db_instance_ip" {
  value = split(":", aws_db_instance.db_pg.endpoint)[0]
}

output "db_instance_port" {
  value = split(":", aws_db_instance.db_pg.endpoint)[1]
}
