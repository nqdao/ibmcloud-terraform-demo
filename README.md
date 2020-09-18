# Terraform Demo
This project uses the [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm) plugin to interact with IBM Cloud. The docker image provided is running the following versions:
- Terraform 0.12
- Go 1.12
- IBM Cloud Provider v1.8.0

## Prerequisite
- You need to have an account to the [IBM Cloud](https://cloud.ibm.com/) and can create resources. This usually mean your account is upgraded to internal plan or equivalent.
- You need to have Docker and docker-compose installed on the machine that will be running Terraform. [Docker](https://docs.docker.com/install/) [Docker-compose](https://docs.docker.com/compose/install/)
- You have generated SSH keys in `~/.ssh/` directory. It is required that you generate a new key to be used with Terraform as IBM Cloud will return error if your public key is already registered in the cloud.

N.B. It is recommended that you generate a **new SSH key that is not passphrase-protected** as the current implementation does not handle passphrase for SSH connections.

## Setup
1. Clone this repository.
```
$ git clone git@github.com:nqdao/ibmcloud-terraform-demo.git
```
2. Run docker-compose to launch deployer docker container.
```
$ docker-compose run --rm deployer
```
3. Once inside the docker container (bash shell prompt is shown `bash-4.4#`), initialize Terraform workspace.
```
$ terraform init
```
4. It is recommended that you make a copy of `terraform.tfvars.example` and name it `terraform.tfvars` to override the default values to be specific to your environment and credential.

You are now ready to use Terraform.
