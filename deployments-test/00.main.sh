#!/bin/bash
set -euo pipefail

echo "
###########################################################################
#### Test infrastructure management deployments setup
###########################################################################"
bash 02.make.terraform.tfvars.sh
bash 03.test.local.terraform.sh

git add .
git commit -m "Update at $(date)"
git push --set-upstream origin branch