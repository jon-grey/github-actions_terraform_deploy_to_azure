#!/bin/bash
set -euo pipefail

dqt='"'


###########################################################################
#### Create service principal and save to $HOME/rbac.json
###########################################################################

. exports-private.sh

az account set --subscription $AZURE_SUBSCRIPTION_ID

echo "Init terraform"
terraform init 

echo "Format check terraform"
terraform fmt -check

echo "Plan terraform"
terraform plan