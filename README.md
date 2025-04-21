# AWS-TF-PROJ
Terraform project to spin up an instance with datastore

Clone repo

Run initTF.py

Setup the state
- Create a datastore: 
- `aws s3api create-bucket   --bucket damions-terraform-bucket   --region us-east-1   `


add versioning

- `aws s3api put-bucket-versioning  --bucket damions-terraform-bucket  --versioning-configuration Status=Enabled`

create the db table for state locking

- `aws dynamodb create-table   --table-name terraform-locks   --attribute-definitions AttributeName=LockID,AttributeType=S   --key-schema AttributeName=LockID,KeyType=HASH   --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5   --region us-east-1`


terraform plan
terraform apply

check output for alb_dns_name and put that into your browser for a confirmation message the server is up and running. Takes a couple minutes to spin up, so if you get a bad gateway, just wait a few minutes.


### Reasoning

original prompt: 
A set of files with the Terraform code to bring up:
Compute infrastructure within AWS that an application could eventually run on.
A data store in AWS, that the compute infrastructure can communicate with.


After the follow-up questions, I tried not to over think it and just set about adding the required parts. I needed compute, network, data, and decided to add a load balancer for being vaguely production aware. 

I was super rusty on terraform, not having used it regularly since 0.8 so I spent a lot of time going back and forth with docs and google and occasionally asking chatgpt to explain bits to me. I think it's much cleaner now than it would have been in 0.8 and terraform validate and fmt are nice features.  I started by looking around at current terraform on aws best practices to ensure I wasn't missing anything new for terraform and then just tried to build with them in mind. 

I created a python script from some skeletons i had laying around, and created my directory structure with some modules and files to start. This was probably unnecessary, but it got me warmed up. I thought I was going to need to build in more python scripting, but that wasn't needed in the end. 


I started with network to give compute somewhere to live, wrote compute, set up the alb and then the DB once it was running. 
I used the security groups and routing to keep everything talking to each other. 

The code’s split into modules to keep everything clean and modular:

- **`network/`** – Sets up the VPC, public/private subnets (2 each for the alb), routing, NAT, and internet gateway. 
- **`compute/`** – Launches an EC2 instance, adds a profile for Systems Manager access, and sets up a security group that only allows traffic from the ALB.
- **`load_balancer/`** – Creates an Application Load Balancer (ALB), target group, listeners for Http/Https, and its security group.
- **`data/`** – Creates a PostgreSQL db in a private subnet, only accessible from the app instance.
- **`state`** - There is state in an s3 bucket with a dynamoDB db with versioning.




#### VPC & Subnets
Went with a `/16` VPC to give plenty of IP space, this was probably overkill, even a /24 would have been sufficient for this tiny project. There are 2 public subnets (for the ALB) and 2 private subnets (for the app and database). The private stuff gets internet access through a NAT gateway.

#### ALB
I'm using an ALB for routing and SSL termination. It listens on http and https, and redirects http to https (just commented out for now while testing). Security group is wide open to the internet on port 80/443 — might tighten that up later depending on the use case.

#### EC2 Instance
This is where the app runs — a t3.micro instance in a private subnet with no public IP. Apache gets installed with user_data and I also try to hit the database to show connection status on the homepage. It uses Systems Manager for access, so there’s no need to mess with SSH keys. I used yum update-minimal -y --security to update, but quickly, and just the security stuff so it would deploy quicker for this. 

#### RDS
PostgreSQL 14, t3.micro instance, private subnet, and locked down to only accept connections from the EC2 instance security group. No public access. Just enough to demo DB connectivity securely.



### Security Stuff

- **Public access only goes to the ALB**, never directly to EC2 or RDS.
- **EC2 can talk to RDS**, but nothing else can.
- ALB and EC2 each have their own scoped-down security groups.
- **No SSH**, just SSM access (more secure, easier to audit).
- Avoided hardcoding sensitive values like DB passwords, they’re passed in via vars for this project. Use Secrets manager for really real. 


### TODOs
- Automating the cert provisioning with route 53 dns validation is the big one.
- I could add more validations, but just included the one for db_name for now. 
- Put the state creation stuff in initTF.py
- I could possibly tighten up the security groups a bit more, but it's really application dependent for more tweaks.
- There are no logs added yet per the clarifying questions those were out of scope, but logging and monitoring would be great to have.






