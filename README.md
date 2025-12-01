
# 🚀 Production-Grade EKS Terraform Setup (Multi-Environment)

This repository provides a **modular, reusable, production-ready Terraform framework** for deploying **Amazon EKS** using:

- Custom VPC (public/private subnets)
- S3 remote backend for Terraform state
- DynamoDB table for state locking
- Multi-environment structure (`dev`, `stage`, `prod`)
- Full workflow: init → plan → apply → destroy

This README gives you a clean, predictable, step-by-step guide to deploy and manage your EKS clusters.

---

## 📦 1. Prerequisites

### ✅ Install Terraform (>= 1.5)
Download:  
https://developer.hashicorp.com/terraform/install

Check version:

```powershell
terraform -version
```

---

### ✅ Install AWS CLI v2
Download:  
https://aws.amazon.com/cli/

Check installation:

```powershell
aws --version
```

---

### ✅ Create AWS IAM User
Create an IAM user with:

- **Programmatic Access**
- **AdministratorAccess** policy (for initial setup)

Then configure AWS CLI:

```powershell
aws configure --profile eks-terraform
```

Enter:

```
AWS Access Key ID: <your-key>
AWS Secret Access Key: <your-secret>
Default region name: us-east-2
Default output format: json
```

Verify identity:

```powershell
aws sts get-caller-identity --profile eks-terraform
```

Set the profile in your session:

```powershell
$env:AWS_PROFILE = "eks-terraform"
```

---

## 🗂️ 2. Project Structure

```
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
```

Each environment folder contains its own lifecycle (`init`, `plan`, `apply`, `destroy`).

---

## ☁️ 3. Create Terraform Backend (S3 + DynamoDB)

Terraform needs:

- An **S3 bucket** for remote state  
- A **DynamoDB table** for state locking  

### 3.1 Create S3 state bucket

Choose a globally unique name:

```
dev-eks-bucket-747034604262
```

Create the bucket:

```powershell
aws s3api create-bucket `
  --bucket dev-eks-bucket-747034604262 `
  --region us-east-2 `
  --create-bucket-configuration LocationConstraint=us-east-2 `
  --profile eks-terraform
```

---

### 3.2 Enable Versioning

```powershell
aws s3api put-bucket-versioning `
  --bucket dev-eks-bucket-747034604262 `
  --versioning-configuration Status=Enabled `
  --profile eks-terraform
```

---

### 3.3 Enable AES-256 Encryption

Create `encryption.json`:

```json
{
  "Rules": [
    {
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }
  ]
}
```

Apply encryption:

```powershell
aws s3api put-bucket-encryption `
  --bucket dev-eks-bucket-747034604262 `
  --server-side-encryption-configuration file://encryption.json `
  --profile eks-terraform
```

---

### 3.4 Create DynamoDB Lock Table

Terraform uses this table to prevent state corruption.

```powershell
aws dynamodb create-table `
  --table-name dev-terraform-locks `
  --attribute-definitions AttributeName=LockID,AttributeType=S `
  --key-schema AttributeName=LockID,KeyType=HASH `
  --billing-mode PAY_PER_REQUEST `
  --region us-east-2 `
  --profile eks-terraform
```

---

## 🚀 4. Deploy EKS (Dev Environment Example)

Move into the environment folder:

```powershell
cd envs/dev
$env:AWS_PROFILE = "eks-terraform"
```

---

### 4.1 Initialize Terraform

```powershell
terraform init
```

Should display:

```
Successfully configured the backend "s3"!
Terraform has been successfully initialized!
```

---

### 4.2 Preview Infra Changes

```powershell
terraform plan
```

---

### 4.3 Apply to Create Infrastructure

```powershell
terraform apply
```

Type **yes** when prompted.

This will create:

- VPC  
- Subnets  
- NAT + IGW  
- Route tables  
- IAM roles  
- EKS cluster  
- EKS managed node group  
- CloudWatch logs  

---

## 📡 5. Connect to Kubernetes

Once deployment succeeds:

```powershell
aws eks update-kubeconfig `
  --name eks-demo-dev `
  --region us-east-2 `
  --profile eks-terraform
```

Test connectivity:

```powershell
kubectl get nodes
kubectl get pods -A
```

---

## 💣 6. Destroy Everything Safely

To remove all EKS + VPC infrastructure:

```powershell
cd envs/dev
$env:AWS_PROFILE = "eks-terraform"
terraform destroy
```

Approve with:

```
yes
```

---

## 🧹 7. Remove Backend (Optional Reset)

### Delete DynamoDB lock table:

```powershell
aws dynamodb delete-table `
  --table-name dev-terraform-locks `
  --region us-east-2 `
  --profile eks-terraform
```

### Empty S3 bucket:

```powershell
aws s3 rm s3://dev-eks-bucket-747034604262 --recursive --profile eks-terraform
```

### Delete S3 bucket:

```powershell
aws s3api delete-bucket `
  --bucket dev-eks-bucket-747034604262 `
  --region us-east-2 `
  --profile eks-terraform
```

---

## 🛠️ 8. Troubleshooting

### ❗ DNS Error (“no such host”)

If you see:

```
lookup eks.us-east-2.amazonaws.com: no such host
```

Check connectivity:

```powershell
aws sts get-caller-identity --profile eks-terraform
```

If this fails → network/VPN/DNS issue.  
If it works → retry Terraform.

---

### ❗ State Lock Issues

Error:

```
Error acquiring the state lock
```

Fix:

```powershell
terraform force-unlock <LOCK_ID>
```

---

### ❗ Failed to Save State

```powershell
terraform state push errored.tfstate
```

---

## 📘 Summary

This README includes everything you need to:

- Configure AWS  
- Bootstrap backend  
- Initialize Terraform  
- Deploy EKS clusters  
- Clean up  
- Troubleshoot problems  

You can now create:

- `envs/stage/`
- `envs/prod/`

And deploy independent environments using the same Terraform modules.

---

# 🎉 Enjoy your fully reusable, production-grade EKS Terraform setup!
