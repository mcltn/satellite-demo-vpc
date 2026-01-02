resource "ibm_satellite_location" "location" {
  location          = "${var.location_name}-${local.PROJECT}"
  zones             = var.location_zones
  managed_from      = var.location_managed_from
  coreos_enabled    = var.coreos_enabled
  resource_group_id = data.ibm_resource_group.satellite.id
}

data "ibm_satellite_attach_host_script" "script-controlplane" {
  location          = ibm_satellite_location.location.location
  labels            = ["host:controlplane"]
  depends_on      = [ibm_satellite_location.location]
  custom_script = <<EOF
subscription-manager refresh
subscription-manager release --set=9
subscription-manager repos --enable rhel-9-for-x86_64-baseos-rpms 
subscription-manager repos --enable rhel-9-for-x86_64-appstream-rpms
subscription-manager repos --disable='*eus*'
yum install container-selinux -y
EOF
}

data "ibm_satellite_attach_host_script" "script-worker" {
  location          = ibm_satellite_location.location.location
  labels            = ["host:worker"]
  depends_on      = [ibm_satellite_location.location]
  custom_script = <<EOF
subscription-manager refresh
subscription-manager release --set=9
subscription-manager repos --enable rhel-9-for-x86_64-baseos-rpms 
subscription-manager repos --enable rhel-9-for-x86_64-appstream-rpms
subscription-manager repos --disable='*eus*'
yum install container-selinux -y
EOF
}

data "ibm_satellite_attach_host_script" "script-storage" {
  location          = ibm_satellite_location.location.location
  labels            = ["host:storage"]
  depends_on      = [ibm_satellite_location.location]
  custom_script = <<EOF
subscription-manager refresh
subscription-manager release --set=9
subscription-manager repos --enable rhel-9-for-x86_64-baseos-rpms 
subscription-manager repos --enable rhel-9-for-x86_64-appstream-rpms
subscription-manager repos --disable='*eus*'
yum install container-selinux -y
EOF
}

resource "ibm_satellite_host" "controlplane" {
  count             = var.controlplane_count
  location          = ibm_satellite_location.location.location
  host_id           = element(ibm_is_instance.controlplane.*.name, count.index)
  labels            = ["host:controlplane"]
  zone              = element(var.location_zones, count.index)
  host_provider     = "ibm"
  depends_on      = [ibm_satellite_location.location, ibm_is_instance.controlplane]
}

resource "ibm_satellite_cluster" "democluster" {
  count                   = var.create_cluster ? 1 : 0  # Create 1 if true, else 0
  name                    = "${var.cluster_name}-${local.PROJECT}"
  location                = ibm_satellite_location.location.location
  enable_config_admin     = true
  kube_version            = var.kube_version
  resource_group_id       = data.ibm_resource_group.satellite.id
  wait_for_worker_update  = true
  worker_count            = 1
  host_labels             = ["host:worker"]
  operating_system        = var.location_operating_system
  depends_on      = [ibm_satellite_host.controlplane, ibm_is_instance.controlplane, ibm_is_instance.worker]
  dynamic "zones" {
    for_each = var.location_zones
    content {
      id = zones.value
    }
  }
}
