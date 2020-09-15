# Fluid-Slurm-GCP : Complete System
Copyright 2020 Fluid Numerics LLC

This "Complete System" Terraform deployment creates
* Shared VPC Network with subnetworks for the controller+login and any regions where partitions are deployed.
* Firewall rules for open internal communication between compute instances in the fluid-slurm-gcp cluster and for access from the outside world via tcp:22 (ssh)
* Filestore instance for hosting /home
* (Optional) Filestore instance for hosting /mnt/share group storage directory
* Cloud SQL instance for hosting Slurm Database
* Service Accounts for login, controller, and compute nodes
* IAM policies on a parent folder for system users, administrators, and service accounts (see the [fluid-slurm-gcp module](../../modules/fluid-slurm-gcp/main.tf) for details).
* Controller and Login Nodes



## Getting Started

### Prerequisites
Before using this example, you need
1. A GCP Folder that contains a single GCP Project. See https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy for more details
2. A service account that has `Project Editor` and `Folder IAM Admin` roles applied at the GCP Folder level.
3. Credentials on your local system for the service account. Be sure to set `export GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials.json` on your local system

### How-to
1. Set the `cluster_name` to the desired name. This name will prefix the login and controller node names in addition to the Filestore instances, Cloud SQL instance, Network and Subnetworks, and Firewall Rules.
2. Set the `controller_machine_type` and `login_machine_type` to set the size of the Controller and Login nodes respectively.
3. Set the `slurm_gcp_admins` to the Cloud Identity user and/or group email addresses for users you want to grant root access on the cluster 
4. Set the `slurm_gcp_users` to the Cloud Identity user and/or group email addresses for users you want to have standard non-root ssh access to the cluster.
5. Set the `primary_project` to the GCP Project ID where the VPC network & subnetworks, firewall rules, filestore instances, Cloud SQL instance, and controller & login nodes will be deployed.
6. Set the `primary_zone` to the GCP Zone where the filestore instances, Cloud SQL and controller & login nodes will be deployed.


By default, these settings will use the CentOS-7 v2.4.0 Fluid-Slurm-GCP images for your cluster with a single basic partition in the `primary_zone`. 

### Changing Image Flavors
If you want to change the default images used to launch the cluster, you can set the following variables
```
controller_image = "projects/fluid-cluster-ops/global/images/fluid-slurm-gcp-controller-centos-v2-5-0"
compute_image = "projects/fluid-cluster-ops/global/images/fluid-slurm-gcp-compute-centos-v2-5-0"
login_image = "projects/fluid-cluster-ops/global/images/fluid-slurm-gcp-login-centos-v2-5-0"
```

For example, you can use our Ubuntu based images
```
controller_image = "projects/fluid-cluster-ops/global/images/fluid-slurm-gcp-controller-ubuntu-v2-5-0"
compute_image = "projects/fluid-cluster-ops/global/images/fluid-slurm-gcp-compute-ubuntu-v2-5-0"
login_image = "projects/fluid-cluster-ops/global/images/fluid-slurm-gcp-login-ubuntu-v2-5-0"
```

Or the CentOS-7 + OpenHPC images
```
controller_image = "projects/fluid-cluster-ops/global/images/fluid-slurm-gcp-controller-ohpc-v2-5-0"
compute_image = "projects/fluid-cluster-ops/global/images/fluid-slurm-gcp-compute-ohpc-v2-5-0"
login_image = "projects/fluid-cluster-ops/global/images/fluid-slurm-gcp-login-ohpc-v2-5-0"
```

Note that you can also use [Packer](https://packer.io) to build on top of these images to retain full functionality of the fluid-slurm-gcp deployment while also including your personal/company applications in the images. Additionally, each `partitions[].machines[]` block can specify a unique compute node image. This is helpful for teams that are building application pipelines that can be distributed across Slurm partitions. 

Note that the `projects/fluid-cluster-ops/global/images/fluid-slurm-gcp-*` images incur a $0.01 USD/vCPU/hour and $0.09 USD/GPU/hour usage fee to help Fluid Numerics support the [Marketplace solutions](https://console.cloud.google.com/marketplace/details/fluid-cluster-ops/fluid-slurm-gcp?utm_source=github&utm_medium=link&utm_campaign=v240&utm_content=terraform), this repository, and other community driven activities. [See our pricing examples documentation for more details](https://help.fluidnumerics.com/slurm-gcp/pricing)
Additionally, use of these images is subject to the [End-User-License Agreement for the fluid-slurm-gcp images](https://help.fluidnumerics.com/slurm-gcp/eula)

### Configuring Partitions
1. Set the `partitions` list-object
2. Terraform plan then apply
3. Log in to your controller instance
4. Run
```
sudo su -
cluster-services update config
cluster-services update all
```

### Adding Slurm Accounts
1. Set the `slurm_accounts` list-object
2. Terraform plan then apply
3. Log in to your controller instance
4. Run
```
sudo su -
cluster-services update config
cluster-services update all
```
