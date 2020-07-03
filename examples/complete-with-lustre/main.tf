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

resource "google_project_service" "filestore" {
  project = var.primary_project
  service = "file.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "service_networking" {
  project = var.primary_project
  service = "servicenetworking.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "sql_admin" {
  project = var.primary_project
  service = "sqladmin.googleapis.com"
  disable_dependent_services = true
}

locals {
  primary_region = trimsuffix(var.primary_zone,substr(var.primary_zone,-2,-2))
  slurm_gcp_admins = ["group:${var.cluster_name}-slurm-gcp-admins@${var.managing_domain}"]
  slurm_gcp_users = ["group:${var.cluster_name}-slurm-gcp-users@${var.managing_domain}"]
  cluster_name = "${var.cluster_name}-slurm"
}

// Mark the Controller project as the Shared VPC Host Project
resource "google_compute_shared_vpc_host_project" "host" {
  project = var.primary_project
}

// Obtain a unique list of projects from the partitions, excluding the host project
locals {
  projects = distinct([for p in var.partitions : p.project if p.project != var.primary_project])
}

// Mark the Shared VPC Service Projects
resource "google_compute_shared_vpc_service_project" "service" {
  count = length(local.projects)
  host_project = var.primary_project
  service_project = local.projects[count.index]
  depends_on = [google_compute_shared_vpc_host_project.host]
}

// Create the Shared VPC Network
resource "google_compute_network" "shared_vpc_network" {
  name = "${local.cluster_name}-shared-network"
  project = var.primary_project
  auto_create_subnetworks = false
  depends_on = [google_compute_shared_vpc_host_project.host]
}

resource "google_compute_subnetwork" "default_subnet" {
  name = "${local.cluster_name}-controller-subnet"
  description = "Primary subnet for the controller"
  ip_cidr_range = var.subnet_cidr
  region = local.primary_region
  network = google_compute_network.shared_vpc_network.self_link
  project = var.primary_project
}

resource "google_compute_firewall" "default_internal_firewall_rules" {
  name = "${local.cluster_name}-all-internal"
  network = google_compute_network.shared_vpc_network.self_link
  source_tags = [local.cluster_name]
  target_tags = [local.cluster_name]
  project = var.primary_project

  allow {
    protocol = "tcp"
    ports = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports = ["0-65535"]
  }
  allow {
    protocol = "icmp"
    ports = []
  }
}

resource "google_compute_firewall" "default_ssh_firewall_rules" {
  name = "${local.cluster_name}-ssh"
  network = google_compute_network.shared_vpc_network.self_link
  target_tags = [local.cluster_name]
  source_ranges = var.whitelist_ssh_ips
  project = var.primary_project

  allow {
    protocol = "tcp"
    ports = ["22"]
  }
}

// Create a list of unique regions from the partitions
locals {
  regions = distinct(flatten([for p in var.partitions : [for m in p.machines : trimsuffix(m.zone,substr(m.zone,-2,-2))]]))
  flatRegions = flatten([for p in var.partitions : [for m in p.machines : trimsuffix(m.zone,substr(m.zone,-2,-2))]])
  flatZones = flatten([for p in var.partitions : [for m in p.machines : m.zone]])
  regionToZone = zipmap(local.flatRegions,local.flatZones)
}

// Create any additional shared VPC subnetworks
resource "google_compute_subnetwork" "shared_vpc_subnetworks" {
  count = length(local.regions)
  name = "${local.cluster_name}-${local.regions[count.index]}"
  ip_cidr_range = cidrsubnet(var.subnet_cidr, 4, count.index+1) 
  region = local.regions[count.index]
  network = google_compute_network.shared_vpc_network.self_link
}

// Create a map that takes in zone and returns subnet (for partition creation)
locals {
  zoneToSubnet = {for s in google_compute_subnetwork.shared_vpc_subnetworks : local.regionToZone[s.region] => s.self_link}
}

// Create the Lustre Filesystem
module "lustre" {
  source = "../../modules/lustre"
  project = var.primary_project
  vpc_subnet = google_compute_subnetwork.default_subnet.self_link
  zone = var.primary_zone
  cluster_name = "${local.cluster_name}-lustre"
  mds_node_count = var.mds_node_count
  mds_machine_type = var.mds_machine_type
  mds_boot_disk_type = var.mds_boot_disk_type
  mds_boot_disk_size_gb = var.mds_boot_disk_size_gb
  mdt_disk_type = var.mdt_disk_type
  mdt_disk_size_gb = var.mdt_disk_size_gb
  oss_node_count = var.oss_node_count
  oss_machine_type = var.oss_machine_type
  oss_boot_disk_type = var.oss_boot_disk_type
  oss_boot_disk_size_gb = var.oss_boot_disk_size_gb
  ost_disk_type = var.ost_disk_type
  ost_disk_size_gb = var.ost_disk_size_gb
}

// Create the home filestore instance
resource "google_filestore_instance" "home_server" {
  name = "${local.cluster_name}-home-fs"
  zone = var.primary_zone
  tier = var.home_tier
  project = var.primary_project

  file_shares {
    capacity_gb = var.home_size_gb
    name        = "home"
  }

  networks {
    network = google_compute_network.shared_vpc_network.name
    modes   = ["MODE_IPV4"]
  }
  depends_on = [google_project_service.filestore]
}

