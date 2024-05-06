#########
# GCP service account for the service
#########

resource "google_service_account" "service_account" {
  account_id   = var.name
  display_name = var.display_name
  description  = var.description
  project      = var.gcp_project_id
}

#########
# Attach permission roles to service account
#########

resource "google_project_iam_member" "service_account" {
  for_each = toset(var.project_roles)
  project  = var.gcp_project_id
  member   = "serviceAccount:${google_service_account.service_account.email}"
  role     = each.value
}

#########
# Impersonators
#########

data "google_iam_policy" "service_account_iam_policy" {
  dynamic "binding" {
    for_each = var.impersonation_roles
    content {
      role    = binding.value
      members = local.impersonators
    }
  }
}

resource "google_service_account_iam_policy" "service_account_iam_policy" {
  service_account_id = google_service_account.service_account.name
  policy_data        = data.google_iam_policy.service_account_iam_policy.policy_data
}

#########
# Identity Group Membership
#########

resource "google_cloud_identity_group_membership" "group_membership" {
  for_each = toset(var.group_memberships)
  group = each.value

  preferred_member_key {
    id = google_service_account.service_account.email
  }

  roles {
    name = "MEMBER"
  }
}