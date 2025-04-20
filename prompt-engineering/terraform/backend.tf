#blacksmith-terraform-state
# gs://blacksmith-terraform-state

variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "blacksmith-443107"
}

variable "project_number" {
  description = "The GCP project number"
  type        = string
  default     = "506362606145"
}

terraform {
  backend "gcs" {
    bucket = "blacksmith-terraform-state"
    prefix = "prompt-engineering"
  }
}

# Import existing state bucket
resource "google_storage_bucket" "terraform_state" {
  name     = "blacksmith-terraform-state"
  location = "US"
  project  = var.project_id

  versioning {
    enabled = true
  }

  uniform_bucket_level_access = true
}

# IAM bindings for the state bucket
resource "google_storage_bucket_iam_member" "terraform_state_viewer" {
  bucket = google_storage_bucket.terraform_state.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${var.project_number}-compute@developer.gserviceaccount.com"
}

resource "google_storage_bucket_iam_member" "terraform_state_creator" {
  bucket = google_storage_bucket.terraform_state.name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${var.project_number}-compute@developer.gserviceaccount.com"
}


