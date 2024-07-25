# Infrastructure Repository

This repository contains the infrastructure setup for deploying an EC2 VPS instance along with a MySQL database and a Grafana dashboard. The infrastructure is managed using Terraform and Ansible.

## Table of Contents

- [Infrastructure Repository](#infrastructure-repository)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Setup Overview](#setup-overview)
  - [Terraform Setup](#terraform-setup)
    - [Variables](#variables)
    - [Usage](#usage)
  - [Ansible Setup](#ansible-setup)
  - [CloudWatch and Grafana](#cloudwatch-and-grafana)
  - [Github Pipeline](#github-pipeline) 

## Prerequisites

Ensure you have the following installed on your local machine:

- [Terraform](https://www.terraform.io/downloads.html)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [AWS CLI](https://aws.amazon.com/cli/)
- An AWS account with the necessary IAM permissions

## Setup Overview

The setup involves:

1. **Terraform**: To provision AWS resources including EC2 instances, IAM roles, and security groups.
2. **Ansible**: To configure the EC2 instance, install Docker, deploy MySQL and Grafana containers, and set up the database schema.

## Terraform Setup

### Variables

The Terraform configuration uses several variables defined in `vars.tf`:

- `aws_region`: AWS region to deploy the resources.
- `instance_type`: EC2 instance type.
- `key_name`: Name of the SSH key pair.
- `subnet_ids`: List of subnet IDs for the instance.
- `private_key_path`: Path to the private key file.
- `db_name`: Database name.
- `db_username`: Database username.
- `db_password`: Database password.
- `db_root_password`: Root password for MySQL.
- `docker_username`: DockerHub username.

### Usage

1. **Initialize Terraform**:
   ```sh
   terraform init
   ````
2. **Apply Terraform Configuration**:

```sh
terraform apply
```
Confirm the apply action with yes.

3. **Output**:
After applying, Terraform will output the public IP of the EC2 instance.

### Ansible Setup
The Ansible playbook playbook.yml performs the following tasks:

1. Installs Docker.
2. Deploys MySQL and Grafana containers.
3. Configures MySQL with the provided schema.
4. Sets up Grafana with access to CloudWatch.

To run the Ansible playbook:

```sh
ansible-playbook -vvv -u ec2-user -i <EC2_PUBLIC_IP>, --private-key <PATH_TO_PRIVATE_KEY> <PATH_TO_PLAYBOOK>"
```
Replace <EC2_PUBLIC_IP>, <PATH_TO_PRIVATE_KEY> and <PATH_TO_PLAYBOOK> with appropriate values.
You could also add extra vars overwriting `vars.yml` file with the `--extra-vars` flag.

**NOTE**

The ansible playbook is being run from **Terraform** everytime we run a `terraform plan`. That being said, we can run manually just the ansible-playbook with the command above.

### CloudWatch and Grafana
The Grafana container is configured with rights to use AWS CloudWatch as a data source. 

In order to set-up grafana we need to:

1. Login with admin:admin credentials and change root password
2. Configure CloudWatch as a source in grafana adding user role RNS and region.
3. Create our visualizations


### Github Pipeline

A github deploy pipeline has also been setup and being triggered everytime we push on main branch running the terraform-ansible process