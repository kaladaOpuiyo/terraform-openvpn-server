# Thank you to these guys and others I referenced. 
# https://github.com/dumrauf/openvpn-terraform-install
# https://github.com/angristan/openvpn-install
# https://github.com/lmammino/terraform-openvpn
# https://github.com/terraform-community-modules/tf_aws_openvpn
OPENVPN_INSTALL_SCRIPT		="https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh"
OPENVPN_UPDATE_USER_SCRIPT	="https://raw.githubusercontent.com/dumrauf/openvpn-terraform-install/master/scripts/update_users.sh"

BASE_AMI 					=ami-0528a5175983e7f28
CLIENTS						="laptop firestick iphone ipad"
DESTROY_OLD_AMI				=true
DOMAIN_ENDPOINT 			=$(DOMAIN)
OPENVPN_LOCAL_CLIENTS_DIR	=$(LOCAL_CLIENTS_DIR)
NAME						=openvpn-server
OPENVPN_CLIENTS_DIR 		=/home/$(SSH_USER)/clients
REGION 						=us-west-2
SSH_USER 					=ec2-user
INSTANCE_TYPE           	=t3.micro

.PHONY: help

build_server: packer_build apply
destroy_server: destroy ami_destroy

help:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

.DEFAULT_GOAL := help

init: 
	terraform init 
	terraform get -update

plan: init
ifdef TARGET
	terraform plan  -detailed-exitcode  -target $(TARGET) \
	-var='resource_name=$(NAME)' \
	-var='region=$(REGION)' \
	-var='instance_type=$(INSTANCE_TYPE)' \
	-var='domain=$(DOMAIN_ENDPOINT)'
else
	terraform plan -detailed-exitcode \
	-var='resource_name=$(NAME)' \
	-var='region=$(REGION)' \
	-var='instance_type=$(INSTANCE_TYPE)' \
	-var='domain=$(DOMAIN_ENDPOINT)'
endif

apply: init
ifdef TARGET
	terraform apply -target $(TARGET) \
	-var='resource_name=$(NAME)' \
	-var='region=$(REGION)' \
	-var='instance_type=$(INSTANCE_TYPE)' \
	-var='domain=$(DOMAIN_ENDPOINT)'
else
	terraform apply \
	-var='resource_name=$(NAME)' \
	-var='region=$(REGION)' \
	-var='instance_type=$(INSTANCE_TYPE)' \
	-var='domain=$(DOMAIN_ENDPOINT)'
endif

destroy: init
ifdef TARGET
	terraform destroy -target $(TARGET) \
	-var='resource_name=$(NAME)' \
	-var='region=$(REGION)' \
	-var='instance_type=$(INSTANCE_TYPE)' \
	-var='domain=$(DOMAIN_ENDPOINT)'
else
	terraform destroy \
	-var='resource_name=$(NAME)' \
	-var='region=$(REGION)' \
	-var='instance_type=$(INSTANCE_TYPE)' \
	-var='domain=$(DOMAIN_ENDPOINT)'
endif

packer_build: packer_validate 
ifdef CLIENTS  
ifdef DOMAIN_ENDPOINT
ifdef OPENVPN_LOCAL_CLIENTS_DIR
ifdef NAME
ifdef REGION
	packer build \
	-var 'aws_region=$(REGION)' \
	-var 'base_ami=$(BASE_AMI)' \
	-var 'openvpn_ami_name=$(NAME)' \
	-var 'openvpn_clients_dir=$(OPENVPN_CLIENTS_DIR)' \
	-var 'openvpn_default_users=$(CLIENTS)' \
	-var 'openvpn_domain=$(DOMAIN_ENDPOINT)' \
	-var 'openvpn_install_script_location=$(OPENVPN_INSTALL_SCRIPT)' \
	-var 'openvpn_local_dir=$(OPENVPN_LOCAL_CLIENTS_DIR)' \
	-var 'openvpn_destroy_old_ami=$(DESTROY_OLD_AMI)' \
	-var 'instance_type=$(INSTANCE_TYPE)' \
	-var 'ssh_user=$(SSH_USER)' \
	-var 'openvpn_update_user_script_location=$(OPENVPN_UPDATE_USER_SCRIPT)' \
	packer/openvpn.json 
else
	@echo please ensure all variables are set
endif
endif
endif
endif
endif

packer_validate:
	packer validate \
	-var 'aws_region=$(REGION)' \
	-var 'base_ami=$(BASE_AMI)' \
	-var 'instance_type=$(INSTANCE_TYPE)' \
	-var 'openvpn_ami_name=$(NAME)' \
	-var 'openvpn_clients_dir=$(OPENVPN_CLIENTS_DIR)' \
	-var 'openvpn_default_users=$(CLIENTS)' \
	-var 'openvpn_domain=$(DOMAIN_ENDPOINT)' \
	-var 'openvpn_install_script_location=$(OPENVPN_INSTALL_SCRIPT)' \
	-var 'openvpn_local_dir=$(OPENVPN_LOCAL_CLIENTS_DIR)' \
	-var 'ssh_user=$(SSH_USER)' \
	-var 'openvpn_update_user_script_location=$(OPENVPN_UPDATE_USER_SCRIPT)' \
	packer/openvpn.json  

# Mainly for testing 
ami_destroy:
	aws ec2 describe-images \
	 --filters "Name=tag:Name,Values=[$(NAME)]" \
	 --query 'Images[*].[ImageId]' --output text \
	 | xargs -I {}  aws ec2 deregister-image --image-id {} 
	
	@echo image removed. GO CHECK!