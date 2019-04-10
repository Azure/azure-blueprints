# Using blueprints with Azure DevOps pipelines

When you reach a certain point of maturity, you will want to start running blueprint definition updates through a release pipeline to validate those changes. At a high level, this means we need to do the following:

1. Push the latest blueprint definition into Azure
2. Publish a `*.TEST` version of the blueprint (since we don't know if it works as expected yet)
3. Assign the blueprint to a test environment
4. If successful, publish a `*.STABLE` version

This directory has two scripts - `build.ps1` and `release.ps1` that collectively do these four steps.

While, this is more specific to Azure DevOps pipelines, the methodolgies and strategies apply just as well to any other release management tool.

## How to use this guide
The `azure-pipelines.yml` build pipeline definition has variables set up to do a full release on teh `101-boilerplate` blueprint. If you want to test a different blueprint, change the varaibles at the top of that file and [change your parameters and test environment](#to-configure-your-release-test) accordingly

## azure-pipelines.yml
This simply executes the below two powershell scripts in sequence. A couple of things to note about this pipeline definition, which is located at the root of this repo:
* It uses the standard powershell tasks, not the *Azure* powershell task.
* The `Az.Blueprint` module uses `Az` and does not support `AzureRM`, so uninstall the latter and replaces it with the former.
* At the moment, there is no cmdlet for publishing a blueprint, so the script generates a token and does a REST API `PUT` to publish a version of the blueprint. We are working on cmdlets for full CRUD operations on the blueprint definition.
* The `$(spnPass)` variable is saved as a secret in the `azureLoginDetails` variable group. **You will need to set this up.**
  
## build.ps1
This does steps 1 and 2 above. For the most part, this script is pretty straightforward, just update the $(blueprintName) variable accordingly.

## release.ps1
This does steps 3 and 4 above. You can choose to run this in a build pipeline or a release pipeline. If you are solely validating that the blueprint is working as expected, I recommend keeping it in build. If you are planning to do a rollout of a blueprint to dev -> QA -> pre-prod -> prod (or some equivalent), I would recommend using Release Pipelines and using some sort of validation between each release stage.

### To configure your release test ###
Each blueprint will have it's own parameters and their own "expected state" for what the environment should look like when it is applied. You will need to update lines `61` to `65` based on the parameters of the blueprint, and you will need to also account for what the test environment looks like between lines `50` and `56`

