provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_apikey
  generation = 2
}

##### SSH Key #####
data "ibm_is_ssh_key" "existing-ssh-key" {
  count = var.use-existing-key ? 1 : 0
  name  = var.ssh-key-name
}

resource "ibm_is_ssh_key" "ssh-key" {
  count      = var.use-existing-key ? 0 : 1
  name       = "${var.prefix}-${var.ssh-key-name}"
  public_key = file(var.ssh-pub-key-path)
}

locals {
  ssh-key = var.use-existing-key ? data.ibm_is_ssh_key.existing-ssh-key[0].id : ibm_is_ssh_key.ssh-key[0].id
}

data ibm_is_image "vm-image" {
  name = var.vm-image-name
}

data "ibm_resource_group" "default-resource-group" {
  is_default = true
}

##### Network #####
resource "ibm_is_vpc" "vpc" {
  name = "${var.prefix}-vpc"
}

resource "ibm_is_public_gateway" "public-gateway" {
  name = "${var.prefix}-gateway"
  vpc  = ibm_is_vpc.vpc.id
  zone = "us-south-1"
}

resource "ibm_is_subnet" "subnet" {
  name            = "${var.prefix}-subnet"
  vpc             = ibm_is_vpc.vpc.id
  zone            = "us-south-1"
  ip_version      = "ipv4"
  ipv4_cidr_block = var.subnet-ipv4-cidr-block
  public_gateway  = ibm_is_public_gateway.public-gateway.id
}

resource "ibm_is_security_group_rule" "secgroup-rule" {
  group     = ibm_is_vpc.vpc.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"
}

resource "ibm_is_floating_ip" "vsi-fip" {
  count = var.vsi-count
  name   = "${var.prefix}-vsi-fip-${count.index}"
  target = ibm_is_instance.vsi_instance[count.index].primary_network_interface.0.id
}

##### Compute #####
resource "ibm_is_instance" "vsi_instance" {
  count = var.vsi-count
  name    = "${var.prefix}-vsi-${count.index}"
  image   = data.ibm_is_image.vm-image.id
  profile = var.vm-profile-name

  primary_network_interface {
    name   = var.host-interface-name
    subnet = ibm_is_subnet.subnet.id
  }

  boot_volume {
    name = "${var.prefix}-vsi-boot-volume-${count.index}"
  }

  vpc  = ibm_is_vpc.vpc.id
  zone = "us-south-1"
  keys = [local.ssh-key]
}

##### Output #####
output "vsi-fip" {
  value       = ibm_is_floating_ip.vsi-fip.*.address
  description = "Floating IP addresses to access the deployer."
}
