# Fluid-Slurm-GCP : Complete System
Copyright 2020 Fluid Numerics LLC

This "Complete System" Terraform deployment creates
* Shared VPC Network with subnetworks for the controller+login and any regions where partitions are deployed.
* Firewall rules for open internal communication between compute instances in the fluid-slurm-gcp cluster and for access from the outside world via tcp:22 (ssh)
* Filestore instance for hosting /home
* (Optional) Filestore instance for hosting /mnt/share group storage directory
* Cloud SQL instance for hosting Slurm Database
* Service Accounts for login, controller, and compute nodes
* IAM policies on project (default) or parent folder (if `parent_folder` is specified) for system users, administrators, and service accounts. IAM policies use custom roles from Fluid Numerics.
* Controller and Login Nodes


## Getting Started

1. Set the `cluster_name` to the desired name. This name will prefix the login and controller node names in addition to the Filestore instances, Cloud SQL instance, Network and Subnetworks, and Firewall Rules.
2. Set the `controller_machine_type` and `login_machine_type` to set the size of the Controller and Login nodes respectively.
3. Set the `slurm_gcp_admins` to the Cloud Identity user and/or group email addresses for users you want to grant root access on the cluster 
4. Set the `slurm_gcp_users` to the Cloud Identity user and/or group email addresses for users you want to have standard non-root ssh access to the cluster.
5. Set the `primary_project` to the GCP Project ID where the VPC network & subnetworks, firewall rules, filestore instances, Cloud SQL instance, and controller & login nodes will be deployed.
6. Set the `primary_zone` to the GCP Zone where the filestore instances, Cloud SQL and controller & login nodes will be deployed.


By default, these settings will use the CentOS-7 v2.4.0 Fluid-Slurm-GCP images for your cluster with a single basic partition in the `primary_zone`. 

### Changing Image Flavors
You can change the image flavor by setting image flavor, e.g.,
```
image_flavor = ubuntu // Ubuntu 19.10
image_flavor = ohpc   // CentOS-7 + OpenHPC Packages
```

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
