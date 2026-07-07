Terraform AWS lab — variables and usage

Files
- `main.tf` — skeleton resources (VPC, SG)
- `variables.tf` — variable definitions
- `outputs.tf` — outputs

Recommended `terraform.tfvars` example:

```
aws_region = "us-east-1"
vpc_cidr = "10.10.0.0/16"
admin_cidr = "YOUR_ADMIN_CIDR" # e.g. 203.0.113.0/32
```

Usage
```bash
cd infra/terraform/aws
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars" -auto-approve
```

Notes
- This is a skeleton; you must provide AMI mappings, subnet creation, and EC2 instance resources for Security Onion, Windows (use a Windows AMI), and Zeek.
- Secure SSH keys and do not commit private keys to git.
