# Terraform
Deploy an EC2 Instance in the default VPC.
Bootstrap the EC2 instance with a script that will install and start Jenkins.
Create and assign a Security Group to the Jenkins Security Group that allows traffic on port 22 from my IP and allows traffic from port 8080.
Create an S3 bucket for the Jenkins Artifacts that is not open to the public.
Verify that I can reach your Jenkins install via port 8080 in my browser.
Create an IAM Role that allows S3 read/write access for the Jenkins Server and assign that role to the Jenkins Server EC2 instance.
Confirm this by sshing into the instance and without using my credentials, test some S3 AWS CLI commands.
