resource "google_container_cluster" "primary" {
  name       = "my-gke-cluster"
  location   = "us-central1"
  network    = "${google_compute_network.my_vpc_network.name}"
  subnetwork = "${google_compute_subnetwork.private_subnetwork.name}"

  initial_node_count = 1
}
