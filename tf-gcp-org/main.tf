resource "google_folder" "department" {
  display_name = "csye7125"
  parent       = "organizations/${var.org_id}"
}

resource "random_id" "random" {
  byte_length = 4
}

data "google_billing_account" "acct" {
  billing_account = var.billing_id
  open            = true
}

resource "google_project" "kubernetes" {
  name            = "Kubernetes"
  project_id      = "kubernetes-${random_id.random.hex}"
  billing_account = data.google_billing_account.acct.id
  folder_id       = google_folder.department.name
}

# resource "google_project_service" "cloud_resource" {
#   project = var.first_project
#   service = "cloudresourcemanager.googleapis.com"
#   disable_dependent_services = false
# }

resource "google_project_service" "billing" {
  project = google_project.kubernetes.project_id
  service = "cloudbilling.googleapis.com"
  # disable_dependent_services = true
}

resource "google_project_service" "cloud_dns" {
  project = google_project.kubernetes.project_id
  service = "dns.googleapis.com"
  # disable_dependent_services = true
}

resource "google_project_service" "service_usage" {
  project = google_project.kubernetes.project_id
  service = "serviceusage.googleapis.com"
  # disable_dependent_services = true
}

resource "google_project_service" "vpc" {
  project = google_project.kubernetes.project_id
  service = "vpcaccess.googleapis.com"
  # disable_dependent_services = true
}

resource "google_project_service" "compute_api" {
  project = google_project.kubernetes.project_id
  service = "compute.googleapis.com"
  # disable_dependent_services = true
}

resource "google_project_service" "crm_api" {
  project = google_project.kubernetes.project_id
  service = "cloudresourcemanager.googleapis.com"
  # disable_dependent_services = true
}

resource "google_project_service" "kube_api" {
  project = google_project.kubernetes.project_id
  service = "container.googleapis.com"
  # disable_dependent_services = true
}

resource "time_sleep" "wait_60_seconds" {
  depends_on      = [google_project_service.billing, google_project_service.cloud_dns, google_project_service.service_usage, google_project_service.vpc, google_project_service.compute_api, google_project_service.kube_api]
  create_duration = "60s"
}

resource "google_compute_network" "kube_vpc" {
  depends_on              = [time_sleep.wait_60_seconds]
  project                 = google_project.kubernetes.project_id
  name                    = "kube-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "public_subnet" {
  name          = "public-subnet"
  ip_cidr_range = cidrsubnet(var.cidr_block, 4, 1)
  network       = google_compute_network.kube_vpc.id
  project       = google_project.kubernetes.project_id
}

resource "google_compute_subnetwork" "private_subnet" {
  # count         = var.private_subnets
  # name          = "subnet-${count.index}"
  name = "private-subnet"
  # ip_cidr_range = cidrsubnet(var.cidr_block, 4, count.index + 1)
  ip_cidr_range            = cidrsubnet(var.cidr_block, 4, 2)
  private_ip_google_access = true
  network                  = google_compute_network.kube_vpc.id
  project                  = google_project.kubernetes.project_id

  secondary_ip_range {
    range_name    = "k8s-pod-range"
    ip_cidr_range = var.k8s_pod_range
  }
  secondary_ip_range {
    range_name    = "k8s-service-range"
    ip_cidr_range = var.k8s_service_range
  }
}

resource "google_compute_firewall" "instance_firewall" {
  project   = google_project.kubernetes.project_id
  name      = "instance-firewall"
  network   = google_compute_network.kube_vpc.name
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}

resource "google_service_account" "bastion_host_sa" {
  project      = google_project.kubernetes.project_id
  account_id   = "bastion-host-sa"
  display_name = "My Compute Instance Service Account"
}

resource "google_project_iam_binding" "bind_cluster_admin" {
  project = google_project.kubernetes.project_id
  role    = "roles/container.clusterAdmin"


  members = [
    "serviceAccount:${google_service_account.bastion_host_sa.email}",
  ]
}

resource "google_project_iam_binding" "tunnel_resource_accessor" {
  project = google_project.kubernetes.project_id
  role    = "roles/iap.tunnelResourceAccessor"


  members = [
    "serviceAccount:${google_service_account.bastion_host_sa.email}",
  ]
}

