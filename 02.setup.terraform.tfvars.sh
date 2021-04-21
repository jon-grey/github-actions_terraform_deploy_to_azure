#!/bin/bash
set -euo pipefail

dqt='"'


###########################################################################
#### Create service principal and save to $HOME/rbac.json
###########################################################################

. exports-private.sh

az account set --subscription $AZURE_SUBSCRIPTION_ID

# Generate Azure client id and secret.
export RBAC_JSON="$HOME/rbac.json"

if test -f "$RBAC_JSON"; then
	RBAC="$(cat $RBAC_JSON)"
else
	echo "[ERROR] no RBAC file"
    exit 1
fi

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
az_location                 = ${dqt}${AZURE_LOCATION}${dqt}
az_storage_tfstate          = ${dqt}${AZURE_STORAGE_TFSTATE}${dqt}
az_storage_account_ops      = ${dqt}${AZURE_STORAGE_ACCOUNT_OPS}${dqt}
az_storage_account_devs     = ${dqt}${AZURE_STORAGE_ACCOUNT_DEVS}${dqt}
az_resource_group_name_devs = ${dqt}${AZURE_RESOURCE_GROUP_DEVS}${dqt}
az_resource_group_name_ops  = ${dqt}${AZURE_RESOURCE_GROUP_OPS}${dqt}
" > $TFVARS
cat $TFVARS
