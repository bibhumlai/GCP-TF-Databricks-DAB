provider "databricks" {
    host=  var.databricks_host
    token = var.databricks_token
  
}

# 1. Create the Catalog for the migration
resource "databricks_catalog" "nativo" {
    name = "nativo_prod"
    comment = "Catalog for the migration project"
    force_destroy  = true
    # storage_root removed to use default storage
}

# 2. Create a Schema for raw data
resource "databricks_schema" "raw" {
    name = "raw"
    catalog_name = databricks_catalog.nativo.name
    comment = "Schema for raw data"
}

# 3. Create a specialized Job Cluster Policy (Cost Optimization!)
resource "databricks_cluster_policy" "migration_policy" {
    
    name = "Nativo-Migration-Policy"
    definition = jsonencode({
        "autotermination_minutes": {
            "type": "fixed",
            "value": 30
        },
        "cluster_type": {
            "type": "fixed",
            "value": "job"
        },

    })
}
# 1. Create the landing zone bucket for migration data
resource "google_storage_bucket" "migration_storage" {
  name          = "life-migration-data-db"
  location      = "US"
  force_destroy = true
  uniform_bucket_level_access = true
}

# 2. Create a Databricks storage credential for GCP
resource "databricks_storage_credential" "external" {
  name = "migration-gcp-creds"
  databricks_gcp_service_account {}
}

# 3. Grant the Databricks GCP service account access to the new bucket
resource "google_storage_bucket_iam_member" "admin" {
  bucket = google_storage_bucket.migration_storage.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${databricks_storage_credential.external.databricks_gcp_service_account[0].email}"
}

# 4. Create an External Location in Databricks for the new bucket
resource "databricks_external_location" "migration_ext" {
  name            = "nativo_migration_ext_location"
  url             = "gs://${google_storage_bucket.migration_storage.name}"
  credential_name = databricks_storage_credential.external.name
  comment         = "External location pointing to the migration bucket"
}

# 5. Create Volumes for Raw and Final data
resource "databricks_volume" "raw_volume" {
  name             = "raw_landing"
  catalog_name     = "nativo_prod"
  schema_name      = "raw"
  volume_type      = "EXTERNAL"
  storage_location = "gs://life-migration-data-db/raw_landing_zone"
}

resource "databricks_volume" "final_volume" {
  name             = "final_landing"
  catalog_name     = "nativo_prod"
  schema_name      = "raw"
  volume_type      = "EXTERNAL"
  storage_location = "gs://life-migration-data-db/final_landing_zone"
}
# # Output the paths so your notebook can find them
# output "landing_bucket_path" {
#   value = google_storage_bucket.landing_zone.url
# }