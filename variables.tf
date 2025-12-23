#variable "ibmcloud_api_key" {}

variable "ibmcloud_region" {
  description = "Preferred IBM Cloud region to use for your infrastructure"
  default = "us-south"
}

variable "ssh_key_name" {
  default = ""
  description = "Name of existing VPC SSH Key"
}

variable "iam_api_key" {
  default = ""
  description = "API Key to use for scripts and storage"
}

variable "satellite_resource_group" {
  default = ""
  description = "Define the resource group for the Coordinator"
}

#### VPC ####
variable "vpc_name" {
  default = "demo"
  description = "Name of your VPC"
}

### VPC NETWORK ###
variable "zone1_cidr" {
  default = "10.240.1.0/24"
  description = "CIDR block to be used for zone 1"
}

### VPC INSTANCES ###
variable "controlplane_count" {
  default = "3"
  description = "Number of hosts to build for Control Plane"
}

variable "worker_count" {
  default = "3"
  description = "Number of hosts to build for Red Hat OpenShift"
}

variable "storage_count" {
  default = "3"
  description = "Number of hosts to build for Storage ODF/PX"
}

variable "storage_cluster_pool_count" {
  default = "1"
  description = "Number of ODF/PX workers in pool. *PER ZONE!"
}
 
variable "image" {
  default = "r006-901f5e3c-13f7-48bf-8a8f-13101af22bea" #us-south
  description = "OS Image ID to be used for virtual instances (RHEL 9 default)"
}

variable "controlplane_profile" {
  default = "bx2-8x32"
  description = "Instance profile to be used for hosts"
}

variable "worker_profile" {
  default = "bx2-8x32"
  description = "Instance profile to be used for hosts"
}

variable "storage_profile" {
  default = "bx2d-16x64" #"bx2d-16x64" 600gb bx2d-8x32 300gb
  description = "Instance profile to be used for ODF/PX hosts"
}

variable "location_name" {
  default = "demo"
}

variable "coreos_enabled" {
  default = "true"
}

variable "operating_system" {
  default = "REDHAT_9_64"
}


variable "location_zones" {
  type = list(string)
  default = ["us-south-1","us-south-2","us-south-3"]
}

variable "location_managed_from" {
  default = "dal"
}

variable "cluster_name" {
  default = "demo"
}

variable "kube_version" {
  default = "4.18_openshift"
}
