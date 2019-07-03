<!-- 
Version 2.0 
Last edited: 7-3-19
-->
# Managing Blueprints as Code

Using the Blueprints in the Azure Portal is a great way to get started with Blueprints or to use Blueprints on a small-ish scale, but often you’ll want to manage your Blueprints as code for a variety of reasons, such as:
* Sharing blueprints
* Keeping blueprints in source control
* Putting blueprints in a CI/CD or release pipeline


## Table of Contents
  - [Prerequisites](#prerequisites)
  - [How to use this guide](#how-to-use-this-guide)
  - [Quickstart](#quickstart)
  - [Structure of blueprint artifacts](#structure-of-blueprint-artifacts)
    - [Blueprint folder](#blueprint-folder)
    - [Functions](#functions)
    - [Blueprint](#blueprint)
    - [Resource Group properties](#resource-group-properties)
    - [Artifacts](#artifacts)
    - [How Parameters work](#how-parameters-work)
    - [Passing values between artifacts](#passing-values-between-artifacts)
    - [Sequencing the deployment of artifacts](#sequencing-the-deployment-of-artifacts)
  - [Push the Blueprint definition to Azure](#push-the-blueprint-definition-to-azure)
  - [Next steps](#next-steps)
  - [Contributing](#contributing)

## Prerequisites

This doc assumes you have a basic understanding of how blueprints work. If you've never used Blueprints before, this will be a little overwhelming. We recommend you build your first blueprint with the UI to understand how everything works. You can try it at [aka.ms/getblueprints](https://aka.ms/getblueprints) and learn more about it in the [docs](https://docs.microsoft.com/en-us/azure/governance/blueprints/overview) or watch this [15 minute overview](https://www.youtube.com/watch?v=cQ9D-d6KkMY).

**Download the [Az.Blueprint module](https://powershellgallery.com/packages/Az.Blueprint/) from the powershell gallery:**

```powershell
Install-Module -Name Az.Blueprint
```

## How to use this guide
This guide references the files in the [samples/101-boilerplate directory](https://github.com/Azure/azure-blueprints/tree/master/samples/101-boilerplate) and deploys the Boilerplate blueprint as a draft definition to Azure.

## Quickstart
Push a sample blueprint definition to Azure:
```powershell
Import-AzBlueprintWithArtifact -Name Boilerplate -ManagementGroupId "DevMG" -InputPath  ".\samples\101-boilerplate"
```

Publish a new version of that definition so it can be assigned:
```powershell
# Get the blueprint we just created
$bp = Get-AzBlueprint -Name Boilerplate -ManagementGroupId "DevMG"
# Publish version 1.0
Publish-AzBlueprint -Bluerpint $bp -Version 1.0
```

Assign the blueprint to a subscription:
```powershell
# Get the version of the blueprint you want to assign, which we will pas to New-AzBlueprintAssignment
$publishedBp = Get-AzBlueprint -ManagementGroupId "DevMG" -Name "Boilerplate" -LatestPublished

# Each resource group artifact in the blueprint will need a hashtable for the actual RG name and location
$rgHash = @{ name="MyBoilerplateRG"; location = "eastus" }

# all other (non-rg) parameters are listed in a single hashtable, with a key/value pair for each parameter
$parameters = @{ principalIds="caeebed6-cfa8-45ff-9d8a-03dba4ef9a7d" }

# All of the resource group artifact hashtables are themselves grouped into a parent hashtable
# the 'key' for each item in the table should match the RG placeholder name in the blueprint
$rgArray = @{ SingleRG = $rgHash }

# Assign the new blueprint to the specified subscription (Assignment updates should use Set-AzBlueprintAssignment
New-AzBlueprintAssignment -Blueprint $publishedBp -Location eastus -SubscriptionId "00000000-1111-0000-1111-000000000000" -ResourceGroupParameter $rgArray -Parameter $parameters
```

## Structure of blueprint artifacts
A blueprint consists of the main blueprint json file and a series of artifact json files. Simple 😊

So you will always have something like the following:

```
Blueprint directory (also the default blueprint name)
* blueprint.json
* artifacts
    - artifact.json
    - ...
    - more-artifacts.json
```

### Blueprint folder
Create a folder or directory on your computer to store all of your blueprint files. **The name of this folder will be the default name of the blueprint** unless you specify a new name in the blueprint json file.

### Functions
We support a variety of expressions that can be used in either a blueprint defintion or artifact such as `concat()` and `parameters()`. For a full reference of functions and how to use them, you can look at the [Functions for use with Azure Blueprints](https://docs.microsoft.com/en-us/azure/governance/blueprints/reference/blueprint-functions) doc.

### Blueprint
This is your main Blueprint file. In order to be processed successfully, the blueprint must be created in Azure before any artifacts (policy, role, template) otherwise the calls to push those artifacts will fail. That's because the **artifacts are child resources of a blueprint**. The `Az.Blueprint` module takes care of this for you automatically. Typically, you will name this blueprint.json, but this name is up to you and customizing this will not affect anything.


Let's look at our Boilerplate sample ```blueprint.json``` file:
```json
{
    "properties": {
        "description": "This will be displayed in the essentials, so make it good",
        "targetScope": "subscription",
        "parameters": { 
            "principalIds": {
                "type": "string",
                "metadata": {
                    "displayName": "Display Name for Blueprint parameter",
                    "description": "This is a blueprint parameter that any artifact can reference. We'll display these descriptions for you in the info bubble",
                    "strongType": "PrincipalId"
                }
            },
            "genericBlueprintParameter": {
                "type": "string"
            }
        },
        "resourceGroups": {
            "SingleRG": {
                "description": "An optional description for your RG artifact. FYI location and name properties can be left out and we will assume they are assignment-time parameters",
                "location": "eastus"
            }
        }
    },
    "type": "Microsoft.Blueprint/blueprints" 
}
```
Some key takeaways to note from this example:
* There are two optional blueprint `parameters`:
    - ```principalIds``` and ```genericBlueprintParameter```. 
    - These parameters can be referenced in any artifact.
    * The `principalIds` parameter uses a `strongType` property which loads a helper UI in the portal when this blueprint is assigned.
* The ```resourceGroups``` artifacts are declared here, not in their own files.


### Resource Group properties
You'll notice the **resource group artifacts are defined within the main blueprint json file**. In this case, we've configured a resource group with these properties: 
 * Hardcodes a location for the resource group of ```eastus```
 * Sets a *placeholder* name ```SingleRG``` for the resource group. 
     - The resource group is not created yet, that will be determined at assignment time. The placeholder is just to help you organize the definition and serves as a reference point for your artifacts.
     - Optionally you could hardcode the resource group name by adding `"name": "myRgName"` as a child property of the `SingleRG` object.

[Full spec of a blueprint](https://docs.microsoft.com/en-us/rest/api/blueprints/blueprints/createorupdate#blueprint)

### Artifacts

Let’s look at the Boilerplate `policyAssignment.json` artifact:
```json
{
    "properties": {
        "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/a451c1ef-c6ca-483d-87d-f49761e3ffb5",
        "parameters": {},
        "dependsOn": [],
        "displayName": "My Policy Definition that will be assigned (Currently auditing usage of custome roles)"
    },
    "kind": "policyAssignment",
    "type": "Microsoft.Blueprint/blueprints/artifacts"
}
```

All artifacts share common properties:
* The `Kind` can be:
    - `template`
    - `roleAssignment`
    - `policyAssignment`
* `Type` – this will always be: `Microsoft.Bluprint/blueprints/artifacts`
* `properties` – this is what defines the artifact itself. Some properties of `properties` are common while others are specific to each type.
    - Common properties
        - `dependsOn` - optional. You can declare dependencies to other artifacts by referencing the artifact name (which by default is the filename without `.json`). More info [here](https://docs.microsoft.com/en-us/azure/governance/blueprints/concepts/sequencing-order#customizing-the-sequencing-order).
        - `resourceGroup` – optional. Use the resource group placeholder name to target this artifact to that resource group. If this property isn't specified it will target the subscription.

Full spec for each artifact type:

* [Policy Assignment](https://docs.microsoft.com/en-us/rest/api/blueprints/artifacts/createorupdate#policyassignmentartifact)
* [Role Assignment](https://docs.microsoft.com/en-us/rest/api/blueprints/artifacts/createorupdate#roleassignmentartifact)
* [Template](https://docs.microsoft.com/en-us/rest/api/blueprints/artifacts/createorupdate#templateartifact)

### How Parameters work
Nearly everything can be parameterized. The only things that can't be parameterized are the `roleDefinitionId` and `policyDefinitionId` in the `rbacAssignment` and `policyAssignment` artifacts respectively.
Parameters are defined in the main blueprint file and can be referenced in any artifact. 

Here's a simple parameter declaration which is a simplified version from `blueprint.json`:

```json
"parameters": { 
    "genericBlueprintParameter": {
        "type": "string"
    }
}
```
You can use the same properties you can in an ARM template like `defaultValue`, `allowedValues`, etc.

And we can reference a parameter like this:
```json
"properties": {
    "genericBlueprintParameter": "[parameters('principalIds')]",
}
```

This gets a little complicated when you want to pass those variables to an artifact that, itself, also has parameters. 

First, in `template.json` we need to set the *artifact* parameter value `myTemplateParameter` to have a `value` of `genericBlueprintParameter` which is our *blueprint* parameter:
```json
"properties": {
    "parameters": {
        "myTemplateParameter": {
            "value": "[parameters('genericBlueprintParameter')]"
        }
    }
}
```

This should look familiar if you've [passed parameters inline to a nested deployment](http://google.com). Instead of getting these parameter values from a file, we are getting them from the list of blueprint parameters.   

And then you can reference that parameter within the `template` section in `template.json` like this:
```json
"template": {
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "myTemplateParameter": {
            "type":"string"
        }
    },
},
```

This shouldn't require any modification of your arm templates.

You can also use the `New-AzBlueprintArtifact` cmdlet to convert a standard ARM template into a bluerpint artifact:

```powershell
New-AzBlueprintArtifact -Type TemplateArtifact -Name storage-account -Blueprint $bp -TemplateFile C:\StorageAccountArmTemplate.json -ResourceGroup "storageRG" -TemplateParameterFile "C:\StorageAccountParams.json"
```

### Passing values between artifacts
There are many reasons you may want or need to pass the output from one artifact as the input to another artifact that is deployed later in the blueprint assignment sequence. If so, you can make use of the ```artifacts()``` function which lets you reference the details of a particular artifact.

Start by passing an [output](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-authoring-templates#outputs) in your template like this example where we are using the [reference](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-functions-resource#reference) function:

```json
{
    ...
    "outputs": {
        "storageAccountId": {
            "type": "string",
            "value": "[reference(variables('storageAccountName'), '2016-01-01', 'Full').resourceId]"
        }
    }
    ...
}
```

Then in another artifact, pass the artifact output into the next template as a parameter:

```json
{
    "kind": "template",
    "name": "vm-using-storage",
    "properties": {
        "template": {
            ...
        },
        "parameters": {
            "blueprintStorageId": {
                "value": "[artifacts('storage').outputs.storageAccountId]"
            }
        }
    },
    "type": "Microsoft.Blueprint/blueprints/artifacts"
}
```

Once you've done that, you can use that parameter anywhere in the `template` section of the artifact.


### Sequencing the deployment of artifacts

Often, you will want to run your templates in a specific order. For example, you may want to create a vnet before you create a vm. In that case, you can use the `dependsOn` property to take a dependency on another artifact. 

In this example, this template artifact `dependsOn` the `policyAssignment` artifact, so the policy will get assigned first:

```json
{
    "kind": "template",
    "properties": {
      ...
      "dependsOn": ["policyAssignment"],
      ...
    }
}
```


## Push the Blueprint definition to Azure
```powershell
Import-AzBlueprintWithArtifact -Name Boilerplate -ManagementGroupId "DevMG" -InputPath  ".\samples\101-boilerplate"
```

Now you should see a new blueprint definition in Azure. You can update the blueprint by simply re-running the above command.

That’s it!

You might run into some issues. Here are some common ones:
* **Missing a required property** – this will result in a 400 bad request. This could be a lot of things. Make sure your blueprint and artifacts have all required properties.
* **```parameters``` in an artifact are not found in the main blueprint file.** Make sure all parameter references are complete. If you are using a parameter in an artifact, make sure it is defined in the main `blueprint.json`
* **```policyDefinitionId``` or ```roleDefinitionId``` does not exist.** If you are referencing a custom policy make sure that custom policy exists at or above the management group where the blueprint is saved. Custom role definitions are currently not supported for management groups.
	
## Next steps
From here you will need to [publish the blueprint](https://docs.microsoft.com/en-us/azure/governance/blueprints/create-blueprint-portal#publish-a-blueprint) and then [assign the blueprint](https://docs.microsoft.com/en-us/azure/governance/blueprints/create-blueprint-portal#assign-a-blueprint) which you can do with either the azure portal or the rest API.

Let us know in the comments if you have any issues!

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

