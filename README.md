# Automated creation of a simulated Satellite Location on IBM Cloud VPC

This repo is used to deploy virtual instances into an IBM Cloud VPC environment to simulate a Satellite location. The virtual instances will be assigned roles of control plane, workers and ODF storage. 

This will create the VPC in a specified region and resource group. A single subnet will be created and security group rules will be applied. All virtual instances will be provisioned into this VPC and single subnet. It will then deploy a Satellite location service and attach all of the instances to the location by downloading and executing the attach script, applying labels to their roles. Control Plane instances will then be assigned. The other instances will be used for deploying a Red Hat OpenShift cluster with a default worker pool, and an additional worker pool for ODF. All instances will be provided a public floating IP address.

### Make the cluster publically accessible
Once the cluster has completed provisioning, a script will be run ("makepublic.sh") that will make the cluster publically accessible. 


> * Current issue
>The Satellite Storage Configuration automation currently has an issue, and should be done manually until this repo is updated. This can be done by selecting Storage in the menu of your location and creating a new Storage Configuration. You will select "OpenShift Data Foundation for local devices" as your storage type and then can create an assignment to this cluster.


## Terraform Variables

ibmcloud_region = Cloud region to use as the VPC location

ssh_key_name = Name of an existing VPC SSH Key in the account

iam_api_key = API Key to use for ODF

satellite_resource_group = Existing resource group to depoly infrastructure to

vpc_name = Name of the VPC to create

zone1_cidr = CIDR block to assign to subnet in zone 1

controlplane_count - number of control plane hosts to deploy into control plane in location

worker_count - number of worker hosts to deploy into location

odf_count - number of worker hosts for ODF to deploy into location * THIS IS PER ZONE

image = Image code to use for the OS on the control and worker hosts (Default is RHEL 8)

controlplane_profile = CPU and Memory profile to use for control plane hosts

worker_profile = CPU and Memory profile to use for worker hosts

odf_profile = CPU and Memory profile to use for ODF hosts

location_name = Name for the Location, will append each location number

location_zones = Zones to be created in each of the locations

location_managed_from = Datacenter code for the Satellite service to be managed from

cluster_name = Name for the ROKS cluster

kube_version = Version of ROKS to install



https://github.com/IBM-Cloud/terraform-provider-ibm

https://registry.terraform.io/providers/IBM-Cloud/ibm/latest

https://cloud.ibm.com/docs/ibm-cloud-provider-for-terraform?topic=ibm-cloud-provider-for-terraform-resources-datasource-list


