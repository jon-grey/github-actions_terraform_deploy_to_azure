#!/bin/bash
set -euo pipefail

dqt='"'

random () 
{ 
    date "+%H%M%S"
}


###########################################################################
#### Create service principal and save to $HOME/rbac.json
###########################################################################

. exports-private.sh

az account set --subscription $AZURE_SUBSCRIPTION_ID
az aks get-credentials \
	--resource-group $AZURE_RESOURCE_GROUP \
	--name $AZURE_AKS_CLUSTER || true

# Generate Azure client id and secret.
export RBAC_JSON="$HOME/rbac.json"

if test -f "$RBAC_JSON"; then
	RBAC="$(cat $RBAC_JSON)"
else
    RBAC_NAME="--name $AZURE_SERVICE_PRINCIPAL"
    RBAC_ROLE="--role 'Contributor'"
    RBAC_SCOPES="--scopes /subscriptions/${AZURE_SUBSCRIPTION_ID}"
	RBAC="$(az ad sp create-for-rbac $RBAC_NAME $RBAC_ROLE $RBAC_SCOPES)"
	echo $RBAC > $RBAC_JSON
fi

export KUBECONFIG=~/.kube/aksconfig


echo $RBAC 

###########################################################################
#### Read variables from RBAC dict
###########################################################################

function rdict {
	python3 -c "print($1[${dqt}$2${dqt}])"
}

ARM_TENANT_ID=$(rdict     "$RBAC" "tenant")
ARM_CLIENT_ID=$(rdict     "$RBAC" "appId")
ARM_CLIENT_SECRET=$(rdict "$RBAC" "password")

###########################################################################
#### Populate terraform variables file
###########################################################################

TFVARS="terraform.tfvars"

echo "
az_client_id                = ${dqt}${ARM_CLIENT_ID}${dqt}
az_client_secret            = ${dqt}${ARM_CLIENT_SECRET}${dqt}
az_location                 = ${dqt}${AZURE_LOCATION}${dqt}
az_storage_tfstate       = ${dqt}${AZURE_STORAGE_TFSTATE}${dqt}
az_storage_account_ops      = ${dqt}${AZURE_STORAGE_ACCOUNT_OPS}${dqt}
az_storage_account_devs     = ${dqt}${AZURE_STORAGE_ACCOUNT_DEVS}${dqt}
az_resource_group_name_devs = ${dqt}${AZURE_RESOURCE_GROUP_DEVS}${dqt}
az_resource_group_name_ops  = ${dqt}${AZURE_RESOURCE_GROUP_OPS}${dqt}
email                    = ${dqt}${LETSENCRYPT_EMAIL}${dqt}
" > $TFVARS
cat $TFVARS

###########################################################################
#### Setup Terraform on Azure
###########################################################################


az group create -g ${AZURE_RESOURCE_GROUP_OPS} -l ${AZURE_LOCATION}

az storage account create -n ${AZURE_STORAGE_ACCOUNT_OPS} -g ${AZURE_RESOURCE_GROUP_OPS} -l ${AZURE_LOCATION} --sku Standard_LRS

az storage container create -n $AZ_TFSTATE --account-name ${AZURE_STORAGE_ACCOUNT_OPS}



###########################################################################
#### Create AKS cluster
###########################################################################

# TARGETS="\
#  -target module.a_aks_cluster \
#  -target module.a_az_container_registry \
# "

echo "TARGETS: "
#echo $TARGETS

echo "############# INIT: to initialize Terraform"
terraform init #$TARGETS
echo "############# PLAN: to see execution plan.
Note: 'plan' to test changes locally here 
      and review the execution plan
	  before committing the changes to Git.
"
terraform plan  #$TARGETS

echo "############# APPLY: "
terraform apply -auto-approve  #$TARGETS

# ###########################################################################
# #### Configure AKS connection in local env 
# ###########################################################################
echo "############# OUT: "
terraform output configure
terraform output -raw kube_config > ~/.kube/aksconfig
export KUBECONFIG=~/.kube/aksconfig
kubectl get nodes

# ###########################################################################
# #### Connect to AKS
# ###########################################################################

az aks get-credentials \
	--resource-group $AZURE_RESOURCE_GROUP \
	--name $AZURE_AKS_CLUSTER || true