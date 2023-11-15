README.md

*** Backup for wordpress: ***

cronjob for ec2 /var/www and other folders: wordpress-init.sh

RDS automated backup enabled - check rds.tf

EFS (for easy file sharing enabled) automated backup enabled - check efs.tf

S3 backup - versioning, encryption enabled - check s3bucket.tf

tfstate - use run after first apply: uncomment backend s3 to switch from local backup of tfstate to aws/s3+versioning; terraform init and terraform apply needed

EC2 Backup plan - check aws_backup_plan.tf (every 2 hours after 12PM, 3 hours limit duration)

Storage volumes backup enabled (every 2 hours after 12PM, 3 hours limit duration) via Data Lifecycle policy and (IF) volume tags: Backup = true - and data_lifecycle.tf Structure 

This repository provides the minimal set of resources, to deploy wordpress on aws and have a redundancy, HA backups for db storage, etc and restore policy:

acm.tf - AWS Certificate Manager Terraform module

alb.tf - AWS Application and Network Load Balancer Terraform module - attached to autoscalling - Access logs currently not working, to be tested out!

asg.tf - AWS Auto Scaling Group (ASG) Terraform module efs.tf - Provides an Elastic File System (EFS) File System resource output.tf - Terraform Output Values

rds.tf - AWS RDS Terraform module mariadb security_group.tf - AWS EC2-VPC Security Group Terraform module 

vpc.tf - AWS VPC Terraform module, Subnets, Route Tables, IGW, NAT 

variables.tf - variables used in Terraform.

terraform.tfvars - DB account name and password and DB name during installation

cloudwatch.tf - Cloudwatch metrics for CPU monitoring on application load ballancer 

waf.tf - WAF module for Application Load Ballancer attachment security_groups (aws firewall rules) - firewall rules for inbound and outbound access


TESTS: Testing The repository contains TravisCI and KitchenCI files for some basic tests. 

*** The test artifacts are found at the test folder: ***

-Assets 
  
  ** Binaries, currently kitchen generates a key pair for EC2 instance to this folder. 

-Fixtures:

  ** Includes a test Terraform module for KitchenCI. 

-Integration 
  
  ** Includes a test suite with the following tests: Communication to NLB over port 80 SSH over port 22 from the public ip which is set as jumpbox_ip.

  ** Operating system parameters are checked and so is a basic terraform state version check. 

The terraform variable values for: "jumpbox_ip" is imported from environment variables as it is usually provided as sensitive values from CI system. 

**** In order to do local testing I would recommend to create a .env file as follows: *** 

export JUMPBOX_IP="JUMPBOX_IP" 
export ROUTE53_ZONE_ID="R53_ZONE_ID" 
export AWS_ACCESS_KEY_ID="KEY" 
export AWS_SECRET_ACCESS_KEY="SECRET" 
export AWS_DEFAULT_REGION="REGION" 

*** References ***

https://github.com/aws-samples/aws-refarch-wordpress 

https://d1.awsstatic.com/whitepapers/wordpress-best-practices-on-aws.pdf 

https://aws-quickstart.s3.amazonaws.com/quickstart-bitnami-wordpress/doc/ 
