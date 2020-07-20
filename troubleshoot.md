---
title: Troubleshoot
layout: template
filename: troubleshoot
---

## WVD Quickstart Troubleshooting
In case you run into any issues while using the WVD Quickstart, this page might prove helpful to you. This page will cover certain common errors, as well as ways to solve them. Additionally, this page lists some known limitations of the solution.

### Known Limitations
* In the *userCreation* custom script extension, there's a small chance it will fail when trying to sync the newly created user to Azure AD, if a cync cycle is already running
* In the *userCreation* custom script extension, the profiles storage account will be joined to the domain using a new *computerAccount*. By default, this computerAccount will be created in the *Domain Controllers* Organizational Unit (OU). In case this OU doesn't exist in your environment, the script will fail. In that case, you would have to change this default in the createUsers.ps1 script in the Modules/ARM/UserCreation/scripts folder. For this customization, you'll have to clone this GitHub repository as explained in the <a href="customize">Customize</a> section.
* The WVD Quickstart cannot configure your native AD environment for you. You will have to have a virtual network and domain controller setup and synced to Azure AD (with AD Connect) as a prerequisite before deploying with the Quickstart.

### Invalid Configuration
A likely cause of a WVD Quickstart failure is if one or more of the <a href="howto">prerequisites</a> is either not present or incorrectly configured. While some of these are validated in the automation, these prerequisites are an absolute requirement in the configuration specified <a href="howto">here</a>.

### CheckAzureCredentials failed
If you get this error, it means that the deployment was unable to authenticate to your Azure account. Please make sure that the Azure Admin credentials you entered are correct and try to redeploy.

### Native AD: Creating Users
In case you are running a Native AD deployment, and the 'UserCreation' fails, there are a number of possible causes:

* Incorrect configuration of the domain controller VM: Please ensure that the VM is running and healthy, and that the RDAgent is installed and running on your domain controller VM
* There's another Custom Script Extension already installed on your domain controller VM: In this case, the userCreation will not be able to run. If possible, uninstall the existing custom script extension. Otherwise, create the user manually as explained below.
* A failure when running the <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/Modules/ARM/UserCreation/scripts/createUsers.ps1" target="_blank">createUsers.ps1</a> script: You could try and edit it to troubleshoot, but it might be easier to log on to your domain controller and create the user manually. Be sure to then assign that user to a Security Group with the same name as the variable 'targetGroup' in the main <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/deploy.json" target="_blank">deploy.json</a> and to sync this change to Azure with AD Connect. Your deployment will only work if the user is synced to Azure. If you go down this manual route, you do want to get rid of the 'UserCreation' deployment in the main deploy.json to avoid your deployment failing again.
