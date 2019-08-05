variable "gcloud_project" {
  description = "The name of the GCP project to deploy against. Set this using TF_VARS_gcloud_project environment variable"
}

module "terraform-google-instance" {
  source                  = "../../.."
  ssh_public_key_filepath = "${path.module}/../../../ubuntu.pub"
}

output "gcloud_project" {
  description = "The name of the GCP project to deploy against. We need this output to pass the value to tests."
  value       = "${var.gcloud_project}"
}
