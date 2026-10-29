output "role_arns" {
  value = merge({ for k, m in module.irsa : k => m.iam_role_arn }, { yace = module.yace.iam_role_arn })
}