resource "google_project_iam_binding" "bind_compute_admin" {
  project = google_project.kubernetes.project_id
  role    = "roles/compute.admin"


  members = [
    "serviceAccount:${google_service_account.bastion_host_sa.email}",
  ]
}

resource "google_project_iam_binding" "bind_container_admin" {
  project = google_project.kubernetes.project_id
  role    = "roles/container.admin"


  members = [
    "serviceAccount:${google_service_account.bastion_host_sa.email}",
  ]
}


resource "google_compute_instance" "default" {
  project                   = google_project.kubernetes.project_id
  name                      = "bastion-host"
  machine_type              = "e2-medium"
  zone                      = "us-east1-b"
  allow_stopping_for_update = true

  tags = ["web"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      labels = {
        my_label = "value"
      }
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.public_subnet.self_link
    access_config {
      // To allow external IP access
    }
  }

  service_account {
    email  = google_service_account.bastion_host_sa.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata = {
    ssh-keys = "${var.ssh_username}:${file(var.ssh_key_path)}"
  }

  metadata_startup_script = <<-EOF
#!/bin/bash
sudo apt-get install kubectl -y
sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin -y
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
EOF

}

resource "google_service_account" "gke_sa" {
  project      = google_project.kubernetes.project_id
  account_id   = format("gke-sa")
  display_name = "gke-sa"
}

resource "google_compute_router" "router" {
  project = google_project.kubernetes.project_id
  name    = "router"
  region  = var.region
  network = google_compute_network.kube_vpc.id
}

resource "google_compute_router_nat" "nat" {
  project = google_project.kubernetes.project_id
  name    = "nat"
  router  = google_compute_router.router.name
  region  = var.region

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  nat_ip_allocate_option             = "MANUAL_ONLY"

  subnetwork {
    name                    = google_compute_subnetwork.private_subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  nat_ips = [google_compute_address.nat.self_link]
}

resource "google_compute_address" "nat" {
  project      = google_project.kubernetes.project_id
  name         = "nat"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"

  depends_on = [google_project_service.compute_api]
}

resource "google_container_cluster" "my_cluster" {
  project                  = google_project.kubernetes.project_id
  name                     = "my-gke-cluster"
  location                 = var.region
  network                  = google_compute_network.kube_vpc.self_link
  subnetwork               = google_compute_subnetwork.private_subnet.self_link
  remove_default_node_pool = true
  initial_node_count       = 1

  node_config {
    service_account = google_service_account.gke_sa.email
    disk_type       = "pd-standard"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "k8s-pod-range"
    services_secondary_range_name = "k8s-service-range"
  }

  workload_identity_config {
    workload_pool = "${google_project.kubernetes.project_id}.svc.id.goog"
  }

  binary_authorization {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "${google_compute_instance.default.network_interface[0].access_config[0].nat_ip}/32"
      display_name = "Bastion Host access to cluster"
    }
    cidr_blocks {
      cidr_block   = "${var.jenkins_cidr_block}/32"
      display_name = "Jenkins Server access to cluster"
    }
  }
  deletion_protection = false
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  project    = google_project.kubernetes.project_id
  name       = "my-node-pool"
  location   = var.region
  cluster    = google_container_cluster.my_cluster.name
  node_count = 1
  autoscaling {
    # min_node_count  = var.zone_min_node_count
    # max_node_count  = var.zone_max_node_count
    total_min_node_count = var.min_node_count
    total_max_node_count = var.max_node_count
    # location_policy = "BALANCED"
  }

  node_config {
    machine_type = var.node_machine_type
    image_type   = "COS_CONTAINERD"
    disk_type    = "pd-standard"
    labels = {
      team = "gke"
    }
    service_account = google_service_account.gke_sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

resource "null_resource" "run_last" {
  depends_on = [google_container_node_pool.primary_preemptible_nodes]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.ssh_username
      agent       = false
      private_key = file(var.ssh_private_key)
      host        = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
    }
    inline = [
      "gcloud container clusters get-credentials '${google_container_cluster.my_cluster.name}' --region '${google_container_cluster.my_cluster.location}' --project ${google_project.kubernetes.project_id}"
    ]
  }
}


# resource "helm_release" "my_app" {
#   name       = "my-app"
#   chart      = "/Users/nbabu/Documents/webapp-3.0.0.tgz"
#   namespace  = "default"
#   depends_on = [null_resource.run_last]
# }
 