# Assigning a blueprint via an ARM template

A blueprint assignment is a subscription level object, which means it can be deployed via an ARM template! Each template will have to be updated based on which blueprint is being assigned. In order to get this to work, the following parameters must be modified:

* **definitionLocationMG**: This template assumes the blueprint is saved at a management group. You will need to change this to your Management Group ID (not the name!). If the blueprint is stored at a subscription scope, you will need to change the `blueprintId` variable to:
 `/subscriptions/{subscriptionId}/providers/Microsoft.Blueprint/blueprints/{blueprintName}/{blueprintVersion}`
* **blueprintName**: The name of your blueprint definition object.
* **blueprintVersion**: The name of the published version of the blueprint definition that you want to assign.
* **blueprintsFirstPartySpnId**: If you are using a `systemAssigned` managed identity, the blueprints first party app will need owner permissions on the subscription. More info in our docs for how to retrieve this. I go to the Active Directory blade and in the **Find** section, change the dropdown to **EnterpriseApplication** and search for the App Id (f71766dc-90d9-4b7d-bd9d-4499c4331c3f), which is static across tenants, then go to the detail and get the ObjectId/PrincipalId. If you are using a `userAssigned` managed identity, you don't need to create the `roleAssignment` resource, but you will need to modify the blueprintAssignment resource accordingly.
* **blueprintParams**: These are the parameters you have created for your blueprint or for any artifacts in the blueprint.
* **blueprintRgs**: Each resource group artifact in a blueprint is a *placeholder*, so you need to provide the `name` and `location` for each RG in your blueprint, unless you have hardcoded those values in the definition.


## Using this template in a deployIfNotExists policy definition
It's common to want to assign the blueprint to a large set of Azure subscriptions. A great way to do this is with a deployIfNotExists policy, which can report any subscription that does not have a specific blueprint assignment and then **remediate** that subscription by deploying this ARM template.

