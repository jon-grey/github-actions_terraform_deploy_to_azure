#!/bin/bash
set -euo pipefail

dqt='"'

function random () 
{ 
    date "+%H%M%S"
}

function rdict {
	python3 -c "print($1[${dqt}$2${dqt}])"
}

###########################################################################
#### Create service principal and save to $HOME/rbac.json
###########################################################################

. exports-private.sh

# uncomment at first run
# az login 

az account set --subscription $AZURE_SUBSCRIPTION_ID

# Generate Azure client id and secret.
export RBAC_JSON="$HOME/rbac.json"

if test -f "$RBAC_JSON"; then
	RBAC="$(cat $RBAC_JSON)"
else
    RBAC_NAME="--name $AZURE_SERVICE_PRINCIPAL"
    RBAC_ROLE="--role Contributor"
    RBAC_SCOPES="--scopes /subscriptions/${AZURE_SUBSCRIPTION_ID}"
	RBAC=$(az ad sp create-for-rbac $RBAC_NAME $RBAC_ROLE $RBAC_SCOPES)
	echo $RBAC > $RBAC_JSON
fi

ARM_TENANT_ID=$(rdict     "${RBAC}" "tenant")
ARM_CLIENT_ID=$(rdict     "${RBAC}" "appId")
ARM_CLIENT_SECRET=$(rdict "${RBAC}" "password")

echo "Store json below as AZURE_CREDENTIALS in github secrets"
echo "======================================================"
echo $RBAC 
echo "======================================================"


echo "
ARM_TENANT_ID = $ARM_TENANT_ID
ARM_CLIENT_ID = $ARM_CLIENT_ID
ARM_CLIENT_SECRET = $ARM_CLIENT_SECRET
AZURE_SUBSCRIPTION_ID = $AZURE_SUBSCRIPTION_ID
"