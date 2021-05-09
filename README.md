# Terraform AWS multi-account deployment

### The provisioned resources:

**This Terraform manifest is going to provision the below infrastructure resources:**

**AWS VPC:**
* New VPC
* Three Private subnets
* Three Public subnets
* Three route tables, and routes for the Public subnets
* Three route tables, and routes for the Private subnets
* Internet Gateway to be attached to the Route table of the public subnets
* Three NAT Gateways to allow private resources reach the internet and acquire updates
* Three Elastic IPs for the NAT gateways
* The route between the private RT and the NAT Gateway


**AWS EC2:**
* Bastion Host EC2 instance for connecting to private AWS resources
* Jenkins EC2 instance for CI/CD pipelines
* Jenkins install and configure script that will be executed in the instance user-data
* Security groups to allow the needed traffic for both instances (such as 22 and 443)
* IAM instance profile for Jenkins server
* Key Pair for each instance, and save its public/private parts in AWS SSM parameter store

**AWS RDS:**
* RDS Amazon Aurora Cluster with PostgreSQL compatibility, that has the below specs:
	Postgres version 12.4
	Auto minor version upgrade
	Provisioned engine mode
	Encrypted storage
	Backup retention period of 30 days
	Enable deletion protection
	Preferred backup and maintenance windows
Not publicly accessible
* Random string for the Admin password, and save it in AWS SSM parameter store
* Security groups to allow the needed traffic from the VPC CIDR range (5432)

**AWS EKS:**
* Amazon EKS cluster and nodes using the official EKS community module with the latest stable version, that has the below specs:
	Amazon EKS version 1.19
	Disable Public access
	 Cluster log retention for 30 days
	EKS node group with min, max and desired capacities.
* Security groups to allow the needed traffic between nodes and master, and the secure connection to the master
* IAM roles for both master and worker nodes

### Terraform structure:
* Terraform templates are defined inside terraform directory, and will be controlled using runway that will take care of the whole deployment process of Teraform in multiple AWS accounts/environments in a simplified way
* Inside terraform directory there is a ```.tfvars``` file for environment, with a symlink  for the file inside each module to centralize the usage of the variables across all modules.
* These ```.tfvars``` correspond to each environment, and will be used to distinguish between differnt resources specifications for each environment.
* runway will automatically detect the environment ```.tfvars``` file when we set the ```DEPLOY_ENVIRONMENT``` variable in its command.

### Runway:
####  What's runway:
* Runway is a lightweight terraform wrapper that will automatically do a lot of extra stuff for keeping the configurations DRY, working with multiple modules, managing multiple AWS accounts switch, and managing remote states.
* It's simply configured by creating a ```runway.yml``` file in  the root of the repo, and refernce all TF modulesi nside it.
* We also define all the AWS Account IDs that correspond to their appropriate environment, and also set the list of the IAM roles that will be assumed to switch between AWS accounts.
* In the deployments block, we define the ttraform modules paths, and any additiona options, such as the backend as shown below:
```bash
  - name: terraform
    modules:
      - ./terraform/vpc
      - ./terraform/rds
      - ./terraform/ec2
    module_options:
      terraform_backend_config:
        bucket: challenge-task-terraform-state-us-east-1
        region: us-east-1
        dynamodb_table: terraform_state
      terraform_version:
        "*": 0.15.0
    regions:
      - us-east-1
    account-id:
      <<: *account_ids
    assume-role:
      <<: *roles
```

####  Runway will do the below:
*  runway comes with built-in commands similar to terraform, such as ```init```, ```plan``` and ```deploy``` (apply)
* When running runway plan or deploy, only one variable is required, which is the ```DEPLOY_ENVIRONMENT```
* Once the DEPLOY_ENVIRONMENT variable is set, and you run ```runway plan``` command, it will automatically do all of the below steps:
    * Assume the IAM role that correspond to the specified environment, in our exampele it will assume: ```arn:aws:iam::581154480033:role/master_access``` role, as we set the ```DEPLOY_ENVIRONMENT``` as master.
    * In the backgroup, runway will execute ```aws sts assume-role``` and acquire the temporary aws credentials for this environment.
    * Then it will execute ```terraform init``` to initilize all TF modules specified in the modules YAML definition.
    *  Next, it will execute ```terraform plan``` and do the same.


####  How to run the manifest:
```bash
# Install runway from the below link:
# https://docs.onica.com/projects/runway/en/release/installation.html
```
```bash
# run the below command only for init/plan
DEPLOY_ENVIRONMENT=master runway plan -ci
```
```bash
# same for apply
DEPLOY_ENVIRONMENT=master runway deploy
```
Same for other environments, for example: to deploy to prod:
```bash
DEPLOY_ENVIRONMENT=prod runway deploy
```
