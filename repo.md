---
title: Repository
layout: template
filename: repo
---

## Repository Breakdown by file
On this page, you'll find an in-depth breakdown of all the files associated with the WVD Quickstart solution. This is intended for any advanced users who wish to customize the WVD Quickstart for their needs or to do some advanced troubleshooting. The GitHub repository consists of two branches:

* Master branch: All code required by the WVD Quickstart lives here
* gh-pages branch: All files required for the GitHub pages website are located here

The folder structure in the master branch is as follows:

* <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/ARMRunbookScripts" target="_blank">ARMRunbookScripts</a>: In this folder, a number of custom scripts are located that are run by the ARM deployment, either through an automation runbook or a deployment script.
  * <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/ARMRunbookScripts/static" target="_blank">/static</a>: In this folder, some PowerShell modules required by the above scripts are located
* <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/Modules/ARM" target="_blank">Modules/ARM</a>: This folder contains modular ARM templates that are called by the DevOps automation to deploy Azure resources. For every resource, there's a dedicated deploy.json file, as well as a parameters file, pipeline file, and a testing script. These files are generic and should typically not be modified.
* <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/QS-WVD" target="_blank">QS-WVD</a>: This folder contains many of the files associated with the DevOps pipeline. This folder is also where you'll do most of your customization. The pipeline.yml file is the main DevOps automation pipeline, and the variables.yml file is where the pipeline gets all its parameters. 
  * <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/QS-WVD/parameters" target="_blank">/parameters</a>: This folder is populated in the automation to store ARM deployment parameter files. 
  * <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/QS-WVD/scripts" target="_blank">/scripts</a>: This folder contains scripts that are called by the DevOps pipeline.
  * <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/QS-WVD/static" target="_blank">/static</a>: This folder contains the important appliedParameters.psd1 file (created in the inital ARM deployment). The parameters in this file are used for the deployment of your WVD resources, and changing the parameters here can be an easy way to customize your WVD deployment.
    * <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/QS-WVD/static/templates/pipelineinput" target="_blank">/templates/pipelineinput</a>: In here, all the ARM parameter file templates are located, which are populated in the automation based on the parameters in appliedParameters.psd1.
* <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/SharedDeploymentFunctions" target="_blank">SharedDeploymentFunctions</a>: This folder contains some scripts called by the DevOps automation pipeline to asssist in the deployment of certain resources.
* <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/Uploads" target="_blank">Uploads</a>: This folder contains the Custom Script Extensions that are installed on the newly deployed WVD VMs.
  * <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/Uploads/WVDScripts" target="_blank">/Scripts</a>: This folder contains the three different custom script extensions that are installed: Azure Files enablement, FSLogix configuration, and NotepadPlusPlus installation.
* <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/deploy.json" target="_blank">Deploy.json</a>: This is the ARM template used for the initial DevOps setup deployment.

### ARMRunbookScripts
* <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/ARMRunbookScripts/checkAzureCredentials.ps1" target="_blank">checkAzureCredentials.ps1</a>: This script makes sure that the entered Azure Admin credentials are correct. 
* <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/ARMRunbookScripts/configureMSI.ps1" target="_blank">configureMSI.ps1</a>: Script that configures the 'WVDServicePrincipal' managed identity in the deployment resource group to give it the *contributor* role on the subscription. This is needed to run deployment scripts in the main ARM template successfully.
* <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/ARMRunbookScripts/createDevopsPipeline.sh" target="_blank">createDevopsPipeline.sh</a>: This Azure CLI script creates and starts a DevOps pipeline in the newly created DevOps project.
* <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/ARMRunbookScripts/createServicePrincipal.ps1" target="_blank">createServicePrincipal.ps1</a>: This script creates the AAD application service principal used to create a service connection between the Azure subscription and the DevOps project. If the application already exists, this script will update the existing one with the right permissions.
* <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/ARMRunbookScripts/devopssetup.ps1" target="_blank">devopssetup.ps1</a>: This script makes a number of REST API calls to create a DevOps project, a service connection between the Azure Subscription and the DevOps project, to initialize the DevOps repository with all the required files, to set some permissions in DevOps, and to generate the main automation parameter files: appliedParmeters.psd1 and variables.yml.

#### <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/ARMRunbookScripts/static" target="_blank">ARMRunbookScripts/static</a>
The azuremodules.zip in this folder contains the following PowerShell modules:
* Az.Accounts
* Az.Automation
* Az.Keyvault
* Az.ManagedServiceIdentity
* Az.Resources
* Az.Websites
* AzureAD
If you want to use additional Powershell modules in your runbook scripts, you can add them to this zip folder and adapt the runbookscripts accordingly to install them.
The other two zip folder contain static files related to WVD SAAS.

### Modules/ARM
Every module in this folder follows the same folder structure:
* /Parameters: parameters file for the ARM template
* /Pipeline: .yml file that can be used to deploy this resource
* /Scripts: Usually empty, unless custom scripts are needed for the deployment of the resource
* /Tests: Script that validates the ARM template syntax
* deploy.json: ARM template used to deploy this resource
* readme.md: Readme for the specific module

One important module is <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/Modules/ARM/UserCreation" target="_blank">UserCreation</a>, as this folder contains the script <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/Modules/ARM/UserCreation/scripts/createUsers.ps1" target="_blank">createUsers.ps1</a> that is used in Native AD deployments to create a new user in on the domain controller through a custom script extension.

### QS-WVD
This is a crucial folder, as it contains the deployment parameters as well as the DevOps automation files. Directly in the folder you will find the <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/QS-WVD/pipeline.yml" target="_blank">pipeline.yml</a> and <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/QS-WVD/variables.template.yml" target="_blank">variables.template.yml</a> files, which are both further explained <a href="devops" target="_blank">here</a>. The remaining subfolders are explained below.

#### QS-WVD/parameters
While this folder only holds a Readme.MD file, it is used in the automation to store the WVD ARM deployment parameter files, and it should therefore not be deleted.

#### QS-WVD/scripts
This folder contains certain Powershell scripts that are invoked by the DevOps pipeline:

* <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/QS-WVD/scripts/Invoke-StorageAccountPostDeployment.ps1" target="_blank">Invoke-StorageAccountPostDeployment.ps1</a>: This script is used in the deployment of the Assets storage account (see <a href="devops" target="_blank">DevOps</a> to upload the required files for the WVD Virtual Machine Custom Script Extensions.
* <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/QS-WVD/scripts/New-PipelineParameterSetup.ps1" target="_blank">New-PipelineParameterSetup.ps1</a>: This script is called at the beginning of the DevOps pipeline (explained <a href="devops" target="_blank">here</a>) to generate the parameter files for the deployment of WVD resources.
* <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/QS-WVD/scripts/Update-WVDHostPool.ps1" target="_blank">Update-WVDHostPool.ps1</a> and <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/QS-WVD/scripts/Update-WVDHostPoolV2.ps1" target="_blank">Update-WVDHostPoolV2.ps1</a> are currently not used in the automation, but they can be used to update existing host pools with a new image.

#### QS-WVD/static

#### QS-WVD/static/templates/pipelineinput

### SharedDeploymentFunctions

### Uploads

#### Uploads/scripts

### <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/deploy.json" target="_blank">deploy.json</a>
This is the ARM template used for the initial deployment, which is explained in a high-level <a href="concepts" target="_blank">here</a> and in a detailed breakdown <a href="armdeployment" target="_blank">here</a>.
 
