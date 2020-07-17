---
title: ARMDeployment
layout: template
filename: armdeployment
---

## Breakdown of ARM Deployment to Setup Azure DevOps
To understand the first of the two major deployments in the WVD Quickstart, the ARM deployment that configures the Azure DevOps automation and deploys some supporting resources, let's dive into the ARM template itself.

### Parameters
```
"parameters": {
    "utcValue": {
        "type": "string",
        "defaultValue": "[utcNow()]"
    },
    "existingVnetName": {
        "type": "string",
        "metadata": {
            "description": "The name of the virtual network the VMs will be connected to."
        }
    },
    "existingSubnetName": {
        "type": "string",
        "metadata": {
            "description": "The subnet the VMs will be placed in."
        }
    },
    "virtualNetworkResourceGroupName": {
        "type": "string",
        "metadata": {
            "description": "The resource group containing the existing virtual network."
        }
    },
    "computerName": {
        "type": "string",
        "metadata": {
            "description": "The name of the VM with the domain controller."
        }
    },
    "azureAdminUpn": {
        "type": "string",
        "metadata": {
            "description": "The UPN of the account that you're currently logged in with on the Azure Portal. This account should at least have the 'contributor' or 'owner' role on the subscription level for the deployment to succeed. The template will fail if you enter a user account that requires MFA."
        }
    },
    "azureAdminPassword": {
        "type": "securestring",
        "metadata": {
            "description": "The password that corresponds to the Azure admin UPN above."
        }
    },
    "tenantAdminDomainJoinUPN": {
        "type": "string",
        "metadata": {
            "description": "The template will fail if you enter a user account that requires MFA or an application that is secured by a certificate. The UPN or ApplicationId must be an RDS Owner in the Windows Virtual Desktop Tenant to create the hostpool or an RDS Owner of the host pool to provision the host pool with additional VMs."
        }
    },
    "tenantAdminDomainJoinPassword": {
        "type": "securestring",
        "metadata": {
            "description": "The password that corresponds to the tenant admin UPN."
        }
    },
    "identitySolution": {
        "type": "string",
        "metadata": {
            "description": "Specify which identity solution you would like to use for your WVD deployment. Pick either AD (Active Directory Domain Services) or AADDS (Azure Active Directory Domain Services)"
        },
        "allowedValues": [
            "AD",
            "AADDS"
        ]
    },
    "optionalNotificationEmail": {
        "type": "string",
        "metadata": {
            "description": "If desired, you can provide an email address to which we'll send a notification once your WVD deployment completes. DevOps will, by default, attempt to send an email to your Azure account, regardless of whether you provide a value here."
        },
        "defaultValue": "[parameters('azureAdminUpn')]"
    }
}
```

