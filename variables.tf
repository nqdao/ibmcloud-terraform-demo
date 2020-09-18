variable "prefix" {
  type = string
  description = "Prefix for all VPC resources for easy identification"
}

variable "ibmcloud_apikey" {
  type = string
  description = "Your IBMCloud API key."
}

variable "ssh-pub-key-path" {
  type = string
  description = "Path to SSH public key to access virtual hosts."
}

variable "ssh-key-name" {
  type = string
  default = "tf-deploy-key"
  description = "Name of SSH key to access virtual hosts."
}

variable "use-existing-key" {
  type = bool
  default = false
  description = "Whether Terraform should use an uploaded key in the cloud."
}

##### COMPUTE VARIABLES #####
variable "vsi_count" {
  type = number
  default = 3
  description = "Number of vsi instances."
}
