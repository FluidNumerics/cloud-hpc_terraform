cluster_name = "demo"
controller_machine_type = "n1-standard-8"
login_machine_type = "n1-standard-8"
slurm_gcp_admins = ["group:support@example.com"]
slurm_gcp_users = ["user:someone@example.com"]

// You must provide a GCP project ID that resides underneath a parent folder
parent_folder = "folders/FOLDER ID"
primary_project = "PROJECT ID"
primary_zone = "ZONE"
vpc_subnet = "projects/{PROJECT}/regions/{REGION}/subnetworks/{SUBNETWORK}

// If you want to change the default images used to launch the cluster, you can set the self_link here.
// Note that you can use Packer to build on top of these images to retain full functionality of this
// deployment plus include your personal/company applications in the images
//
//controller_image = "projects/fluid-cluster-ops/global/images/fluid-slurm-gcp-controller-centos-v2-4-0"
//compute_image = "projects/fluid-cluster-ops/global/images/fluid-slurm-gcp-compute-centos-v2-4-0"
//login_image = "projects/fluid-cluster-ops/global/images/fluid-slurm-gcp-login-centos-v2-4-0"


// Leave the vpc_subnet blank in the partitions[].machines[] in this example
// This example creates VPC subnets based on the unique regions the partitions[].machines[]
// are aligned with. The main.tf in this example will automatically assign the vpc_subnet
// to each partitions[].machines[].vpc_subnet for you if set to ""
//
//partitions = [{name = "basic"
//               project = PROJECT ID
//               max_time = "8:00:00"
//               labels = {"slurm-gcp"="compute"}
//               machines = [{ name = "basic"
//                             disk_size_gb = 15
//                             disk_type = "pd-standard"
//                             disable_hyperthreading = false
//                             external_ip = false
//                             gpu_count = 0
//                             gpu_type = ""
//                             n_local_ssds = 0
//                             image = var.compute_image
//                             local_ssd_mount_directory = "/scratch"
//                             machine_type = "n1-standard-16"
//                             max_node_count = 5
//                             preemptible_bursting = false
//                             static_node_count = 0
//                             vpc_subnet = ""
//                             zone = ZONE
//                          }]
//               }]
//
//slurm_accounts = [{ name = "basic-users",
//                    users = ["someone","someone-else"]
//                    allowed_partitions = ["basic"]
//                 }]
 
