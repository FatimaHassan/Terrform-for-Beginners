#Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}

#Create EC2 Instance
resource "aws_instance" "instance1" {
  ami                    = "ami-04f1014c8adcfa670"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.terraform_sg.id]
  tags = {
    Name = "terraform_instance"
  }
  
  #Bootstrap APACHE installation and start
  user_data = <<-EOF
  #!/bin/bash
  # Use this for your user data (script from top to bottom)
  # install httpd (Linux 2 version)
  sudo yum update -y
  sudo yum install -y httpd
  sudo systemctl start httpd
  sudo systemctl enable httpd
  echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
  
  EOF
  
  user_data_replace_on_change = true
    
}

#Create security group 
resource "aws_security_group" "terraform_sg" {
  name        = "terraform_sg"
  description = "Open ports 22, 80, and 443"

  #Allow incoming TCP requests on port 22 from any IP
  ingress {
    description = "Incoming SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow incoming TCP requests on port 8080 from any IP
  ingress {
    description = "Incoming 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow incoming TCP requests on port 443 from any IP
  ingress {
    description = "Incoming 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform_sg"
  }
}
