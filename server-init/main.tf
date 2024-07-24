terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.59.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "php_app" {
  ami           = "ami-071878317c449ae48"
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = element(var.subnet_ids, 0)

  tags = {
    Name    = "php-app"
    optimy  = "true"
  }

  vpc_security_group_ids = [aws_security_group.php_app_sg.id]

  provisioner "local-exec" {
    command = "echo waiting for SSH; while ! ssh -o StrictHostKeyChecking=no -i ${var.private_key_path} ec2-user@${self.public_ip} exit; do echo .; sleep 5; done"
  }
  
  provisioner "local-exec" {
    command = <<EOF
      ansible-playbook -u ec2-user -i ${self.public_ip}, --private-key ${var.private_key_path} ../server-setup/playbook.yml \
      --extra-vars "db_name=${var.db_name} db_username=${var.db_username} db_password=${var.db_password} docker_username=${var.docker_username} mysql_root_password=${var.db_root_password}"
    EOF
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.private_key_path)
    host        = self.public_ip
  }
}

resource "aws_security_group" "php_app_sg" {
  name        = "php-app-sg"
  description = "Allow HTTP, MySQL, and SSH"

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

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
  value = aws_instance.php_app.public_ip
}
