variable "databricks_token" {
  description = "Databricks Personal Access Token"
  type        = string
  sensitive   = true
}

variable "databricks_host" {
  description = "Databricks Workspace URL"
  type        = string
}