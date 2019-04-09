# Using sample blueprints

This directory contains sample blueprints made by both the community and Microsoft. They are organized by level (101, 201, etc.)

In order to use one of these samples, do the following:

1. Clone the repo or copy the directory with the sample you want. For example, if you want to use `201-AppNetwork` blueprint you should grab the entire `201-AppNetwork` directory.
2. Push the blueprint into your tenant with the [`Manage-AzureRMBlueprint.ps1`](https://www.powershellgallery.com/packages/Manage-AzureRMBlueprint) script and the following command:
    ```powershell
    Manage-AzureRMBlueprint -mode Import -ImportDir ".\" -ManagementGroupID "ManagementGroupId"
    ```
    **NOTE**: You may need to add the parameter `-ModuleMode Az` if you are using `Az` instead of `AzureRM`

3. Publish the blueprint in the portal by navigating to that blueprints details (all services -> blueprints -> blueprint definitions -> <YOUR BLUEPRINT>) and clicking `publish` in the action bar.
4. Assign the blueprint from the same screen or use the [`Az.Blueprint`](https://www.powershellgallery.com/packages/Az.Blueprint) powershell module, or [deploy the assignment with an ARM template](../assign-blueprint//as-template-deployment).


That's it. Isn't that easy?

# Contributing

If you'd like to add a sample, please fork the repo, add your new sample and submit a PR.