## Terraform-Openvpn-Server 

An openvpn server implementation. Packer creates an ami, ami runs on a single node ASG as a spot instance.SSH access only from local machine terraform runs from. Clients can be added via a " " seperated list,examples in Makefile.When an instance is terminated the public ip of the replacement instance is attached to the A record vpn-$DOMAIN.Makefile serves as a main interaction point. Example .tfvars file, example/variables.tfvars_example.Updating the instance type for example will cause a new asg to be created before the old one is destroyed. 

### Prerequisite 
- Packer 
- Terraform 
- awscli 

### Installation (Packer + Terraform)
```
export LOCAL_CLIENTS_DIR=/urbanradikal/openvpn && \
export DOMAIN=urbanradikal.io && \
make build_server 

```

Run `make help` or `make` for all other options



### References 
- https://github.com/dumrauf/openvpn-terraform-install
- https://github.com/angristan/openvpn-install
- https://github.com/lmammino/terraform-openvpn
- https://github.com/terraform-community-modules/tf_aws_openvpn
