output "vpn_instance_dns" {
  value = aws_route53_record.openvpn.*.fqdn
}
output "vpn_host_zone_id" {
  value = data.aws_route53_zone.hosted_zone.id
}
output "vpc_id" {
  value = data.aws_vpc.vpc.id
}
