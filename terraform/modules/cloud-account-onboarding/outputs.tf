output "cloudwatch_read_role_arn" {
  value = aws_iam_role.cloudwatch_read.arn
}
output "pagerduty_integration_key" {
  value     = pagerduty_service_integration.alertmanager.integration_key
  sensitive = true
}
