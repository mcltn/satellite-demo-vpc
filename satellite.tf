resource "ibm_satellite_location" "location" {
  location          = "${local.PREFIX}-${var.location_name}-${local.PROJECT}"
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
  name                    = "${local.PREFIX}-${var.cluster_name}-${local.PROJECT}"
  location                = ibm_satellite_location.location.location
  enable_config_admin     = true
  kube_version            = var.kube_version
  resource_group_id       = data.ibm_resource_group.satellite.id
  wait_for_worker_update  = true
  worker_count            = 1
  host_labels             = ["host:worker"]
  depends_on      = [ibm_satellite_host.controlplane, ibm_is_instance.controlplane, ibm_is_instance.worker]
  dynamic "zones" {
    for_each = var.location_zones
    content {
      id = zones.value
    }
  }
}

#resource "ibm_satellite_cluster_worker_pool" "storage-pool" {
#    name               = "storage-pool"
#    cluster            = ibm_satellite_cluster.democluster.id
#    worker_count       = var.storage_cluster_pool_count
#    resource_group_id  = data.ibm_resource_group.satellite.id
#    host_labels        = ["host:storage"]
#    dynamic "zones" {
#        for_each = var.location_zones
#        content {
#              id  = zones.value
#        }
#      }
#}

# resource "ibm_satellite_storage_configuration" "storage-configuration" {
#     location = ibm_satellite_location.location.location
#     config_name = "storage-config-${local.PROJECT}"
#     storage_template_name = "storage-local"
#     storage_template_version = "4.12"
#     user_config_parameters = {
#         auto-discover-devices = "true"
#         osd-device-path = ""
#         num-of-osd = "1"
#         worker-nodes = "" #"${join(", ", [for i in ibm_is_instance.storage : i.name])}"
#         storage-upgrade = "false"
#         billing-type = "advanced"
#         ibm-cos-endpoint = ""
#         ibm-cos-location = ""
#         ibm-cos-access-key = ""
#         ibm-cos-secret-key = ""
#         cluster-encryption = ""
#         perform-cleanup = "false"
#         kms-encryption = "false"
#         kms-instance-name = ""
#         kms-instance-id = ""
#         kms-api-key = ""
#         ignore-noobaa = "false"
#     }
#     user_secret_parameters = {
#         iam-api-key = "${var.iam_api_key}"
#     }
# }

#resource "ibm_satellite_storage_assignment" "storage-assignment" {
#    assignment_name = "storage-assignment"
#    cluster = ibm_satellite_cluster.democluster.id
#    config = "storage-config-${var.project_name}"
#    controller = ibm_satellite_location.location.location
#}
