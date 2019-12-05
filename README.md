# csye6225-Azure-team8

## Team Information

| Name | NEU ID | Email Address |
| --- | --- | --- |
| Veena Vasudevan Iyer | 001447061 | iyer.v@husky.neu.edu |
| Amogh Doijode Harish| 001449026 | doijodeharish.a@husky.neu.edu |
| Ravi Kiran | 001491808 | lnu.ra@husky.neu.edu |
| | | |

## Technology Stack
Terraform used to interact with Azure to implement network module, virtual machine and lambda
The Amazon Machine Images being built here uses Packer. Packer is a Hashicorp 
technology used to automate building of Amazon Images.

## Build Instructions
    * az login command to login into Azure
    * Install Packer using - https://www.packer.io/
    * Generate ssh key and add in key pairs of instance resource in AWS
    * Follow the deploy instructions to view an ami being generated
    
## Deploy Instructions
    * After successful login into Azure, before creating image we need to create Resource Group
    * `az group create -n myResourceGroup -l westus2`
    * You will need your credentials to create AMI.
    * Add subscription id, client id, tenant id into centos.json file
    * You can get your credentials using the below command
    * `az ad sp create-for-rbac --query "{ client_id: appId, client_secret: password, tenant_id: tenant }" `
    * You can find subscription id using 
       `az account show --query "{ subscription_id: id }"` 
    * After adding the above credentials use the below command to build AMI
        `packer build centos.json`
    * Once image is created and can be viewed in the Azure Dashboard run terraform
    *   `terraform plan -out=plan1 -var resource_group_name=resourcegroupname -var packer_image=amiimagename -var lambda_filepath="*.zip" `
    * View Dashboard to see the infrastructure as code created in Azure using Terraform
