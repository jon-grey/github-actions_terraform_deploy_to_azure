
# Deployment steps

# Install terraform

```sh
bash 01.setup.terraform.sh
```

# Setup Azure RBAC

```sh
bash 01.setup.azure.rbac.sh
```

# Setup Azure for Terraform

```sh
bash 02.setup.azure.terraform.sh
```



# Issues

## terraform plan is locked

When we try `terraform plan`

![](2021-04-21-19-16-24.png)

and in azure portal we see

![](2021-04-21-19-16-41.png)

or in az cli we can do

```sh
az storage blob show --name "terraform.tfstate" --container-name ${AZURE_STORAGE_TFSTATE} --account-name ${AZU
RE_STORAGE_ACCOUNT_OPS}  
```

to see 

![](2021-04-21-19-23-45.png)

Then we can break lease of blob in azure

```sh
az storage blob show --name "terraform.tfstate" --container-name ${AZURE_STORAGE_TFSTATE} --account-name ${AZURE_STORAGE_ACCOUNT_OPS}
```