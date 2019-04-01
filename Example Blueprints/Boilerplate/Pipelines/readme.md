# Managing blueprints in a release pipeline
When you reach a certain point of scale & automation, you will start to want to validate your blueprints when you push new code. This guide walks you through how to "build" and how to "release" a blueprint to deploy and validate the latest changes, as well as best practices for how you should think about managing bluerpints-as-code in a release pipeline.

## How to use this guide
This doc walks through how to set up an Azure DevOps pipeline with a "build" and "release" step. Though, at present, everything takes place in the "build" pipeline. It currently references the "Boilerplate" bluerpint in the root directory.

## Build.ps1
The build step does the following key items:
1. **Push a new blueprint definition to Azure**: When you push the blueprint to Azure, we do some basic validation to make sure the blueprint and the artifacts have a valid schema. Any invalid schemas will cause this step to fail.
2. **Publish a `*.TEST` version of this blueprint definition:** In order to assign a bluerpint (which we will do in `release.ps1`) we need to publish a version. Since we don't know if this blueprint will successfully deploy, we publish it as a `*.TEST` version. We also do some validation on publish. For example, we check that all of the dependencies and parameter references resolve correctly. If the blueprint definition fails to publish, the build fails. 

## Release.ps1
The release step does the following key items:
1. **Assign the blueprint to a test environment**: In order to test if a blueprint definition is "valid" we assign it to a test subscription. The script waits in a `while` loop until the blueprint assignment reaches a terminal state. Obviously, if this blueprint fails to deploy, the step will fail.
2. **Publish a `*.STABLE` version of this blueprint definition:** If the blueprint is assigned successfully, we know that it is a "stable" blueprint definition. Now that we know this, we can publish a `*.STABLE` version of the blueprint. This should always succeed since we successfully published a `*.TEST` version in `build.ps1`.


## Caveats
Since blueprints is still in preview, there are still some loose ends and gotchas that you should be aware of.

* Since there are no cmdlets in `Az.Blueprint` for importing the blueprint definition, we are taking advantage of the [`Manage-AzureRMBlueprint`]() script for importing the blueprint in the `build.ps1` script.
* Since neither `Az.Blueprint` nor `Manage-AzureRMBlueprint` have support for publishing a version, we are doing that manually with the API in both `build.ps1` and `release.ps1`, so you will see code in both scripts for aquiring a auth token for talking to the Blueprints REST API. We are currently working on cmdlets for this.
* Since the `Az.Blueprint` module only supports the `Az` module, we are uninstalling `AzureRM` and replacing it with `Az`.
* We are not using the the Azure powershell tasks, so we are setting up the Service Principal (SPN) manually. At some point, we will move this to use Azure powershell task with a service connection.
* This `azure-pipelines.yml` file was set up in the context of a different repo with a different directory structure. So this will not "just work" if you use this repo in a DevOps pipeline.
* The pipeline makes use of a DevOps Pipeline Library called `azureLoginDetails` to pass in build variables (including secrets) such as `${subscriptionId}`. You will need to create this Library yourself.

