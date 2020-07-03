
variable "lustre_version" {
  type = string
  default = "latest-release"
}

variable "e2fs_version" {
  type = string
  default = "latest"
}

variable "project" {
  type = string
  description = "GCP Project ID"
}

variable "zone" {
  type = string
  description = "GCP Zone to deploy Lustre Cluster"
}

variable "vpc_subnet" {
  type = string
  description = "VPC Subnetwork to host Lustre Cluster"
}

variable "service_account" {
  type = string
  description = "Service account to align with Lustre Cluster GCE instances"
  default = "default"
}

variable "network_tags" {
  type = list(string)
  description = "Network tags"
  default = ["lustre"]
}

variable "cluster_name" {
  type = string
  default = "lustre"
  description = "Name of the Lustre cluster. This name prefixes all compute instances that are created"
}

variable "fs_name" {
  type = string
  default = "lustre"
  description = "Name of the Lustre filesystem. This name determines the server directory path for mounting"
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
