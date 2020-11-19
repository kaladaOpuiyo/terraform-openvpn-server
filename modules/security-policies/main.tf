module "security_group" {
  source = "./modules/security-groups"


  resource_name        = var.resource_name
  resource_description = var.resource_description
  vpc_id               = var.vpc_id

}
module "iam_policies" {
  source = "./modules/iam-policies"

  resource_name    = var.resource_name
  vpn_host_zone_id = var.vpn_host_zone_id

}

