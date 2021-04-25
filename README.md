
# TODO

[x] - share one azure storage account with other github projects, but use different blobs

# Deployment steps

> Note: terraform for azure will not work before doing `make setup-deployments; make submit-deployments` or simply `make all`. As such github actions will fail as they need secrets!
 
## Setup deployments

In here we create Azure RBAC, install terraform locally, setup resources in Azure for Terraform. 

```sh
make setup-deployments
```

## Submit Deployments

In here we update dynamic variables for terraform via bash (edit deployments-submit/02.make.terraform.tfvars.sh accordingly), test our terraform deployment locally, and push changes of repo to github.

```sh
make submit-deployments
```

In github 


# Issues

## Parallel access to same azure blob 

Each github workflow using storage blob should have its own blob as they try to lock the same blob

![](images/README/2021-04-25-20-27-46.png)


## Manually unlock terraform.tfstate blob in azure

```sh
isLocked=$(az storage blob show --name "terraform.tfstate"  --container-name az-terraform-state --account-name storageops233836 --query "properties.lease.status=='locked'" -o tsv)
 
if  $isLocked; then 
    az storage blob lease break --blob-name "terraform.tfstate" --container-name az-terraform-state --account-name storageops233836                
fi      
```


## terraform plan hangs in github actions

![](images/README/2021-04-21-21-45-13.png)

As we can here `command: asking for input: "var.az_storage_account_devs"` there are no variables, so we have to unignore `terraform.tfvars` file. LOL

## terraform plan is locked

When we try `terraform plan`

![](images/README/2021-04-21-19-16-24.png)

and in azure portal we see

![](images/README/2021-04-21-19-16-41.png)

or in az cli we can do

```sh
az storage blob show --name "terraform.tfstate" --container-name ${AZURE_STORAGE_BLOB_TFSTATE} --account-name ${AZURE_STORAGE_ACCOUNT_OPS}  
```

to see 

![](images/README/2021-04-21-19-23-45.png)

Then we can break lease of blob in azure

```sh
az storage blob show --name "terraform.tfstate" --container-name ${AZURE_STORAGE_BLOB_TFSTATE} --account-name ${AZURE_STORAGE_ACCOUNT_OPS}
```