project = "PROJECT ID"
vpc_subnet = "projects/PROJECT ID/regions/REGION/subnetworks/SUBNETWORK"
zone = "ZONE"

mds_node_count          = 1
mds_machine_type        = "n1-standard-32"
mds_boot_disk_type      = "pd-standard"
mds_boot_disk_size_gb   = 20
mdt_disk_type           = "pd-ssd"
mdt_disk_size_gb        = 100

oss_node_count          = 4
oss_machine_type        = "n1-standard-16"
oss_boot_disk_type      = "pd-standard"
oss_boot_disk_size_gb   = 20
ost_disk_type           = "pd-standard"
ost_disk_size_gb        = 1000

// Lustre HSM Lemur Configuration
//hsm_node_count         = 1
//hsm_machine_type       = "n1-standard-8"
//hsm_gcs_bucket         = "MY_BUCKET"
//hsm_gcs_bucket_import  = "MY_BUCKET_PATH"
