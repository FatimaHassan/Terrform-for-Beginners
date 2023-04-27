# Terrform-for-Beginners
In this project we will create a single EC2 instance with bootstrapped APACHE using user data in default VPC.
## Step 1 - Setup AWS Cloud9 Environment
Log into your AWS Account → search for “Cloud9” → Create Environment → give it a name.
To remain under free-tier you can choose t2.micro as your EC2 instance for Cloud9 environment.
You can read more about Cloud9 from here https://aws.amazon.com/cloud9/
## Step 2 - Exporting AWS Keys in Terraform
When configuring AWS using Terraform, you need to provide your access keys to Terraform so that it can authenticate with the AWS API. Exporting access keys makes them available as environment variables, which Terraform can then use to interact with AWS.
![2023-04-27_11-31_1](https://user-images.githubusercontent.com/26363688/234791327-658920d3-464a-4e83-81f7-55d5ac32bd92.jpg)
## Step 3 - Creating main.tf file
In Terraform, main.tf is a file that defines the main configuration for your infrastructure as code. It is one of the standard filenames that Terraform uses for configuration files.
The main.tf file is where you define the resources you want to create and configure in your infrastructure. It contains the actual code that Terraform uses to create and manage resources. The resources you define in main.tf can include anything from virtual machines to databases, load balancers, security groups, and more.  
Complete main.tf is available in repository. I will explain sections of code here
### Provider configuration
In this step we will assign the cloud provider that we will be using. Since we are deploying our instance in default VPC, make sure you choose correct region.
```
#Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}
```
### Resource definitions

1. Create a Security Group that will be attached to your EC2 instance. We will allow traffic on port 80(http), 443(https) and 22(SSH). You can also take reference from official documentation by harshicorp.  
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group  
By default, AWS creates an ALLOW ALL egress rule when creating a new Security Group inside of a VPC. When creating a new Security Group inside a VPC, Terraform will remove this default rule, and require you specifically re-create it if you desire that rule. If you desire this rule to be in place, you can use this egress block:

```
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
```
2. To define the instance type in Terraform, we will utilize the free-tier t2.micro. Additionally, you have the option to include a tag for your instance. For this example, I have added a tag with the value "terraform_instance".  
Assign the security group to your EC2 instance that you created in previous step.  
Note: Since each AMI is specific to a region, kindly ensure that you are choosing correct ami-id as per your region.  
The user_data attribute in Terraform is utilized to transfer data to an instance when it is launched. It must be specified as a string in the Terraform configuration file and is capable of carrying any valid data at the time the instance is launched.  
Here we have installed APACHE web server and enabled the web server to start automatically on system boot, and create an HTML file with a "Hello World" message that displays the hostname of the system:

```
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

```
![ami-id](https://user-images.githubusercontent.com/26363688/234799811-025e75a6-039c-4dda-b96a-d05a6cc31907.jpg)  

## Step 4 - Run the Infrastructure
1. First we need to initialize a working directory containing Terraform configuration files. This command is typically run once at the beginning of a Terraform project to set up the project's dependencies and initialize the backend.
```
terraform init
``` 
![init](https://user-images.githubusercontent.com/26363688/234817973-cf3f8d29-c25e-4dc4-bbe8-4603c691470b.jpg)

2. Following command in Terraform is used to check the syntax and configuration of your Terraform files. This command is used to verify that your configuration files are syntactically correct and internally consistent. It's a good practice to check before applying terraform to catch any syntax errors in your configuration files. This can save you time and prevent errors that could cause your Terraform plan to fail.

``` 
terraform validate
``` 

![2023-04-27_11-30_1](https://user-images.githubusercontent.com/26363688/234817461-e94d312f-16c8-4713-ae6a-5a1daad9d97e.jpg)  

3. Following command is used to generate an execution plan for creating or modifying infrastructure resources defined in your Terraform configuration files. It provides a preview of the changes that Terraform will make to your infrastructure, allowing you to review and approve them before applying them.
``` 
terraform plan
``` 
![plan](https://user-images.githubusercontent.com/26363688/234818115-89b32572-3d8c-4eef-9289-d47559c895f6.jpg)  

4. Before applying changes, Terraform will prompt you to confirm that you want to apply the changes. If you do not want to apply the changes, you can exit the command with Ctrl+C. Once you confirm the changes, Terraform will begin applying them. During the apply process, Terraform will output progress updates and any errors encountered.
```
terraform apply
```
![apply](https://user-images.githubusercontent.com/26363688/234819071-48a7efa6-a922-4174-82b0-85bdd9ab1954.jpg)  

## Step 5 - Verify the Infrastructure
You can now check your EC2 console where all resource that were created would be running. You can access public DNS of your instance in browser to get the required output
![output](https://user-images.githubusercontent.com/26363688/234821717-936975dc-6509-49dc-ba56-157afcd1797d.jpg)






