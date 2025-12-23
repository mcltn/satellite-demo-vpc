
##################################
##################################

data "ibm_resource_group" "satellite" {
  name = var.satellite_resource_group
}

data "ibm_is_ssh_key" "sshkey" {
  name = var.ssh_key_name
}

locals {
  ZONE1 = "${var.ibmcloud_region}-1"
  #ZONE2 = "${var.ibmcloud_region}-1"
  #ZONE3 = "${var.ibmcloud_region}-1"
  PROJECT = "${random_string.project.result}"
}

resource "random_string" "project" {
  length    = 8
  numeric   = true
  special   = false
  upper     = false
}

resource "ibm_iam_api_key" "iam_api_key" {
  name = "sat-key-${local.PROJECT}"
}

resource "ibm_is_instance" "controlplane" {
  count = var.controlplane_count
  name    = "controlplane-${local.PROJECT}${count.index+1}"
  resource_group  = data.ibm_resource_group.satellite.id
  vpc  = ibm_is_vpc.sat-vpc.id
  zone = local.ZONE1

  image   = var.image
  profile = var.controlplane_profile

  primary_network_interface {
    subnet = ibm_is_subnet.sn1.id
  }
  keys = [data.ibm_is_ssh_key.sshkey.id]
  user_data = data.ibm_satellite_attach_host_script.script-controlplane.host_script
}

resource "ibm_is_instance" "worker" {
  count = var.worker_count
  name    = "worker-${local.PROJECT}${count.index+1}"
  resource_group  = data.ibm_resource_group.satellite.id
  vpc  = ibm_is_vpc.sat-vpc.id
  zone = local.ZONE1

  image   = var.image
  profile = var.worker_profile

  primary_network_interface {
    subnet = ibm_is_subnet.sn1.id
  }
  keys = [data.ibm_is_ssh_key.sshkey.id]
  user_data = data.ibm_satellite_attach_host_script.script-worker.host_script
}

resource "ibm_is_instance" "storage" {
  count = var.storage_count
  name    = "storage-${local.PROJECT}${count.index+1}"
  resource_group  = data.ibm_resource_group.satellite.id
  vpc  = ibm_is_vpc.sat-vpc.id
  zone = local.ZONE1

  image   = var.image
  profile = var.storage_profile

  primary_network_interface {
    subnet = ibm_is_subnet.sn1.id
  }
  volumes = [ibm_is_volume.storage-mon-volume[count.index].id,ibm_is_volume.storage-osd-volume[count.index].id]
  keys = [data.ibm_is_ssh_key.sshkey.id]
  user_data = data.ibm_satellite_attach_host_script.script-storage.host_script
}

resource "ibm_is_volume" "storage-mon-volume" {
  count = var.storage_count
  name = "storagemon-${local.PROJECT}${count.index+1}"
  profile = "10iops-tier"
  capacity = 20
  resource_group  = data.ibm_resource_group.satellite.id
  zone = local.ZONE1
}

resource "ibm_is_volume" "storage-osd-volume" {
  count = var.storage_count
  name = "storageosd-${local.PROJECT}${count.index+1}"
  profile = "10iops-tier"
  capacity = 200
  resource_group  = data.ibm_resource_group.satellite.id
  zone = local.ZONE1
}

resource "ibm_is_floating_ip" "fip-controlplane" {
  count = "${var.controlplane_count}"
  name = "controlplane-${local.PROJECT}${count.index}"
  resource_group  = data.ibm_resource_group.satellite.id
  target = "${element(ibm_is_instance.controlplane.*.primary_network_interface.0.id, count.index)}"
}

resource "ibm_is_floating_ip" "fip-worker" {
  count = "${var.worker_count}"
  name = "worker-${local.PROJECT}${count.index}"
  resource_group  = data.ibm_resource_group.satellite.id
  target = "${element(ibm_is_instance.worker.*.primary_network_interface.0.id, count.index)}"
}

resource "ibm_is_floating_ip" "fip-storage" {
  count = "${var.storage_count}"
  name = "storage-${local.PROJECT}${count.index}"
  resource_group  = data.ibm_resource_group.satellite.id
  target = "${element(ibm_is_instance.storage.*.primary_network_interface.0.id, count.index)}"
}

resource "terraform_data" "makepublic" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/makepublic.sh"
    environment = {
      APIKEY =  "${var.iam_api_key}" #ibm_iam_api_key.iam_api_key.apikey
      REGION = "${var.ibmcloud_region}"
      RESOURCEGROUP = "${var.satellite_resource_group}"
      LOCATION = "${var.location_name}-${local.PROJECT}"
      CLUSTER = "${var.cluster_name}-${local.PROJECT}"
      PROJECT = "${local.PROJECT}"
    }
  }
  depends_on = [ ibm_satellite_cluster.democluster ]
}


output "controlplane" {
    #value = ibm_is_instance.controlplane.*.primary_network_interface.0.primary_ipv4_address
    value = "${ibm_is_floating_ip.fip-controlplane.*.address}"
}
output "worker" {
    #value = ibm_is_instance.worker.*.primary_network_interface.0.primary_ipv4_address
    value = "${ibm_is_floating_ip.fip-worker.*.address}"
}
output "storage" {
    #value = ibm_is_instance.worker.*.primary_network_interface.0.primary_ipv4_address
    value = "${ibm_is_floating_ip.fip-storage.*.address}"
}
output "project" {
    #value = ibm_is_instance.worker.*.primary_network_interface.0.primary_ipv4_address
    value = "${local.PROJECT}"
}
