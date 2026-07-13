#resource "aws_iam_user" "kubernetes_admin" {
#  name = local.kubernetes_admin_name
#}
#
#resource "aws_iam_access_key" "kubernetes_admin_bash_key" {
#  user = aws_iam_user.kubernetes_admin.name
#}
#
#resource "aws_iam_user_policy" "kubernetes_admin_policy" {
#  name = "kubernetes_admin_policy"
#  user = aws_iam_user.kubernetes_admin.name
#  policy = <<EOT
#    {
#    "Version": "2012-10-17",
#    "Statement": [
#        {
#            "Sid": "Statement1",
#            "Effect": "Allow",
#            "Action": [
#                "ec2:*"
#            ],
#            "Resource": 
#            ${jsonencode(
#  concat(aws_instance.kubernetes_controllers[*].arn, aws_instance.kubernetes_workers[*].arn)
#)}
#            
#        }
#    ]
#}
#    EOT
#}
#
#output "kubernetes_admin_iam_access_key_id" {
#  description = "Iam key id for kubernetes admin"
#  value       = aws_iam_access_key.kubernetes_admin_bash_key.id
#  sensitive   = true
#}
#
#output "kubernetes_admin_iam_access_key_secret" {
#  description = "Access key secret for kubernetes admin"
#  value       = aws_iam_access_key.kubernetes_admin_bash_key.secret
#  sensitive   = true
#}