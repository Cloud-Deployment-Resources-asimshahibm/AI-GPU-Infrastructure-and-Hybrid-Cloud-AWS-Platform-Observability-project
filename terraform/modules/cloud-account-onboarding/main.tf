# Onboard a new AWS account: cross-account read role for YACE + PagerDuty service for the owning team.
data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [var.yace_role_arn]
    }
  }
}

resource "aws_iam_role" "cloudwatch_read" {
  name               = "${var.prefix}-obs-cloudwatch-read"
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

resource "aws_iam_role_policy_attachment" "cw" {
  role       = aws_iam_role.cloudwatch_read.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "tags" {
  role       = aws_iam_role.cloudwatch_read.name
  policy_arn = "arn:aws:iam::aws:policy/ResourceGroupsandTagEditorReadOnlyAccess"
}

resource "pagerduty_service" "team" {
  name              = "${var.team}-${var.account_alias}"
  escalation_policy = var.escalation_policy_id
  alert_creation    = "create_alerts_and_incidents"
  auto_resolve_timeout    = "null"
  acknowledgement_timeout = 1800
}

resource "pagerduty_service_integration" "alertmanager" {
  name    = "Alertmanager"
  service = pagerduty_service.team.id
  type    = "events_api_v2_inbound_integration"
}
