# Overview

Built-In blueprints are static blueprint definitions available to **all** customers (ie: global resources) that are intended to be used as "templates" when creating new blueprint definitions via the UI. They cannot be assigned directly, and are read-only due to their global nature.

Built-In blueprints are checked into the Blueprint source repository and deployed with our resource provider, and can be accessed using the REST API via the endpoint "/providers/Microsoft.Blueprint/blueprints". Because they are static embedded resources, the process for introducing new built-in blueprints is highly specific, and is described within this document.

## Prerequisites

 - Read/write access to the Blueprint GIT repository
 - A local enlistment to the Blueprint GIT repository
 - Fundamental GIT knowledge
 - Visual Studio installed locally

# Authoring New Built-In Blueprints

The process for the actual creation of blueprints intended for built-in use is the same as any other blueprint with the following exceptions:

- They CANNOT refer to any scope specific resources (custom policies, etc.)
- The display name for the blueprint should not exceed 25 characters (ensures optimal UI appearance)
- The description for the blueprint should not exceed 80 characters (ensures optimal UI appearance)

They can be created in the UI or via the REST API, and as long as the above exceptions hold true, any valid blueprint can be used as a built-in blueprint. They should however be blueprints that show common practices that would be useful as templates for users (highly specific blueprints are discouraged as built-ins).

## Testing Blueprints as Built-Ins

Prior to checking-in blueprint definitions as built-ins it is **required** that they be tested by using a UI feature allowing templates (built-ins) to be pulled from a Management Group instead of the backend. To use this feature it's recommended you create a new MG specifically used for testing potential built-ins (internally the team uses "AzBlueprintBuiltIns") and then store/edit your built-in definitions there. You can then test these templates by using the portal URL format:

*https://<span></span>ms.portal.azure.<span></span>com/?Microsoft_Azure_Policy_privacy=true&Microsoft_Azure_Policy_Blueprints=true&feature.builtInBlueprints_DevMG=**{YOUR_MG_NAME_HERE}**&feature.builtInBlueprints=true#blade/Microsoft_Azure_Policy/BlueprintsMenuBlade/Blueprints*

For example if you were using AzBlueprintBuiltIns for the test MG, you'd use the following link:

https://ms.portal.azure.com/?Microsoft_Azure_Policy_privacy=true&Microsoft_Azure_Policy_Blueprints=true&feature.builtInBlueprints_DevMG=AzBlueprintBuiltIns&feature.builtInBlueprints=true#blade/Microsoft_Azure_Policy/BlueprintsMenuBlade/Blueprints

After navigating to the link, performing a "Create Definition" action under blueprints will show the template selection UI using blueprints pulled from your MG. The following validations must be performed via this feature at a **minimum**:

1. Validate the title/description shown in the sample/built-in selection UI are appropriate for customer use
2. Validate you can create/edit a new definition using your sample blueprint.
3. Validate you can successfully assign a blueprint created from your sample blueprint.
4. Validate the deployment of your blueprint succeeds and all resulting resources are in their expected states.
5. Validate that you can successfully upgrade/update your blueprint assignment.

If all looks good, you're ready to begin the check-in process.

## Checking-In the Blueprint/Artifact Definitions

