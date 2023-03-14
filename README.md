# Bitwarden AWS Installation 

* Author:  Jason Paul
* Email:  jasonpa@gmail.com

## Introduction

This project includes resources for spinning up an AWS environment ready to install [Bitwarden](https://Bitwarden.com/) for self hosting.  The environment in AWS is created using Terraform.  It creates the following:

* EC2 instance running Debian 11.  By default the instance type is t3.medium to meet the [recommended Bitwarden hardware requirements](https://Bitwarden.com/help/install-on-premise-linux/).  Note that this will not be covered under the [AWS Free Tier](https://aws.amazon.com/free/) and charges will apply.
* 50GB [Amazon Elastic Block Storage](https://aws.amazon.com/ebs/) (EBS) mounted at /opt/Bitwarden to store all Bitwarden related files.
* AWS VPC with private and public subnets.
* [User Data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html) shell script to automatically install and configure preqreuisites to prepare EC2 the instance for installing Bitwarden.  Note that there are some prerequisites to be handled before proceeding with the Bitwarden installation.

## Security Considerations

This project is intended for testing and evaluation purposes, to speed up bringing up an environment for self hosting Bitwarden.  This installation exposes port 22 for SSH, and ports 80 and 443 for HTTP/HTTPS to the internet.  Do consider adding additional security layers if you will be using this configuration outside of a testing environment.  You may want to consider using an [Amazon HTTP API Gateway](https://aws.amazon.com/api-gateway/), or enabling AWS [Web Application Firewall](https://aws.amazon.com/waf/) (WAF) to limit brute force attempts, and block regions or countries that should not have access to the server.

## Other Considerations

If you will be using this configuration outside of a testing environment, it is recommended to set up regular backups of the Bitwarden data.  Review [this article](https://Bitwarden.com/help/backup-on-premise/) for details on what needs to be backed up.  Some options not covered by this project:

* Automated nightly snapshots of the EC2 virtual machine.
* Automated nightly backups of the EBS disk.
* Automated process to archive and copy the bwdata folder to an S3 bucket.

## Usage

**To use this repository:** 

You will need:

* [Terraform](https://developer.hashicorp.com/terraform/downloads) installed.  Recommending version 1.3.6 or higher.
* Git available to clone the repo

* Valid AWS credentials as an environment variable, via SSO, or in ```~/.aws/credentials```.


**To create the environment:**

1.   ```git clone``` this folder.  

2.  Add an SSH public key to the root folder to be added to the EC2 instance for SSH access.  If you do not have an SSH public/private key pair, you will need to generate one first.  The default name of the public key file is id_rsa.pub.  This can be adjusted in the Terraform ssh_key_file variable, or set in the terraform.tfvars file.

3.  Set the timezone the server will be located in.  By default, the userdata.sh script sets the timezone to ```America/Toronto```.  Adjust this as needed.

4.  Change to the terraform directory and run the following commands:

```
terraform init
terraform plan
terraform apply
```

5.  Once Terraform has finished creating the environment, it will output the public and private IP address for the EC2 instance.  You can SSH into the instance using the user ```admin```, which is the default for Debian 11, and using the SSH Private Key that pairs with the public key you installed.

## Prerequisites for Installing Bitwarden

1.  Create a DNS A record to specify a fully qualified domain name for the Bitwarden server.  Point the domain name to the public IP address of the AWS EC2 instance returned by Terraform.  Ideally this can be done in [AWS Route 53](https://aws.amazon.com/route53/) but if you use another DNS provider, you can set it up there.  

2.  Set up an SMTP server for Bitwarden to send verification emails using.  This can be an internal mail server, an external SMTP server like [GMail SMTP](https://support.google.com/a/answer/176600?hl=en), or a service like [Amazon Simple Email Service](https://aws.amazon.com/ses/) (SES).  This information will need to be specified during the installation before you can use Bitwarden.

3.  A Bitwarden Installation ID and Key for self-hosting.  This can be requested at [this](https://Bitwarden.com/host/) link.

## References and Resources

* [Bitwarden Linux On-Premise Installation Guide](https://Bitwarden.com/help/install-on-premise-linux/)
* [Amazon Simple Email Service SMTP Setup](https://docs.aws.amazon.com/ses/latest/dg/send-email-smtp.html)
* [Verifying Easy DKIM for use with SES](https://docs.aws.amazon.com/ses/latest/dg/creating-identities.html#just-verify-domain-proc)
