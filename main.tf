module "security_policies" {
  source = "./modules/security-policies"

  resource_description = var.sg_resource_description
  resource_name        = var.resource_name
  vpc_id               = module.openvpn_server.vpc_id
  vpn_host_zone_id     = module.openvpn_server.vpn_host_zone_id

}

module "openvpn_server" {
  source = "./modules/ovpn-server"

  domain                           = var.domain
  iam_instance_profile_openvpn_arn = module.security_policies.iam_instance_profile_openvpn_arn
  instance_type                    = var.instance_type
  key_name                         = var.key_name
  region                           = var.region
  resource_name                    = var.resource_name
  security_group_id                = module.security_policies.security_group_id
  volume_size                      = var.volume_size
  volume_type                      = var.volume_type
  vpc_name                         = var.vpc_name

}
