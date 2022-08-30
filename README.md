# Cookie Cutter

Demonstrate that Terraform can deploy the same configuration to multiple customers in an Azure Lighthouse multi-tenanted environment.

***This repo is intended as a reference for managed service providers (MSPs) who are experienced with both Terraform and Azure Lighthouse.***

## Initialisation

Initial set-up in the "home" Managed Services Provider (MSP) subscription is  via the terraform.sh script, which creates

* a service principal in the MSP tenancy called `http://terraform`
* a resource group, `terraform`
* a storage account
* a container, `cookie-cutter` for the Terraform remote state
* a key vault
* secrets for `cookie-cutter-client-id` and `cookie-cutter-client-secret`

> Note that the key vault ane storage account names are prefixes by the value of uniq. Change this to something that is unique to you before running.

These are then referenced by the backend.tf file.

## Azure Lighthouse

Two Lighthouse definitions are included. The only one required is the lighthouse_terraform.json.

### Customise

Customise the lighthouse_terraform.json with the objectId for your service principal.

1. Get the appId that links the App Registration to the service principal:

    ```bash
    appId=$(az ad app list --display-name "http://terraform" --query [0].appId --output tsv)
    ```

1. Display the objectId for the service principal:

    ```bash
    az ad sp show --id $appId --query id
    ```

1. Add as the default parameter value in the template
1. Customise the tenantId and the cosmetic descriptions
1. Save

## Create and assign

The following steps are performed by an account in the customer subscription with the appropriate permissions.

1. Add an offer

    Open the [service providers offers](https://portal.azure.com/#view/Microsoft_Azure_CustomerHub/ServiceProvidersBladeV2/~/providers) portal page.

    Click on __+ Add offer__ and select __Add via template__.

    Browse to your modified Lighthouse template and __upload__.

1. Delegate

    Open the [Delegations](https://portal.azure.com/#view/Microsoft_Azure_CustomerHub/ServiceProvidersBladeV2/~/scopeManagement) portal page.

    Click on __+ Add__, select the correct offer and delgate the subscription scope

    Note the subscription ID

## Module call in main.tf

The module (./module/cookie) is simple. Its role is to quickly create a resource group and an SSH key to prove that the same resources can be stamped out in multiple target subscriptions.

Example call:

```hcl
module "customer_subscription_alias" {
  source    = "./module/cookie"
  providers = { azurerm = azurerm.customer_subscription_alias }
}
```

> The provider map effectively replaces the azurerm provider in the module/cookie/provider.tf with the passed value.

## provider.tf

The [aliased provider block](https://www.terraform.io/language/providers/configuration#alias-multiple-provider-configurations) must be found in the config. In this example they are consolidated in the ./provider.tf file. E.g.:

```hcl
provider "azurerm" {
  features {}
  alias           = "citadel"
  subscription_id = "2d31be49-d959-4415-bb65-8aec2c90ba62"

  tenant_id     = local.managed_service_provider_tenant_id
  client_id     = data.azurerm_key_vault_secret.client_id.value
  client_secret = data.azurerm_key_vault_secret.client_secret.value
}
```

The section that differs by customer_subsscription_alias are the alias value and the subscription_id. Customise blocks as required for your environment.

Note the credentials (tenant_id, client_id, client_secret) relate to the service principal in the MSP tenant. Set the tenant_id in the locals to your MSP tenant ID.

## CI/CD notes

If you are using something similar in a CI/CD pipeline such as GitHub Actions then you would commonly store the service principal credentials in the environment variables.

## Making it more elegant

...is difficult. You cannot use variables or functions for the provider alias value, so constructs such as for_each do not work.

You could reorganise the .tf files, and change to a file per customer, containing both the aliased provider plus the module call. Adding a new customer would then simply require duplicating an existing file and customising with a new alias name and subscription_id value.

You could upvote the open issue, [Ability to pass providers to modules in for_each](https://github.com/hashicorp/terraform/issues/24476).

Or you could use the excellent [terragrunt example](https://github.com/hashicorp/terraform/issues/24476#issuecomment-619450972) in the same issue to generate the .tf files in a large environment.
