---
title: ARMDeployment
layout: template
filename: armdeployment
---

## Breakdown of ARM Deployment to Setup Azure DevOps
To understand the first of the two major deployments in the WVD Quickstart, the ARM deployment that configures the Azure DevOps automation and deploys some supporting resources, let's dive into the ARM template itself.

### Parameters
In the parameters section of the ARM template, you'll find all the parameters that are exposed to the user input. ALl of these parameters come with a description to indicate what they're used for. These are typically pretty straightforward and will not be explained further in this documentation.
```
"parameters": {
    "utcValue": {
        "type": "string",
        "metadata": {
            "description": "Please leave this value as '[utcNow()]', as this is used to generate unique names in the deployment. This is a requirement for resources like a keyvault or storage account."
        },
        "defaultValue": "[utcNow()]"
    },
    "existingVnetName": {
        "type": "string",
        "metadata": {
            "description": "The name of the virtual network the VMs will be connected to."
        }
    },
    ....
    ....
}
```

### Variables
The variables section holds certain values that are used throughout the deployment, that are not exposed to the user. As these are less obvious, their meaning and use will be explained in this section.
```
"variables": {
    "_artifactsLocation": "https://raw.githubusercontent.com/samvdjagt/dev/master",
```
The *artifactslocation* variable holds the URL to the GitHub repository that is used throughout the deployment to fetch required files. If you are to customize the solution in your own GitHub repository, you should provide the link to it here to make sure the deployment fetches the files from your repo. This repo has to be public for the deployment to work.
```
    "AdminPasswordSecret": "adminPassword",
```
The *AdminPasswordSecret* variable holds the name of the Keyvault secret in which the password of the domain join service account will be stored.
```
    "existingDomainUsername": "[first(split(parameters('tenantAdminDomainJoinUPN'), '@'))]",
    "existingDomainName": "[split(parameters('tenantAdminDomainJoinUPN'), '@')[1]]",
```
The *existingDomainUsername* and *existingDomainName* variables are both taken from the domain join service account UPN, where the domain name is used to perform the domain join of the virtual machines.
```
    "identityName": "WVDServicePrincipal",
```
The *identityName* variable holds the name of the managed identity that will be deployed in this template. This managed identity is then used to run certain deployment scripts.
```
    "location": "[resourcegroup().location]",
    "rgName": "[resourcegroup().name]",
```
The *location* variable will hold the location in which all WVD resources will be deployed. The *rgName* or resource group name holds the name of the resource group in which you're deploying.
```
    "keyvaultName": "[concat('keyvault', parameters('utcValue'))]",
    "assetsName": "[concat('aset', toLower(parameters('utcValue')))]",
    "profilesName": "[concat('prof', toLower(parameters('utcValue')))]",
    "autoAccountName": "[concat('auto', toLower(parameters('utcValue')))]",
```
The above variables hold the names of resources deployed in this template that require a unique identifier, in this case being a Keyvault, two Storage Accounts (the assets storage, which will hold the Modules/ARM folder, and the profiles storage for FSLogix), and an Automation Account.
```
    "uniquestr": "[uniqueString(resourceGroup().id, deployment().name)]",
    "runbookName": "[concat('wvdrunbook','-',variables('uniquestr'))]",
```
The *uniquestr* variable is used to generate a unique name for the runbooks used in this ARM template
```
    "tenantId": "[subscription().tenantId]",
```
The *tenantId* variable holds the ID of your AAD tenant.
```
    "uniqueBase0": "[toLower(uniquestring(variables('identityName'), resourceGroup().id, parameters('utcValue'),'MSISetup'))]",
    "uniqueBase": "[toLower(uniquestring(variables('identityName'), resourceGroup().id, parameters('utcValue'),variables('autoAccountName')))]",
    "uniqueBase2": "[toLower(uniquestring(variables('identityName'), subscription().id, parameters('utcValue'),'devOpsSetup'))]",
    "newGuid0": "[guid(variables('uniqueBase0'))]",
    "newGuid": "[guid(variables('uniqueBase'))]",
    "newGuid2": "[guid(variables('uniqueBase2'))]",
    "scriptUri0": "[concat(variables('_artifactsLocation'),'/ARMRunbookScripts/configureMSI.ps1')]",
    "scriptUri1": "[concat(variables('_artifactsLocation'),'/ARMRunbookScripts/createServicePrincipal.ps1')]",
    "scriptUri2": "[concat(variables('_artifactsLocation'),'/ARMRunbookScripts/devopssetup.ps1')]",
```
The above variables are used to create unique names for the runbook jobs that will be executed in this ARM deployment. The *scriptUri* variables hold the location of the three runbook scripts that will be run.
```
    "devOpsName": "WVDQuickstart0715",   
    "devOpsProjectName": "WVDQuickstart0715",
```
The above variables contain the name of the DevOps organization (*devOpsName*) and the DevOps project that will be created in this deployment.
```
    "targetGroup": "WVDTestUsers",
```
The *targetGroup* variable holds the name of the user group that will be assigned to the WVD environment.
```
    "automationVariables": [
        {
            "name": "subscriptionid",
            "value": "[concat('\"',subscription().subscriptionId,'\"')]"
        },
        {
            "name": "accountName",
            "value": "[concat('\"',variables('autoAccountName'),'\"')]"
        },
        ....
        ....
    ]   
},
```
The *automationVariables* section, which is not shown in full here, contains a list of variables and parameters that will be saved as variables in the Automation account that is created in this deployment. These variables will be accessed by the runbook scripts to generate the appropriate parameter files for the WVD deployment.

### Resources
