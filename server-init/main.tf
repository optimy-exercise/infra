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

data "aws_caller_identity" "current" {}


resource "aws_iam_role" "grafana_role" {
  name = "grafana-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "*"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "grafana_policy" {
  name        = "grafana-policy"
  description = "Policy for Grafana to access CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "sts:AssumeRole",
          "cloudwatch:*",
          "logs:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "grafana_assume_role_policy" {
  name   = "grafana-assume-role-policy"
  role   = aws_iam_role.grafana_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "sts:AssumeRole",
        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/grafana-role"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "grafana_role_attachment" {
  role       = aws_iam_role.grafana_role.name
  policy_arn = aws_iam_policy.grafana_policy.arn
}

resource "aws_iam_instance_profile" "grafana_instance_profile" {
  name = "grafana-instance-profile"
  role = aws_iam_role.grafana_role.name
}

resource "aws_instance" "php_app" {
  ami           = "ami-071878317c449ae48"
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = element(var.subnet_ids, 0)
  iam_instance_profile   = aws_iam_instance_profile.grafana_instance_profile.name

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

  ingress {
    from_port   = 3000
    to_port     = 3000
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
