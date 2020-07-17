---
title: ARMDeployment
layout: template
filename: armdeployment
---

## Breakdown of ARM Deployment to Setup Azure DevOps
To understand the first of the two major deployments in the WVD Quickstart, the ARM deployment that configures the Azure DevOps automation and deploys some supporting resources, let's dive into the ARM template itself.

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
