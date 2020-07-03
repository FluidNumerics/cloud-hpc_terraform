// Configure the Google Cloud provider
provider "google" {
 version = "3.9"
}

resource "google_compute_disk" "mdt" {
  count = var.mds_node_count
  name = "${var.cluster_name}-mdt${count.index}"
  type = var.mdt_disk_type
  zone = var.zone
  size = var.mdt_disk_size_gb 
  project = var.project
}

resource "google_compute_instance" "mds" {
  count = var.mds_node_count
  name = "${var.cluster_name}-mds${count.index}"
  project = var.project
  machine_type = var.mds_machine_type
  zone = var.zone
  tags = var.network_tags
  boot_disk {
    auto_delete = true
    initialize_params {
      image = "projects/centos-cloud/global/images/family/centos-7"
      size = var.mds_boot_disk_size_gb
      type = var.mds_boot_disk_type
    }
  }
  attached_disk {
    source = google_compute_disk.mdt[count.index].self_link 
    device_name = "mdt"
  }
  metadata_startup_script = file("${path.module}/scripts/startup-script.sh")
  metadata = {
    cluster-name = var.cluster_name
    fs-name = var.fs_name
    node-role = "MDS"
    hsm-gcs = var.hsm_gcs_bucket
    hsm-gcs-prefix = var.hsm_gcs_prefix
    lustre-version = var.lustre_version
    e2fs-version = var.e2fs_version
    enable-oslogin = "TRUE"
  }
  network_interface {
    subnetwork  = var.vpc_subnet
    access_config {
    }
  }
  service_account {
    email  = var.service_account
    scopes = ["cloud-platform"]
  }
  allow_stopping_for_update = true
}


// OSS
resource "google_compute_disk" "ost" {
  count = var.oss_node_count
  name = "${var.cluster_name}-ost${count.index}"
  type = var.ost_disk_type
  zone = var.zone
  size = var.ost_disk_size_gb 
  project = var.project
}

resource "google_compute_instance" "oss" {
  count = var.oss_node_count
  name = "${var.cluster_name}-oss${count.index}"
  project = var.project
  machine_type = var.oss_machine_type
  zone = var.zone
  tags = var.network_tags
  boot_disk {
    auto_delete = true
    initialize_params {
      image = "projects/centos-cloud/global/images/family/centos-7"
      size = var.oss_boot_disk_size_gb
      type = var.oss_boot_disk_type
    }
  }
  attached_disk {
    source = google_compute_disk.ost[count.index].self_link 
    device_name = "ost"
  }
  metadata_startup_script = file("${path.module}/scripts/startup-script.sh")
  metadata = {
    cluster-name = var.cluster_name
    fs-name = var.cluster_name
    node-role = "OSS"
    hsm-gcs = var.hsm_gcs_bucket
    hsm-gcs-prefix = var.hsm_gcs_prefix
    lustre-version = var.lustre_version
    e2fs-version = var.e2fs_version
    enable-oslogin = "TRUE"
  }
  network_interface {
    subnetwork  = var.vpc_subnet
    access_config {
    }
  }
  service_account {
    email  = var.service_account
    scopes = ["cloud-platform"]
  }
  allow_stopping_for_update = true
}

resource "google_compute_instance" "hsm" {
  count = var.hsm_node_count
  name = "${var.cluster_name}-hsm${count.index}"
  project = var.project
  machine_type = var.hsm_machine_type
  zone = var.zone
  tags = var.network_tags
  boot_disk {
    auto_delete = true
    initialize_params {
      image = "projects/centos-cloud/global/images/family/centos-7"
      size = 20
      type = "pd-standard"
    }
  }
  metadata_startup_script = file("${path.module}/scripts/startup-script.sh")
  metadata = {
    cluster-name = var.cluster_name
    fs-name = var.cluster_name
    node-role = "HSM"
    hsm-gcs = var.hsm_gcs_bucket
    hsm-gcs-prefix = var.hsm_gcs_prefix
    lustre-version = var.lustre_version
    e2fs-version = var.e2fs_version
    enable-oslogin = "TRUE"
  }
  network_interface {
    subnetwork  = var.vpc_subnet
    access_config {
    }
  }
  service_account {
    email  = var.service_account
    scopes = ["cloud-platform"]
  }
  allow_stopping_for_update = true
}
