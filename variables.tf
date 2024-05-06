variable "gcp_project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "name" {
  type        = string
  description = "Name of service account"
}

variable "display_name" {
  type        = string
  description = "Human readable display name for service account"
}

variable "description" {
  type        = string
  description = "Description of the service and its purpose"
}

#########
# Project Access
#########

variable "project_roles" {
  type        = list(string)
  description = "List of roles the service account will have available in the project"
  default     = []
}

#########
# Impersonators
#########

variable "impersonation_roles" {
  type        = list(string)
  description = "List of roles requires on the service account in order to impersonate it."
  default = [
    "roles/iam.serviceAccountUser",
    "roles/iam.serviceAccountTokenCreator",
    "roles/iam.workloadIdentityUser",
  ]
}

variable "gcp_impersonators" {
  type        = list(string)
  description = "List of service acccount, users, and/or groups which are allowed to impersonate the service account"
  default     = []
}

#########
# K8s Service Account Impersonators
#########

variable "ksa_impersonators" {
  type = list(object({
    gke_project_id = string
    k8s_namespace  = string
    ksa_name       = string
  }))
  description = "List of Kubernetes service accounts which are allowed to impersonate the service account"
  default     = []
}

locals {
  k8s_impersonators = [
    for impersonator in var.ksa_impersonators :
    "serviceAccount:${impersonator.gke_project_id}.svc.id.goog[${impersonator.k8s_namespace}/${impersonator.ksa_name}]"
  ]

  impersonators = distinct(concat(local.k8s_impersonators, var.gcp_impersonators))
}

#########
# Service Account Group Membership
#########
variable "group_memberships" {
  type = list(string)
  description = "List of group_ids or aliases which this service account should be added to"
  default = []
}