### Variables
```
"variables": {
    "_artifactsLocation": "https://raw.githubusercontent.com/samvdjagt/dev/master",
    "AdminPasswordSecret": "adminPassword",
    "existingDomainUsername": "[first(split(parameters('tenantAdminDomainJoinUPN'), '@'))]",
    "existingDomainName": "[split(parameters('tenantAdminDomainJoinUPN'), '@')[1]]",
    "identityName": "WVDServicePrincipal",
    "location": "[resourcegroup().location]",
    "rgName": "[resourcegroup().name]",
    "keyvaultName": "[concat('keyvault', parameters('utcValue'))]",
    "assetsName": "[concat('aset', toLower(parameters('utcValue')))]",
    "profilesName": "[concat('prof', toLower(parameters('utcValue')))]",
    "autoAccountName": "[concat('auto', toLower(parameters('utcValue')))]",
    "uniquestr": "[uniqueString(resourceGroup().id, deployment().name)]",
    "runbookName": "[concat('wvdrunbook','-',variables('uniquestr'))]",
    "subnet-id": "[resourceId(parameters('virtualNetworkResourceGroupName'), 'Microsoft.Network/virtualNetworks/subnets', parameters('existingVnetName'), parameters('existingSubnetName'))]",
    "tenantId": "[subscription().tenantId]",
    "uniqueBase0": "[toLower(uniquestring(variables('identityName'), resourceGroup().id, parameters('utcValue'),'MSISetup'))]",
    "uniqueBase": "[toLower(uniquestring(variables('identityName'), resourceGroup().id, parameters('utcValue'),variables('autoAccountName')))]",
    "uniqueBase2": "[toLower(uniquestring(variables('identityName'), subscription().id, parameters('utcValue'),'devOpsSetup'))]",
    "newGuid0": "[guid(variables('uniqueBase0'))]",
    "newGuid": "[guid(variables('uniqueBase'))]",
    "newGuid2": "[guid(variables('uniqueBase2'))]",
    "scriptUri0": "[concat(variables('_artifactsLocation'),'/ARMRunbookScripts/configureMSI.ps1')]",
    "scriptUri1": "[concat(variables('_artifactsLocation'),'/ARMRunbookScripts/createServicePrincipal.ps1')]",
    "scriptUri2": "[concat(variables('_artifactsLocation'),'/ARMRunbookScripts/devopssetup.ps1')]",
    "devOpsName": "WVDQuickstart0715",   
    "devOpsProjectName": "WVDQuickstart0715",
    "targetGroup": "WVDTestUsers",
    "automationVariables": [
        {
            "name": "subscriptionid",
            "value": "[concat('\"',subscription().subscriptionId,'\"')]"
        },
        {
            "name": "accountName",
            "value": "[concat('\"',variables('autoAccountName'),'\"')]"
        },
        {
            "name": "AppName",
            "value": "[concat('\"',variables('identityName'),'\"')]"
        },
        {
            "name": "ResourceGroupName",
            "value": "[concat('\"',variables('rgName'),'\"')]"
        },
        {
            "name": "fileURI",
            "value": "[concat('\"',variables('_artifactsLocation'),'\"')]"
        },
        {
            "name": "orgName",
            "value": "[concat('\"',variables('devOpsName'),'\"')]"
        },
        {
            "name": "projectName",
            "value": "[concat('\"',variables('devOpsProjectName'),'\"')]"
        },
        {
            "name": "location",
            "value": "[concat('\"',variables('location'),'\"')]"
        },
        {
            "name": "adminUsername",
            "value": "[concat('\"',variables('existingDomainUsername'),'\"')]"
        },
                    {
            "name": "domainName",
            "value": "[concat('\"',variables('existingDomainName'),'\"')]"
        },
        {
            "name": "keyvaultName",
            "value": "[concat('\"',variables('keyvaultName'),'\"')]"
        },
        {
            "name": "assetsName",
            "value": "[concat('\"',variables('assetsName'),'\"')]"
        },
        {
            "name": "profilesName",
            "value": "[concat('\"',variables('profilesName'),'\"')]"
        },
        {
            "name": "tenantAdminDomainJoinUPN",
            "value": "[concat('\"',parameters('tenantAdminDomainJoinUPN'),'\"')]"
        },
        {
            "name": "computerName",
            "value": "[concat('\"',parameters('computerName'),'\"')]"
        },
        {
            "name": "existingVnetName",
            "value": "[concat('\"',parameters('existingVnetName'),'\"')]"
        },
        {
            "name": "existingSubnetName",
            "value": "[concat('\"',parameters('existingSubnetName'),'\"')]"
        },
        {
            "name": "virtualNetworkResourceGroupName",
            "value": "[concat('\"',parameters('virtualNetworkResourceGroupName'),'\"')]"
        },
        {
            "name": "targetGroup",
            "value": "[concat('\"', variables('targetGroup'),'\"')]"
        },
        {
            "name": "identitySolution",
            "value": "[concat('\"',parameters('identitySolution'),'\"')]"
        },
        {
            "name": "notificationEmail",
            "value": "[concat('\"',parameters('optionalNotificationEmail'),'\"')]"
        }
    ]   
},
```
