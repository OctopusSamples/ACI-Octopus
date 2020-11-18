# ACI-Octopus
This repository contains Terraform code that you can use to create a production-ready Octopus Deploy container running in Azure Container Instances

## What's Used?

The technologies used to create a production-level Octopus environment are:
1. Azure Storage Accounts
2. Azure SQL Server
3. Azure SQL Database
4. Azure Storage Containers
5. Azure Container Groups
6. The official Octopus Deploy Docker image

## Main Configuration

The main configuration can be found under the `main.tf` file. It creates:
1. A storage account
2. Storage shares to hold crucial Octopus Deploy data
3. An Azure SQL server
4. An Azure SQL database
5. A SQL database firewall rule to allow Azure services to connect to the database
6. An Azure Container Instance Group, which is a collection of containers (only one container is used to deploy Octopus Deploy)

## Variables

The variables consist of:
1. The location (region) for the resources to exist in
2. The resource group to store the resources
3. The storage account name
4. Octopus Deploy username
5. SQL username
6. SQL password
7. Octopus Deploy password

```
variable "location" {
    type = string
}

variable "RG" {
    type = string
}

variable "storageAccountName" {
    type = string
}

variable "octopusUser" {
    type = string
}

variable "sqlLogin" {
    type = string
}

variable "dbpassword" {
    type = string
}

variable "octopusPassword" {
    type = string
}
```

## Passing In Variables At Runtime

If you would like to pass in the variables at runtime, whether it be Adhoc on a terminal or by passing in the values and deploying via Octopus Deploy, you can do so in the `terraform.tfvars` file

Example:
```
location = "eastus"
RG = "MichaelLevanResources"
octopusUser = "admin"
sqlLogin = "mike"
storageAccountName = "octopusstoragemjl92"
```

## How To Use This Code

1. The first thing you will want to do is insure that you run `terraform init`, which will pull down the latest version of the `azurerm` Terraform provider.
2. Next, run `terraform plan` which will prompt you for two passwords - the SQL pasword and the Octopus Deploy password.
3. The last step is to run `terraform apply` and create the resources