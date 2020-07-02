// Configure the Google Cloud provider
provider "google" {
 version = "3.9"
}

provider "google-beta" {
}

// Enable necessary APIs
resource "google_project_service" "compute" {
  project = var.primary_project
  service = "compute.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "monitoring" {
  project = var.primary_project
  service = "monitoring.googleapis.com"
  disable_dependent_services = true
}

locals {
  primary_region = trimsuffix(var.primary_zone,substr(var.primary_zone,-2,-2))
  slurm_gcp_admins = ["group:${var.cluster_name}-slurm-gcp-admins@${var.managing_domain}"]
  slurm_gcp_users = ["group:${var.cluster_name}-slurm-gcp-users@${var.managing_domain}"]
  cluster_name = "${var.cluster_name}-slurm"
}


// *************************************************** //
locals {
  controller = {
    machine_type = var.controller_machine_type
    disk_size_gb = 15
    disk_type = "pd-standard"
    labels = {"slurm-gcp"="controller"}
    project = var.primary_project
    region = local.primary_region
    vpc_subnet = var.vpc_subnet
    zone = var.primary_zone
  }
  login = [{
    machine_type = var.login_machine_type
    disk_size_gb = 15
    disk_type = "pd-standard"
    labels = {"slurm-gcp"="login"}
    project = var.primary_project
    region = local.primary_region
    vpc_subnet = var.vpc_subnet
    zone = var.primary_zone
  }]

  default_partition = [{name = "basic"
                        project = var.primary_project
                        max_time = "8:00:00"
                        labels = {"slurm-gcp"="compute"}
                        machines = [{ name = "basic"
                                      disk_size_gb = 15
                                      disk_type = "pd-standard"
                                      disable_hyperthreading = false
                                      external_ip = false
                                      gpu_count = 0
                                      gpu_type = ""
                                      n_local_ssds = 0
                                      image = var.compute_image
                                      local_ssd_mount_directory = "/scratch"
                                      machine_type = "n1-standard-16"
                                      max_node_count = 5
                                      preemptible_bursting = false
                                      static_node_count = 0
                                      vpc_subnet = var.vpc_subnet
                                      zone = var.primary_zone
                                   }]
                        }]

  partitions = length(var.partitions) != 0 ? var.partitions : local.default_partition
  
}

// Create the Slurm-GCP cluster
module "slurm_gcp" {
  source  = "../../modules/fluid-slurm-gcp"
  controller_image = var.controller_image
  compute_image = var.compute_image
  login_image = var.login_image
  parent_folder = var.parent_folder
  slurm_gcp_admins = var.slurm_gcp_admins
  slurm_gcp_users = var.slurm_gcp_users
  name = var.cluster_name
  tags = [var.cluster_name]
  controller = local.controller
  login = local.login
  partitions = local.partitions
  slurm_accounts = var.slurm_accounts
}


