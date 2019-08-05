
variable "gcloud_project" {
  type = "string"
  description = "The name of the GCP project to deploy against. Set this using TF_VAR_gcloud_project environment variable"
}

variable "ssh_key" {
  type = "string"
  description = "The path to the public key to use to access the Google instance. Set this using TF_VAR_ssh_key environment variable."
}

module "terraform-google-instance" {
  source                  = "../../.."
  ssh_public_key_filepath = "${var.ssh_key}"
}

output "gcloud_project" {
  description = "The name of the GCP project to deploy against. We need this output to pass the value to tests."
  value       = "${var.gcloud_project}"
}
