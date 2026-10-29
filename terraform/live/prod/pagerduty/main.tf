locals {
  all_emails = toset(flatten(values(var.teams)))
}

data "pagerduty_user" "u" {
  for_each = local.all_emails
  email    = each.key
}

resource "pagerduty_schedule" "team" {
  for_each  = var.teams
  name      = "${each.key} primary"
  time_zone = "America/Chicago"
  layer {
    name                         = "weekly"
    start                        = var.rotation_start
    rotation_virtual_start       = var.rotation_start
    rotation_turn_length_seconds = 604800
    users                        = [for e in each.value : data.pagerduty_user.u[e].id]
  }
}

resource "pagerduty_escalation_policy" "team" {
  for_each  = var.teams
  name      = "${each.key} escalation"
  num_loops = 2
  rule {
    escalation_delay_in_minutes = 15
    target {
      type = "schedule_reference"
      id   = pagerduty_schedule.team[each.key].id
    }
  }
}

resource "pagerduty_service" "team" {
  for_each                = var.teams
  name                    = each.key
  escalation_policy       = pagerduty_escalation_policy.team[each.key].id
  acknowledgement_timeout = 1800
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "alertmanager" {
  for_each = var.teams
  name     = "Alertmanager"
  service  = pagerduty_service.team[each.key].id
  type     = "events_api_v2_inbound_integration"
}

output "integration_keys" {
  description = "Store each key in the secret store at observability/pagerduty/<team>"
  value       = { for k, i in pagerduty_service_integration.alertmanager : k => i.integration_key }
  sensitive   = true
}
