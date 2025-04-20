resource "google_project_iam_member" "storage_object_creator" {
  project = "blacksmith-443107"
  role    = "roles/storage.objectCreator"
  member  = "serviceAccount:blacksmith-github-actions@blacksmith-443107.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "storage_object_admin" {
  project = "blacksmith-443107"
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:blacksmith-github-actions@blacksmith-443107.iam.gserviceaccount.com"
}

# Add bucket-level IAM permissions for the prompt-engineering bucket
resource "google_storage_bucket_iam_member" "prompt_engineering_admin" {
  bucket = "blacksmith-prompt-engineering"
  role   = "roles/storage.admin"
  member = "serviceAccount:blacksmith-github-actions@blacksmith-443107.iam.gserviceaccount.com"
}
