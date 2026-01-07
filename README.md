# Terraform AWS Infrastructure - Northwind E-Commerce Platform

This Terraform configuration provisions a complete, production-ready AWS infrastructure for the Northwind E-Commerce platform. It creates a modular, scalable architecture with networking, database, and compute resources.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [What It Creates](#what-it-creates)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Usage](#usage)
- [Module Structure](#module-structure)
- [Outputs](#outputs)
- [Cleanup](#cleanup)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

This Terraform project implements a three-tier architecture on AWS:

1. **Networking Layer** - VPC with public and private subnets across multiple availability zones
2. **Database Layer** - RDS PostgreSQL database in private subnets
3. **Compute Layer** - Auto Scaling Group with Application Load Balancer serving web traffic

The infrastructure is designed for high availability, scalability, and security following AWS best practices.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Internet                            │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │  Application Load     │
            │  Balancer (ALB)       │
            │  Public Subnets       │
            └──────────┬────────────┘
                       │
        ┌──────────────┴──────────────┐
        │                             │
        ▼                             ▼
┌──────────────┐            ┌──────────────┐
│  EC2 Instance│            │  EC2 Instance│
│  (Auto       │            │  (Auto       │
│  Scaling)    │            │  Scaling)    │
│  Public AZ-1 │            │  Public AZ-2 │
└──────┬───────┘            └──────┬───────┘
       │                           │
       │                           │
       └───────────┬───────────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │  RDS PostgreSQL      │
        │  Database            │
        │  Private Subnets     │
        │  Multi-AZ            │
        └──────────────────────┘
```

## 🚀 What It Creates

### Networking Module (`modules/networking`)
- **VPC** with custom CIDR block (default: 192.168.0.0/16)
- **2 Public Subnets** (one per availability zone)
- **2 Private Subnets** (one per availability zone)
- **Internet Gateway** for public subnet internet access
- **NAT Gateway** for private subnet outbound internet access
- **Route Tables** for public and private subnets
- **Security Groups** for network traffic control

### Database Module (`modules/database`)
- **RDS PostgreSQL 15.4** instance
- **DB Subnet Group** in private subnets
- **Security Group** allowing PostgreSQL traffic from VPC only
- **Automated Backups** enabled
- **Multi-AZ** deployment option (configurable)

### Compute Module (`modules/compute`)
- **Application Load Balancer (ALB)** in public subnets
- **Target Group** for HTTP traffic (port 80)
- **Auto Scaling Group** with EC2 instances
- **Launch Template** with Amazon Linux 2023 AMI
- **IAM Role & Instance Profile** for EC2 instances
- **Security Groups** for ALB and EC2
- **Nginx** web server pre-installed via user data

## 📦 Prerequisites

Before you begin, ensure you have:

1. **Terraform** installed (version >= 1.0)
   ```bash
   terraform version
   ```

2. **AWS Account** with appropriate permissions
   - VPC creation/modification
   - EC2 (instances, security groups, launch templates)
   - RDS (database instances)
   - ELB/ALB (load balancers)
   - Auto Scaling Groups
   - IAM (roles, instance profiles)

3. **AWS Credentials** configured
   - See [AWS Credentials Setup](#aws-credentials-setup) below

4. **Git** (optional, for cloning the repository)

## 🚀 Quick Start

### 1. Clone or Navigate to the Project

```bash
cd terraform-assessment
```

### 2. Configure AWS Credentials

**Option A: Using the provided script (Windows Command Prompt)**
```cmd
set-my-aws-credentials.bat
```

**Option B: Set environment variables manually**
```cmd
set AWS_ACCESS_KEY_ID=your-access-key
set AWS_SECRET_ACCESS_KEY=your-secret-key
set AWS_DEFAULT_REGION=us-east-1
```

**Option C: Use AWS CLI**
```bash
aws configure
```

For more details, see [AWS_CREDENTIALS_SETUP.md](./AWS_CREDENTIALS_SETUP.md)

### 3. Configure Variables

Copy the example variables file and edit it:

```bash
copy terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set your database password:

```hcl
db_password = "YourStrongPassword123!"
```

**Note:** The password must meet AWS RDS requirements:
- Minimum 8 characters
- Mix of uppercase, lowercase, numbers, and symbols

### 4. Initialize Terraform

```bash
terraform init
```

This downloads the required providers and modules.

### 5. Review the Plan

```bash
terraform plan
```

Review the changes that will be made. You should see:
- VPC and networking resources
- RDS database instance
- ALB and Auto Scaling Group
- Security groups and IAM roles

### 6. Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted to create the resources.

**⏱️ This will take approximately 10-15 minutes** to create all resources.

## ⚙️ Configuration

### Variables

Key variables you can customize in `terraform.tfvars`:

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region for resources | `us-east-1` |
| `vpc_cidr` | CIDR block for VPC | `192.168.0.0/16` |
| `db_instance_class` | RDS instance class | `db.t3.micro` |
| `db_allocated_storage` | RDS storage in GB | `20` |
| `db_name` | Database name | `northwind` |
| `db_username` | Database master username | `admin` |
| `db_password` | Database master password | **Required** |
| `instance_type` | EC2 instance type | `t3.micro` |
| `min_size` | Minimum ASG instances | `1` |
| `max_size` | Maximum ASG instances | `3` |
| `desired_capacity` | Desired ASG instances | `1` |
| `project_name` | Project name for tagging | `northwind` |
| `environment` | Environment name | `production` |

### Example `terraform.tfvars`

```hcl
aws_region = "us-east-1"

# Database credentials
db_username = "admin"
db_password = "MySecurePassword123!"

# Optional: Override defaults
# vpc_cidr = "10.0.0.0/16"
# db_instance_class = "db.t3.small"
# instance_type = "t3.small"
# min_size = 2
# max_size = 5
```

## 📖 Usage

### View Outputs

After applying, view the created resources:

```bash
terraform output
```

Key outputs:
- `alb_dns_name` - URL to access your application
- `rds_endpoint` - Database connection endpoint
- `vpc_id` - VPC ID for reference

### Access the Application

1. Get the ALB DNS name:
   ```bash
   terraform output alb_dns_name
   ```

2. Open the URL in your browser:
   ```
   http://<alb-dns-name>
   ```

   You should see the Northwind E-Commerce welcome page with instance information.

### Connect to the Database

1. Get the RDS endpoint:
   ```bash
   terraform output rds_endpoint
   ```

2. Connect using your database client:
   ```
   Host: <rds-endpoint>
   Port: 5432
   Database: northwind
   Username: admin
   Password: <your-db-password>
   ```

**Note:** The database is in private subnets, so you'll need to:
- Connect from an EC2 instance in the VPC, OR
- Use AWS Systems Manager Session Manager, OR
- Set up a bastion host

### Scale the Application

Modify `terraform.tfvars`:

```hcl
min_size = 2
max_size = 5
desired_capacity = 3
```

Then apply:
```bash
terraform apply
```

The Auto Scaling Group will automatically adjust the number of instances.

## 📁 Module Structure

```
terraform-assessment/
├── main.tf                 # Root configuration
├── variables.tf            # Variable definitions
├── outputs.tf              # Output definitions
├── terraform.tfvars        # Variable values (not in git)
├── terraform.tfvars.example # Example variables
│
├── modules/
│   ├── networking/         # VPC, subnets, gateways
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── database/           # RDS PostgreSQL
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── compute/            # ALB, ASG, EC2
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── .github/
    └── workflows/
        └── pipeline.yml     # CI/CD pipeline
```

## 📤 Outputs

After applying, Terraform provides these outputs:

| Output | Description |
|--------|-------------|
| `vpc_id` | ID of the created VPC |
| `public_subnet_ids` | List of public subnet IDs |
| `private_subnet_ids` | List of private subnet IDs |
| `rds_endpoint` | RDS database endpoint (sensitive) |
| `alb_dns_name` | DNS name of the Application Load Balancer |
| `alb_arn` | ARN of the Application Load Balancer |

View all outputs:
```bash
terraform output
```

View specific output:
```bash
terraform output alb_dns_name
```

## 🧹 Cleanup

To destroy all created resources:

```bash
terraform destroy
```

Type `yes` when prompted.

**⚠️ Warning:** This will permanently delete:
- All EC2 instances
- The RDS database (including data)
- Load balancer
- VPC and all networking resources

**Note:** Some resources may take a few minutes to delete (especially RDS).

## 🔧 Troubleshooting

### Error: "No valid credential sources found"

**Solution:** Set up AWS credentials. See [AWS_CREDENTIALS_SETUP.md](./AWS_CREDENTIALS_SETUP.md)

```cmd
set-my-aws-credentials.bat
```

### Error: "Database password does not meet requirements"

**Solution:** Use a password that meets AWS RDS requirements:
- Minimum 8 characters
- Mix of uppercase, lowercase, numbers, and symbols

Example: `MySecure123!`

### Error: "Insufficient permissions"

**Solution:** Ensure your AWS IAM user/role has permissions for:
- VPC, EC2, RDS, ELB, Auto Scaling, IAM

See [AWS_CREDENTIALS_SETUP.md](./AWS_CREDENTIALS_SETUP.md) for required permissions.

### Error: "Resource already exists"

**Solution:** Some resources (like VPCs) might have naming conflicts. Try:
1. Change `project_name` in `terraform.tfvars`
2. Or delete the conflicting resource manually in AWS Console

### Terraform Plan Shows Errors

**Solution:** 
1. Run `terraform init` to ensure modules are downloaded
2. Check that all required variables are set in `terraform.tfvars`
3. Verify AWS credentials are valid

### Can't Access Application via ALB DNS

**Possible causes:**
1. **Security group** - Check ALB security group allows HTTP (port 80) from your IP
2. **Health checks failing** - Check target group health in AWS Console
3. **Instances not registered** - Verify Auto Scaling Group has running instances

**Debug:**
```bash
# Check ALB status
aws elbv2 describe-load-balancers

# Check target group health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>
```

## 📚 Additional Resources

- [AWS Credentials Setup Guide](./AWS_CREDENTIALS_SETUP.md)
- [Password Guide](./PASSWORD_GUIDE.md)
- [Command Prompt Setup Guide](./CMD_SETUP_GUIDE.md)
- [Quick Start Guide](./QUICK_START_CMD.md)

## 🏷️ Resource Tagging

All resources are tagged with:
- `Name`: Resource-specific name
- `Environment`: Environment name (default: `production`)
- `ManagedBy`: `Terraform`
- `Project`: Project name (default: `northwind`)

## 🔒 Security Features

- **Database in private subnets** - Not directly accessible from internet
- **Security groups** - Restrictive rules (only necessary ports open)
- **IAM roles** - Least privilege for EC2 instances
- **Encrypted RDS** - Database encryption at rest
- **VPC isolation** - Network segmentation

## 💰 Cost Estimation

Approximate monthly costs (us-east-1, on-demand):

- **VPC & Networking**: ~$0 (free tier eligible)
- **NAT Gateway**: ~$32/month + data transfer
- **RDS db.t3.micro**: ~$15/month (free tier eligible for first year)
- **EC2 t3.micro (1 instance)**: ~$7/month (free tier eligible for first year)
- **ALB**: ~$16/month + LCU charges
- **Total**: ~$70-100/month (after free tier)

**Note:** Costs vary by region, usage, and instance sizes. Use AWS Pricing Calculator for accurate estimates.

## 📝 Notes

- This configuration uses **terraform-aws-modules/alb/aws** version 9.0+
- RDS uses **PostgreSQL 15.4**
- EC2 instances use **Amazon Linux 2023**
- All resources are created in **2 availability zones** for high availability
- Database backups are **automatically enabled** (7-day retention)

## 🤝 Contributing

This is an assessment project. For questions or issues, refer to the troubleshooting section or AWS documentation.

## 📄 License

This project is for educational/assessment purposes.

---

**Created with Terraform** 🚀

