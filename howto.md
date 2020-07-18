---
title: How-to
layout: template
filename: howto
---

## How To Deploy With The WVD Quickstart

### Prerequisites
In order to successfully deploy a WVD environment with the Quickstart, a couple of prerequisites need to be satisfied beforehand. All of these prerequisites are listed below, together with links to documentation that can help you with setting them up.
* An active <a href="https://azure.microsoft.com/en-us/" target="_blank">Azure subscription</a>
* A 
<a href="https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview" target="_blank">Windows Server Active Directory</a> (AD) in sync with <a href="https://azure.microsoft.com/en-us/services/active-directory/" target="_blank">Azure Active Directory</a> (AAD), configured with <a href="https://docs.microsoft.com/en-us/azure/active-directory/hybrid/how-to-connect-install-express" target="_blank">AD Connect</a>
* Sufficient <a href="https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-list-portal" target="_blank">administrator privileges</a> on your subscription: you will need the *contributor* or *owner* role at the minimum
* WVD resource provider is installed
* Domain join service account (Must be without MFA)
* Existing virtual network (VNET)
    * With an available subnet
    * With the DNS setting to *custom*
    * Domain join service account needs to have administrator privileges on the domain controller in this VNET
* Firewall configuration: ensure all the required ports are accessible to the WVD resource provider

### ARM Deployment: Azure DevOps Setup
Once you've satisfied all the prerequisites, you are ready to deploy using the Quickstart! As explained in the <a href="concepts">Concepts</a> section, the deployment consists of two main components: an Azure Resource Manager (ARM) deployment and an Azure DevOps (ADO) pipeline. The first of the two will deploy a number of resources supporting the deployment automation, including the creation of a DevOps project and automation pipeline. By clicking the "Deploy to Azure" button, you will be taken to the Azure Portal for a custom deployment. There, you can fill out the required user input and click *purchase*. 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https:%2F%2Fraw.githubusercontent.com%2Fsamvdjagt%2Fwvdquickstart%2Fmaster%2Fdeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a><br>

### WVD Deployment: DevOps Pipeline
Once the ARM deployment completes, your WVD environment will automatically be deployed by an Azure DevOps pipeline. To follow along with this deployment, navigate to <a href="https://dev.azure.com" target="_blank">Azure DevOps</a>, where you will find the WVD Quickstart project. Navigate to the "pipelines" section - Here you'll find a running pipeline that deploys a WVD environment (VMs, host pool, desktop app group, FSLogix configuration) for you. Upon completion of this pipeline, which will take about 20 minutes, your WVD environment is ready for use! You can also follow along with the deployment in the Azure Portal.

### Using Your New WVD Environment
The Quickstart creates a test user for you to try out the environment. Navigate to the <a href="https://rdweb.wvd.microsoft.com/arm/webclient/index.html" target="_blank">WVD web client</a> and login with the following test user credentials:

Username: WVDTestUser001@{your-domain}.com <br>
Password: wvdTest123!
