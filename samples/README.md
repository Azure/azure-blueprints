# Using sample blueprints

This directory contains sample blueprints made by both the community and Microsoft. They are organized by level (101, 201, etc.)

In order to use one of these samples, do the following:

1. Clone the repo or copy the directory with the sample you want. For example, if you want to use `201-AppNetwork` blueprint you should grab the entire `201-AppNetwork` directory.
2. Push the blueprint into your tenant with the [`Az.Blueprint powershell module`](https://powershellgallery.com/packages/Az.Blueprint/) cmdlet and the following command:
    ```powershell
    Import-AzBlueprintWithArtifact -Name "201-AppNetwork" -ManagementGroupId "root" -InputPath "./samples/201-AppNetwork"
    ```

3. From here, you can publish and assign ([portal](https://docs.microsoft.com/en-us/azure/governance/blueprints/create-blueprint-portal#assign-a-blueprint) | [powershell](https://docs.microsoft.com/en-us/azure/governance/blueprints/how-to/manage-assignments-ps) | arm template) the sample.


That's it!

# Contributing

If you'd like to add a sample, please fork the repo, add your new sample and submit a PR.