The definitions for built-in blueprints and their artifacts are stored under "src\BlueprintSamples\BlueprintSamples\BuiltInBlueprints" within the [Blueprint GIT repository](https://dev.azure.com/msazure/One/_git/Mgmt-Governance-Blueprint). The file/folder structure is:

- BuiltInBlueprints\{blueprintName}
    - Blueprint definition: BuiltInBlueprints\{blueprintName}\blueprint.json
    - Artifact definitions:  BuiltInBlueprints\{blueprintName}\artifact.{artifactName}.json

The JSON files are the equivalent to the GET responses returned for the blueprint and artifacts when using the latest API version.

**Note:** Prior to performing the steps to add a new built-in blueprint to the repository, you should sync with the latest master Blueprint branch and create your own local branch specifically for the built-in blueprint addition, for example "youralias/newbuiltins".

## Obtaining and prepping definition JSON for check-in

1. Create a new folder: src\BlueprintSamples\BlueprintSamples\BuiltInBlueprints\{yourBlueprintName}

   **Note:** The folder name must match the name of the blueprint within the definition
2. Perform an HTTP GET request against your blueprint (you can use [armclient](https://github.com/projectkudu/ARMClient) for this) . For example: "armclient GET /providers/Microsoft.Management/managementGroups/**{YourMGName}**/providers/Microsoft.Blueprint/blueprints/**{YourBlueprintName}**?api-version=2018-11-01-preview"
   - Modify the returned JSON to have the appropriate ID for the built-in. Basically any MG/subscription scope paths will need stripped out. For example:

     *"id": "<span style='color:red'>/providers/Microsoft.Management/managementGroups/AzBlueprintBuiltIns/</span>providers/Microsoft.Blueprint/blueprints/networking-vnet"*

     Would become:

     *"id": "/providers/Microsoft.Blueprint/blueprints/networking-vnet"*

   - Save the JSON as BuiltInBlueprints\{blueprintName}\\**blueprint.json**
 
3.	For each artifact in the blueprint, perform a GET request and obtain the returned JSON
    -  Modify the ids for each artifact like you did in the previous step for the blueprint definition (strip out any subscription/MG scope information).
    
    - Save the JSON for each artifact as BuiltInBlueprints\{blueprintName}\**artifact**.{artifactName}.**json**
    **Note:** The artifactName **must** match the artifact name within the json

At this point you have all the definition files you'll need for the check-in, but you'll still need to trigger a local build to prep the definitions for localization.

## Performing a local build to prep the built-in for localization

When you perform a local build with a new built-in blueprint definition present, a tool will be executed to update the ".resx" file for the built-in blueprints to allow for future localization. This is a step that is **required** prior to submitting your changes to the master branch via a PR.

To perform a local build, open a new Blueprints GIT/repo environment command prompt and from the root execute the following command line: *"msbuild dirs.proj"*

After the build completes, execute a "git status" and you should see that the "src\BlueprintSamples\BlueprintSamples\BuiltInBlueprintResources.resx" file has been modified. It's recommended that you compare the new changes with the previous file state to ensure the expected localizable strings are present within the file.

## Update BuiltInOwnerMappings.md

Within the Blueprints repository is a file that contains a mapping of specific built-in blueprints to their relevant owning team. It is located at "src\BlueprintSamples\BlueprintSamples\BuiltInOwnerMappings.md" and you **must** update it to include your new built-in's team association as part of your PR.

## Local testing
 
It is **highly recommended** that you load the Blueprint solution within Visual Studio and execute all of the UnitTests prior to submitting a PR. There are numerous tests to validate built-in blueprints can be retrieved as expected. 
 
If you choose not to run the unit tests locally they will still run as part of the build verification after you create your PR request.

## Submitting the PR

After all the previous steps have been completed you can to submit the PR with your new built-in blueprint! Within the PR text please provide us with the following information as well:

* Whether the built-in is supported in Fairfax (if it is not, the Blueprints team will need to create an additional PR in our UX branch that disables the built-in in Fairfax). **Note**: If you claim support for the blueprint in Fairfax you MUST test it within that environment before submitting your blueprint PR.
* The Azure resource IDs of one or more successful blueprint assignments created during your validation testing (as described in the "Testing Blueprints as Built-Ins" section of this document). **Alternatively** you can provide us with screenshot(s) of your successful assignment(s), but please note to do this you'll need to create the PR without the screenshots first via DevOps (visualstudio.com) and then immediately edit it afterwards to include the screenshots (pasting screenshots into PRs does not work during PR creation, but *does work* when editing PRs).
* The names/aliases of the PM(s) on your team who have reviewed and signed off on your blueprint.

### What the PR reviewer will look at
The following items are a check list of what the reviewer of the Blueprint PR will look at. The code review will go more smoothly if you verify and fix these before submitting the PR.
* Do the artifacts/blueprints have the "id" property? And are they tenant level IDs that start with `/providers/Microsoft.Blueprint/blueprints/...`? If these are missing it means you have not run the built-in export/preparation script against your blueprints and should do so before submitting the PR.
* Does the blueprint have an appropriate display name/description present? Are they relatively short? If not, they should be as there is limited space to render them in the Portal.
* Are the display names for artifacts user friendly? If not, they should be. 
* Did you specify "Preview" in display names for policies? If yes, please remove it. The blueprint display names for policies will not automatically update when the policy goes out of preview.
* Have you specified the information necessary for the corresponding UI update in your PR description? Which icons hould be used? Which environments (Public or Fairfax) is the blueprint supported in? What should the aka.ms link be? If not, please provide this information before submitting the PR.
* Did you update BuiltInOwnerMappings.md to include your new built-in?

## Built-In Availability

New built-ins become available to customers when the Resource Provider binaries built with your changes are deployed to production. If you lack access to create deployments (currently limited to internal Blueprints team members only), you can start a mail thread with the Blueprint team (unizomb@microsoft.com) to track progress of deployments containing your changes. Deployments can also be tracked here:

* **Prod**: https://msazure.visualstudio.com/One/_release?view=mine&definitionId=3583
* **Dogfood**: https://msazure.visualstudio.com/One/_release?view=mine&definitionId=6851
 
Prior to production deployments, it is required that new built-ins are verified to work as expected in the dogfood portal/azure environment.