// Create the share filestore instance 
resource "google_filestore_instance" "share_server" {
  count = var.share_size_gb == 0 ? 0 : 1
  name = "${local.cluster_name}-share-fs"
  zone = var.primary_zone
  tier = var.share_tier
  project = var.primary_project

  file_shares {
    capacity_gb = var.share_size_gb
    name        = "share"
  }

  networks {
    network = google_compute_network.shared_vpc_network.name
    modes   = ["MODE_IPV4"]
  }
  depends_on = [google_project_service.filestore]
}

locals {
  lustre_mount = {group = "root",
                  mount_directory = "/mnt/lustre",
                  mount_options = "defaults,_netdev",
                  owner = "root",
                  protocol = "lustre",
                  permission = "755",
                  server_directory = "${module.lustre.cluster_name}:/${module.lustre.fs_name}"}
  home_mount = {group = "root",
                mount_directory = "/home",
                mount_options = "rw,hard,intr",
                owner = "root",
                protocol = "nfs",
                permission = "755",
                server_directory = "${google_filestore_instance.home_server.networks[0].ip_addresses[0]}:/${google_filestore_instance.home_server.file_shares[0].name}"}

  mounts = var.share_size_gb == 0 ? [local.home_mount, local.lustre_mount] : [local.home_mount, local.lustre_mount, {group = "root",
                                                                                             mount_directory = "/mnt/share",
                                                                                             mount_options = "rw,hard,intr",
                                                                                             owner = "root",
                                                                                             protocol = "nfs",
                                                                                             permission = "755",
                                                                                             server_directory = "${google_filestore_instance.share_server[0].networks[0].ip_addresses[0]}:/${google_filestore_instance.share_server[0].file_shares[0].name}"}]
}


// Create the Cloud SQL instance
resource "google_compute_global_address" "private_ip_address" {
  provider = google-beta
  name = "private-ip-address"
  purpose = "VPC_PEERING"
  address_type = "INTERNAL"
  prefix_length = 16
  network = google_compute_network.shared_vpc_network.id
  project = var.primary_project
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta
  network = google_compute_network.shared_vpc_network.id
  service = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
  depends_on = [google_project_service.service_networking]
}

// Create a random suffix - CloudSQL names cannot be reused within 7 days of use
resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "slurm_db" {
  provider = google-beta
  name = "${var.cluster_name}-slurm-db-${random_id.db_name_suffix.hex}"
  database_version = "MYSQL_5_6"
  region = local.primary_region
  project = var.primary_project
  depends_on = [google_service_networking_connection.private_vpc_connection,google_project_service.sql_admin,google_project_service.compute]

  settings {
    tier = var.cloud_sql_tier
    ip_configuration {
      ipv4_enabled  = false
      private_network = google_compute_network.shared_vpc_network.id
    }
  }
}

locals {
  slurm_db = {"cloudsql_name":google_sql_database_instance.slurm_db.name, 
              "cloudsql_ip":google_sql_database_instance.slurm_db.private_ip_address,
              "cloudsql_port":6819}
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
    vpc_subnet = google_compute_subnetwork.default_subnet.self_link
    zone = var.primary_zone
  }
  login = [{
    machine_type = var.login_machine_type
    disk_size_gb = 15
    disk_type = "pd-standard"
    labels = {"slurm-gcp"="login"}
    project = var.primary_project
    region = local.primary_region
    vpc_subnet = google_compute_subnetwork.default_subnet.self_link
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
                                      vpc_subnet = google_compute_subnetwork.default_subnet.self_link
                                      zone = var.primary_zone
                                   }]
                        }]

  // Create the draft partitions
  prePartitions = length(var.partitions) != 0 ? var.partitions : local.default_partition
  
  // If the user has provided a partitions list object, they don't have to provide the vpc-subnet, because
  // this module creates the subnets based on the number of unique regions derived from the partitions.
  // Instead, they can leave partitions[].machines[].vpc_subnet = "" and this step will use the partition zone
  // to map it to the VPC subnet
  partitions = [for p in local.prePartitions : {name = p.name
                                                project = p.project
                                                max_time = p.max_time
                                                labels = p.labels
                                                machines = [for m in p.machines : {name = m.name
                                                                                   disk_size_gb = m.disk_size_gb
                                                                                   disk_type = m.disk_type
                                                                                   disable_hyperthreading = m.disable_hyperthreading
                                                                                   external_ip = m.external_ip
                                                                                   gpu_count = m.gpu_count
                                                                                   gpu_type = m.gpu_type
                                                                                   n_local_ssds = m.n_local_ssds
                                                                                   image = m.image
                                                                                   local_ssd_mount_directory = m.local_ssd_mount_directory
                                                                                   machine_type = m.machine_type
                                                                                   max_node_count = m.max_node_count
                                                                                   preemptible_bursting = m.preemptible_bursting
                                                                                   static_node_count = m.static_node_count
                                                                                   vpc_subnet = m.vpc_subnet != "" ? m.vpc_subnet : local.zoneToSubnet[m.zone]
                                                                                   zone = m.zone}]}] 
                                            


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
  slurm_db = local.slurm_db
  mounts = local.mounts
}





