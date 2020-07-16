---
title: How-to
layout: template
filename: howto
---

### How To Deploy With The WVD Quickstart

#### Prerequisites
In order to successfully deploy a WVD environment with the Quickstart, a couple of prerequisites need to be satisfied beforehand. All of these prerequisites are listed below, together with links to documentation that can help you with setting them up.
* An active Azure subscription
* A Windows Server Active Directory (AD) in sync with Azure Active Directory (AAD), configured with AD Connect
* Sufficient administrator privileges on your subscription: *contributor* or *owner* at the minimum
* WVD resource provider is installed
* Domain join service account (Must be without MFA)
* Existing virtual network (VNET)
** With an available subnet
** With the DNS setting to *custom*
** Domain join service account needs to have administrator privileges on the domain controller in this VNET
* Firewall configuration: ensure all the required ports are accessible to the WVD resource provider

#### ARM Deployment: Azure DevOps Setup
By clicking the "Deploy to Azure" button, you will be taken to the Azure Portal for a custom deployment. There, you can fill out the required user input and click "deploy". This will set up some resources needed for the Quickstart, including an Azure DevOps organization and project.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https:%2F%2Fraw.githubusercontent.com%2Fsamvdjagt%2Fdev%2Fmaster%2Fdeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a><br>

#### WVD Deployment: DevOps Pipeline
Once the deployment completes, please navigate to <a href="https://dev.azure.com">Azure DevOps</a>, where you will find the WVD Quickstart project. Navigate to the "pipelines" section - Here you'll find a running pipeline that deploys a WVD environment (VMs, host pool, desktop app group, FSLogix configuration) for you. Upon completion of this pipeline, which will take about 20 minutes, your WVD environment is ready for use!

#### Using Your New WVD Environment
The Quickstart creates a test user for you to try out the environment. Navigate to the <a href="https://rdweb.wvd.microsoft.com/arm/webclient/index.html">WVD web client</a> and login with the following test user credentials:

Username: WVDTestUser001@{your-domain}.com <br>
Password: wvdTest123!
