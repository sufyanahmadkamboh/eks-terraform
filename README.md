# 🟦 Production-Grade EKS Terraform Setup (Multi-Env)

This repo contains a modular, reusable Terraform configuration for deploying **Amazon EKS** on a custom VPC, with S3 remote state + DynamoDB locking, and full multi-environment support (`dev`, `stage`, `prod`).

This README provides a **clean, predictable, step-by-step workflow** covering:

1. Installing prerequisites  
2. Creating backend infrastructure  
3. Initializing terraform  
4. Deploying your EKS cluster  
5. Destroying everything safely  
6. Troubleshooting state lock & DNS issues

---

# 📦 1. Prerequisites

### ✅ Install Terraform ≥ 1.5  
Download:  
https://developer.hashicorp.com/terraform/install

Check version:

```powershell
terraform -version
✅ Install AWS CLI v2
Download:
https://aws.amazon.com/cli/

Check:

powershell
Copy code
aws --version
✅ Configure IAM User
Create an IAM user with:

Programmatic access

Permission: AdministratorAccess (for testing)

Then configure AWS CLI:

powershell
Copy code
aws configure --profile eks-terraform
Enter:

pgsql
Copy code
AWS Access Key ID: <your key>
AWS Secret Access Key: <your secret>
Default region name: us-east-2
Default output format: json
Verify:

powershell
Copy code
aws sts get-caller-identity --profile eks-terraform
For the rest of this guide, set profile explicitly:

powershell
Copy code
$env:AWS_PROFILE = "eks-terraform"
🗂️ 2. Project Structure
cpp
Copy code
eks-terraform/
├── envs/
│   ├── dev/
│   │   ├── main.tf
│   │   └── backend.tf (optional)
│   ├── stage/
│   └── prod/
├── modules/
│   ├── vpc/
│   └── eks/
└── outputs.tf
Each environment has its own configuration (recommended for production).

☁️ 3. Create Terraform Backend (S3 + DynamoDB)
Before running Terraform, create:

S3 bucket for remote state

DynamoDB table for lock management

3.1 Create S3 bucket
Select a globally unique bucket name:

Copy code
dev-eks-bucket-747034604262
Create it:

powershell
Copy code
aws s3api create-bucket `
  --bucket dev-eks-bucket-747034604262 `
  --region us-east-2 `
  --create-bucket-configuration LocationConstraint=us-east-2 `
  --profile eks-terraform
3.2 Enable versioning
powershell
Copy code
aws s3api put-bucket-versioning `
  --bucket dev-eks-bucket-747034604262 `
  --versioning-configuration Status=Enabled `
  --profile eks-terraform
3.3 Enable AES-256 encryption
Create file encryption.json:

json
Copy code
{
  "Rules": [
    {
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }
  ]
}
Apply:

powershell
Copy code
aws s3api put-bucket-encryption `
  --bucket dev-eks-bucket-747034604262 `
  --server-side-encryption-configuration file://encryption.json `
  --profile eks-terraform
3.4 Create DynamoDB lock table
powershell
Copy code
aws dynamodb create-table `
  --table-name dev-terraform-locks `
  --attribute-definitions AttributeName=LockID,AttributeType=S `
  --key-schema AttributeName=LockID,KeyType=HASH `
  --billing-mode PAY_PER_REQUEST `
  --region us-east-2 `
  --profile eks-terraform
🚀 4. Deploy EKS in dev environment
Go inside the environment folder:

powershell
Copy code
cd envs/dev
$env:AWS_PROFILE = "eks-terraform"
4.1 Initialize Terraform
powershell
Copy code
terraform init
Should show:

nginx
Copy code
Successfully configured the backend "s3"!
Terraform has been successfully initialized!
4.2 Preview changes
powershell
Copy code
terraform plan
4.3 Apply (create the infra)
powershell
Copy code
terraform apply
Type:

bash
Copy code
yes
Terraform will now create:

VPC

Subnets

IGW / NAT

Route tables

IAM roles

EKS control plane

EKS managed node group

CloudWatch log group

This takes 10–15 minutes.

📡 5. Connect to Kubernetes
Once apply completes:

powershell
Copy code
aws eks update-kubeconfig `
  --name eks-demo-dev `
  --region us-east-2 `
  --profile eks-terraform
Test connectivity:

powershell
Copy code
kubectl get nodes
kubectl get pods -A
💣 6. Destroy Everything (Safe Cleanup)
To remove all EKS + VPC infra:

powershell
Copy code
cd envs/dev
$env:AWS_PROFILE = "eks-terraform"
terraform destroy
Then type:

bash
Copy code
yes
Terraform will remove:

EKS cluster

Node groups

VPC, subnets, IGW, NAT

IAM roles

CloudWatch logs

🧹 7. (Optional) Remove Terraform Backend
Only if you want to fully reset:

Delete DynamoDB lock table
powershell
Copy code
aws dynamodb delete-table `
  --table-name dev-terraform-locks `
  --region us-east-2 `
  --profile eks-terraform
Empty bucket
powershell
Copy code
aws s3 rm s3://dev-eks-bucket-747034604262 --recursive --profile eks-terraform
Delete bucket
powershell
Copy code
aws s3api delete-bucket `
  --bucket dev-eks-bucket-747034604262 `
  --region us-east-2 `
  --profile eks-terraform
🛠️ 8. Troubleshooting
❗ DNS issues (no such host):
If you see:

yaml
Copy code
lookup eks.us-east-2.amazonaws.com: no such host
Fix:

powershell
Copy code
aws sts get-caller-identity --profile eks-terraform
If this fails → network/VPN/DNS issue
If it works → retry Terraform.

❗ State lock issues
If you see:

csharp
Copy code
Error acquiring the state lock
Unlock manually:

powershell
Copy code
terraform force-unlock <LOCK_ID>
(LOCK_ID is shown in the error)

❗ Terraform failed to save state
Use:

powershell
Copy code
terraform state push errored.tfstate
📘 Summary
This README gives you a complete, clean workflow for:

Setting up AWS credentials

Creating Terraform backend

Running init/plan/apply

Deploying EKS

Cleaning everything

Troubleshooting

You can now:

Create stage and prod under envs/

Reuse the same workflow

Version everything in GitHub

Add CI (GitHub Actions) later