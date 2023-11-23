module "workload_1" {
    // todo github.com needs to be part of this token
    source = "github.com/<GITHUB_OWNER>/gitops.git//terraform/<CLOUD_PROVIDER>/modules/workload-cluster"

    cluster_name = var.cluster_name
    cluster_region = var.cluster_region
    environment = var.environment
    node_type = var.node_type
    node_count = var.node_count
}