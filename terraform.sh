#!/bin/bash

# Create the service principal, resource group,
# storage account for tfstate
# and put the secrets into a key vault

set -x

uniq=${1:-citadel}          # unique prefix for FQDNs
config=${2:-cookie-cutter}  # use hyphens, not underscores, to adhere to naming policy for secrets

export AZURE_DEFAULTS_LOCATION="uksouth"
export AZURE_DEFAULTS_GROUP="terraform"
export AZURE_STORAGE_ACCOUNT="${uniq}terraform"

kvName="${uniq}terraform"

tenantId=$(az account show --query tenantId --output tsv)
subscriptionId=$(az account show --query id --output tsv)
myObjectId=$(az ad signed-in-user show --query id --output tsv)

spName="http://terraform"
password=$(az ad sp create-for-rbac --name $spName --query password --output tsv)
appId=$(az ad app list --display-name $spName --query [0].appId --output tsv)
objectId=$(az ad app show --id $appId --query id --output tsv)

az group create --name $AZURE_DEFAULTS_GROUP

az storage account create --name $AZURE_STORAGE_ACCOUNT --sku Standard_LRS
saId=$(az storage account show --name $AZURE_STORAGE_ACCOUNT --query id --output tsv)
az role assignment create --role "Storage Blob Data Contributor" --scope $saId --assignee $myObjectId
# az role assignment create --role "Storage Blob Data Contributor" --scope $saId --assignee $appId
az storage container create --name "$config" --auth-mode login

az keyvault create --name $kvName --retention-days 7 --enable-rbac-authorization
kvId=$(az keyvault show --name $kvName --query id --output tsv)
az role assignment create --role "Key Vault Administrator" --scope $kvId --assignee $myObjectId
# az role assignment create --role "Key Vault Secrets User" --scope $kvId --assignee $appId
az keyvault secret set --vault-name "$kvName" --name "${config}-client-id" --value $appId
az keyvault secret set --vault-name "$kvName" --name "${config}-client-secret" --value $password
