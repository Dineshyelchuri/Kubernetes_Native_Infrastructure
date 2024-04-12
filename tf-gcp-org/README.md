# CSYE7125 - Advanced Cloud Computing

## tf-gcp-org

The terraform code in this repository is responsible for setting up networking resources such as Virtual Private Cloud (VPC), Subnetworks, Firewalls, Route for the kubernetes cluster.

## Terraform
Terraform is an open-source infrastructure as code software tool that enables you to safely and predictably create, change, and improve infrastructure <br><br>

## Setting up Infrastructure using Terraform 
 
<br> The terraform init command initializes a working directory containing Terraform configuration files:
```
terraform init
```

The terraform plan command creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure:
```
terraform plan
```

The terraform fmt command is used to check terraform configuration files adhere to canonical format:
```
terraform fmt
```

The terraform apply command executes the actions proposed in a Terraform plan to create, update, or destroy infrastructure:
```
terraform apply
```

The terraform destroy command is a convenient way to destroy all remote objects managed by a particular Terraform configuration:
```
terraform destroy
```