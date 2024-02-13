Launch an Auto Scaling group that spans 2 subnets in the default VPC.
Create a security group that allows traffic from the internet and associate it with the Auto Scaling group instances.
Include a script in the user data to launch an Apache webserver. The Auto Scaling group should have a min of 2 and max of 5.
To verify everything is working, check the public IP addresses of the two instances. Manually terminate one of the instances to verify that another one spins up to meet the minimum requirement of 2 instances.
Create an S3 bucket and set it as your remote backend.
        -------------------------------------------------------
Add an ALB in front of the Auto Scaling group.
Create a security group for the ALB that allows traffic from the internet and associate it with the ALB.
Modify the Auto Scaling group security group to only allow traffic from the ALB.
Output the public DNS name of the ALB and verify I’m able to reach your webservers from a browser.
