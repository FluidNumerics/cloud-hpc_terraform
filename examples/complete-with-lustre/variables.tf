variable "parent_folder" {
  type = string
  description = "A GCP folder id (folders/FOLDER-ID) that contains the Fluid-Slurm-GCP controller project and compute partition projects. This folder setting is useful for multi-project deployments."
}

variable "cluster_name" {
  type = string
  description = "Customer organization ID from the managed-fluid-slurm-gcp customers database"
}

variable "subnet_cidr" {
  type = string
  description = "CIDR Range for controller/login VPC Subnet."
  default = "10.10.0.0/16"
}

variable "cloud_sql_tier" {
  type = string
  description = "Instance tier for the Cloud SQL instance that hosts the Slurm database"
  default = "db-f1-micro"
}

variable "home_tier" {
  type = string
  description = "Filestore Tier for the home NFS server. Either STANDARD or PREMIUM"
  default = "STANDARD"
}

variable "home_size_gb" {
  type = number
  description = "Size of the filestore home disk in GB. Minimum : 1024 for STANDARD and 2048 for PREMIUM."
  default = 1024
}

variable "slurm_gcp_admins" {
  type = list(string)
  description = "A list of users that will serve as Linux System Administrators on your cluster. Set each element to 'user:someone@example.com' for users or 'group:somegroup@example.com' for groups"
}

variable "slurm_gcp_users" {
  type = list(string)
  description = "A list of users that will serve as Linux System Administrators on your cluster. Set each element to 'user:someone@example.com' for users or 'group:somegroup@example.com' for groups"
}

variable "share_tier" {
  type = string
  description = "Filestore Tier for the share NFS server. Either STANDARD or PREMIUM"
  default = "STANDARD"
}

variable "share_size_gb" {
  type = number
  description = "Size of the filestore share disk in GB. Minimum : 1024 for STANDARD and 2048 for PREMIUM. Set to 0 to disable the share filestore instance"
  default = 0
}
variable "managing_domain" {
  type = string
  description = "The registered GSuite domain used to host Fluid-Slurm-GCP Cloud Identity Accounts"
  default = "fluidnumerics.com"
}

variable "controller_image" {
  type = string
  description = "Image to use for the fluid-slurm-gcp controller"
  default = "projects/fluid-cluster-ops/global/images/fluid-slurm-gcp-controller-centos-v2-4-0"
}

variable "compute_image" {
  type = string
  description = "Image to use for the fluid-slurm-gcp compute instances (all partitions[].machines[])."
  default = "projects/fluid-cluster-ops/global/images/fluid-slurm-gcp-compute-centos-v2-4-0"
}

variable "login_image" {
  type = string
  description = "Image to use for the fluid-slurm-gcp login node"
  default = "projects/fluid-cluster-ops/global/images/fluid-slurm-gcp-login-centos-v2-4-0"
}

variable "primary_project" {
  type = string
  description = "Main GCP project ID for the customer's managed solution"
}

variable "primary_zone" {
  type = string
  description = "Main GCP zone for the customer's managed solution"
}

variable "whitelist_ssh_ips" {
  type = list(string)
  description = "IP addresses that should be added to a whitelist for ssh access"
  default = ["0.0.0.0/0"]
}

variable "controller_machine_type" { 
  type = string
  description = "GCP Machine type to use for the login node."
}

variable "default_partition" {
  type = string
  description = "Name of the default compute partition."
  default = ""
}

variable "login_machine_type" {
  type = string
  description = "GCP Machine type to use for the login node."
}

variable "partitions" {
  type = list(object({
      name = string
      project = string
      max_time= string
      labels = map(string)
      machines = list(object({
        name = string
        disk_size_gb = number
        disk_type = string
        disable_hyperthreading= bool
        external_ip = bool
        gpu_count = number
        gpu_type = string
        image = string
        n_local_ssds = number
        local_ssd_mount_directory = string
        machine_type=string
        max_node_count= number
        preemptible_bursting= bool
        static_node_count= number
        vpc_subnet = string
        zone= string
      }))
  }))
  description = "Settings for partitions and compute instances available to the cluster."
  
  default = []
}

variable "slurm_accounts" {
  type = list(object({
      name = string
      users = list(string)
      allowed_partitions = list(string)
  }))
  default = []
}

variable "munge_key" {
  type = string
  default = ""
}

variable "suspend_time" {
  type = number
  default = 300
}

variable "lustre_version" {
  type = string
  default = "latest-release"
}

variable "e2fs_version" {
  type = string
  default = "latest"
}

variable "mds_node_count" {
  type = number
  default = 1
  description = "Number of MDS node instances to run."
}

variable "mds_machine_type" {
  type = string
  default = "n1-standard-32"
  description = "Machine type to use for MDS node instances, eg. n1-standard-4.."
}

variable "mds_boot_disk_type" {
  type = string
  default = "pd-standard"
  description = "Disk type (pd-ssd or pd-standard) for MDT boot disk."
}

variable "mds_boot_disk_size_gb" {
  type = number
  default = 20
  description = "Size of disk for the MDS boot disk (in GB)."
}

variable "mdt_disk_type" {
  type = string
  default = "pd-ssd"
  description = "Disk type (pd-ssd or pd-standard) for MDT disks."
}

variable "mdt_disk_size_gb" {
  type = number
  default = 100
  description = "Size of disk for the MDT disks (in GB)."
}

variable "oss_node_count" {
  type = number
  default = 4
  description = "Number of OSS node instances to run."
}

variable "oss_machine_type" {
  type = string
  default = "n1-standard-16"
  description = "GCP Machine type for the object storage server nodes."
}

variable "oss_boot_disk_type" {
  type = string
  default = "pd-standard"
  description = "Disk type (pd-ssd or pd-standard) for OSS boot disk."
}

variable "oss_boot_disk_size_gb" {
  type = number
  default = 20
  description = "Size of the OSS boot disk (in GB)"
}

variable "ost_disk_type" {
  type = string
  default = "pd-ssd"
  description = "Disk type (pd-ssd or pd-standard) for OST disks."
}

variable "ost_disk_size_gb" {
  type = number
  default = 100
  description = "Size of disk for the OST disks (in GB)."
}

variable "hsm_node_count" {
  type = number
  default = 0
  description = "Number of Lustre HSM Data Movers node instances to run."
}

variable "hsm_machine_type" {
  type = string
  default = "n1-standard-8"
  description = "Machine type to use for Lustre HSM Data Movers node instances, eg. n1-standard-4."
}

variable "hsm_gcs_bucket" {
  type = string
  default = ""
  description = "Google Cloud Storage bucket to archive to."
}

variable "hsm_gcs_prefix" {
  type = string
  default = ""
  description = "Google Cloud Storage bucket path to import data from to Lustre."
}
