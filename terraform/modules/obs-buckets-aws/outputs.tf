output "bucket_names" {
  value = { for k, b in module.bucket : k => b.s3_bucket_id }
}
output "bucket_arns" {
  value = { for k, b in module.bucket : k => b.s3_bucket_arn }
}
