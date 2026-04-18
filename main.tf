terraform {
    backend "gcs" {
        bucket = "terraform-state-bibhu"
        prefix = "databricks-life360"
    }

    required_providers {
        google = {
            source  = "hashicorp/google"
            version = "~> 5.0"
        }
        databricks = {
            source  = "databricks/databricks"
            version = "~> 1.0"
        }
    }
}
# 1. Connect to your GCP Project (AWS Equivalent: Connecting to your AWS Account)
provider "google" {
    project = "project-d938e8ef-98b9-4e42-9e8"              #var.gcp_project_id
    region  = "us-central1"                                 #var.gcp_region
  
}
# 2. Create a Databricks Workspace (AWS Equivalent: Creating an EMR Cluster)
provider "databricks" {
    alias = "mws"
    host  = "https://accounts.gcp.databricks.com"#"https://8259565123234976.6.gcp.databricks.com"# #
    account_id = "1198965d-51e1-4900-bfea-a9676e53cac9"
    # token = var.databricks_token
    # google_credentials = "D:\\DE\\Databricks\\Databricks on GCP\\Life360\\life360-migration-project\\key.json"  # Note: Use double backslashes for Windows paths in Terraform
    google_service_account = "databricks-tf@project-d938e8ef-98b9-4e42-9e8.iam.gserviceaccount.com"
}
# 3. Create the Databricks Workspace (AWS Equivalent: databricks_mws_workspaces on AWS)
resource "databricks_mws_workspaces" "new_workspace" {
    provider = databricks.mws
    account_id = "1198965d-51e1-4900-bfea-a9676e53cac9"
    workspace_name = "life360-migration-workspace"
    # deployment_name = "life360-migration-deployment"
    location = "us-central1"

    cloud_resource_container {
        gcp{
            project_id = "project-d938e8ef-98b9-4e42-9e8"
        
        }
      
    }
}




# Output the URL of the workspace so we can log into it after it builds
output "databricks_workspace_url" {
  value = databricks_mws_workspaces.new_workspace.workspace_url
}