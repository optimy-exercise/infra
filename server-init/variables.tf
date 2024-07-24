variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "eu-central-1"
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "The key pair name for SSH access"
  type        = string
}

variable "private_key_path" {
  description = "The path to the private key file for SSH access"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "The subnet IDs"
  type        = list(string)
}

variable "db_name" {
  description = "The name of the MySQL database"
  type        = string
  default     = "app"
}

variable "db_username" {
  description = "MySQL database username"
  type        = string
}

variable "db_password" {
  description = "MySQL database password"
  type        = string
}

variable "db_root_password" {
  description = "MySQL database root password"
  type        = string
}

variable "docker_username" {
  description = "Docker Hub username"
  type        = string
}
