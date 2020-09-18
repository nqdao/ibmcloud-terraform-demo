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
  ssh-private-key-path = replace(var.ssh-pub-key-path, ".pub", "")
}

##### Read-only Resources #####
data ibm_is_image "vm-image" {
  name = "ibm-ubuntu-18-04-1-minimal-amd64-1"
}

##### VPC #####
resource "ibm_is_vpc" "vpc" {
  name = "${var.prefix}-vpc"
}

resource "ibm_is_public_gateway" "public_gateway" {
  name = "${var.prefix}-gateway"
  vpc  = ibm_is_vpc.vpc.id
  zone = "us-south-1"
}

resource "ibm_is_subnet" "subnet" {
  name            = "${var.prefix}-subnet"
  vpc             = ibm_is_vpc.vpc.id
  zone            = "us-south-1"
  ip_version      = "ipv4"
  ipv4_cidr_block = "10.240.0.0/26"
  public_gateway  = ibm_is_public_gateway.public_gateway.id
}

resource "ibm_is_security_group_rule" "secgroup_rule" {
  group     = ibm_is_vpc.vpc.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"
}

resource "ibm_is_floating_ip" "vsi_fip" {
  count  = var.vsi_count
  name   = "${var.prefix}-vsi-fip-${count.index}"
  target = ibm_is_instance.vsi_instance[count.index].primary_network_interface[0].id
}

##### Compute #####
resource "ibm_is_instance" "vsi_instance" {
  count   = var.vsi_count
  name    = "${var.prefix}-vsi-${count.index}"
  image   = data.ibm_is_image.vm-image.id
  profile = "bx2-4x16"

  primary_network_interface {
    subnet = ibm_is_subnet.subnet.id
  }

  boot_volume {
    name = "${var.prefix}-vsi-boot-volume-${count.index}"
  }

  vpc  = ibm_is_vpc.vpc.id
  zone = "us-south-1"
  keys = [local.ssh-key]
}

##### Deploy #####
resource "local_file" "ansible-inventory-file" {
  content = templatefile("${path.module}/templates/ansible_hosts.tpl",
                        { private_key_file = local.ssh-private-key-path,
                          hosts = zipmap(ibm_is_instance.vsi_instance[*].name,ibm_is_floating_ip.vsi_fip[*].address)
                        })
  filename = "ansible/ansible_hosts"
}

resource "null_resource" "ansible-deploy" {
  depends_on = [local_file.ansible-inventory-file]
  triggers = {
    ansible_file_id = local_file.ansible-inventory-file.id
  }
  provisioner "local-exec" {
    when = create
    command = "ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i ansible/ansible_hosts ansible/nginx.yaml"
  }
}

##### Output #####
output "vsi-info" {
  value       = zipmap(ibm_is_instance.vsi_instance[*].name, ibm_is_floating_ip.vsi_fip[*].address)
  description = "VSI access information."
}
