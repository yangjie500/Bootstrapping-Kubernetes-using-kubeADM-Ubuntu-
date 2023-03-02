resource "tls_private_key" "project_private_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_file" "private_key" {
  content = tls_private_key.project_private_key.private_key_openssh
  filename = "~/.ssh/project_key.pem"
  file_permission = "0400"
}

resource "aws_key_pair" "project_key" {
  key_name = "project-key"
  public_key = tls_private_key.project_private_key.public_key_openssh

  # provisioner "local-exec" {
  # command = "echo '${tls_private_key.project_private_key.private_key_openssh}' > ~/.ssh/project_key.pem" }
}

locals {
  multiple_instances = {
    master = {
      subnet_id = element(module.vpc.public_subnets, 0)
      nodetype_tags = "master"
      isKubernetesTesting = "yes"
    }
    worker1 = {
      subnet_id = element(module.vpc.public_subnets, 1)
      nodetype_tags = "worker"
      isKubernetesTesting = "yes"
    }
  }
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = local.multiple_instances

  name = "instance-${each.key}"

  ami                    = "ami-0557a15b87f6559cf"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.project_key.key_name
  monitoring             = true
  vpc_security_group_ids = [module.project_sg.security_group_id]
  subnet_id              =  each.value.subnet_id
  associate_public_ip_address = true
  user_data = <<EOF
#!/bin/bash -x
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt-get install unzip
unzip awscliv2.zip
sudo ./aws/install
EOF

  tags = {
    Terraform   = "true"
    Environment = "dev"
    nodetype    = "${each.value.nodetype_tags}"
    isKubernetesTesting = "${each.value.isKubernetesTesting}"
  }
}

