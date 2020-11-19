
output "security_group_id" {
  value = module.security_group.security_group_id
}

output "iam_instance_profile_openvpn_arn" {
  value = module.iam_policies.iam_instance_profile_openvpn_arn
}
