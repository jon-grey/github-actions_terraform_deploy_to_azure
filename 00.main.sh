#!/bin/bash
set -euo pipefail

echo "
###########################################################################
#### Setup infrastructure management
###########################################################################"
bash 01.deploy.azure.rbac.sh
bash 01.setup.local.terraform.sh
# bash 01.setup.local.github.secrets.sh
bash 02.make.terraform.tfvars.sh
bash 02.setup.azure.terraform.sh
bash 03.test.local.terraform.sh

git add .
git commit -m "Update at $(date)"
git push --set-upstream origin branch