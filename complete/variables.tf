variable "parent_folder" {
  type = string
  default = ""
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

variable "image_version" {
  type = string
  description = "Image version for the fluid-slurm-gcp images"
  default = "v2-4-0"
}

variable "image_flavor" {
  type = string
  description = "Base Fluid-Slurm-GCP image flavor. One of `centos`, `ohpc`, or `ubuntu`"
  default = "centos"
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
