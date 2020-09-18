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

##### NETWORK VARIABLES #####
variable "host-interface-name" {
  type  = string
  default = "hostnet"
  description = "Name of network interface on host."
}

variable "subnet-ipv4-cidr-block" {
  type = string
  default = "10.240.0.0/26"
  description = "CIDR block for fabric subnet."
}

##### COMPUTE VARIABLES #####
variable "vm-image-name" {
  type = string
  default = "ibm-ubuntu-18-04-1-minimal-amd64-1"
  description = "Image name for VSI."
}

variable "vm-profile-name" {
  type = string
  default = "bx2-8x32"
  description = "Instance Profile for VSI."
}

variable "vsi-count" {
  type = number
  default = 1
  description = "Number of vsi instances."
}

variable "worker_count" {
  type = number
  default = 1
  description = "Number of IKS worker instances."
}

variable "ansible_host_template" {
  type = string
  default = "%s ansible_host=%s fabric_ip=%s uuid=%s"
}
