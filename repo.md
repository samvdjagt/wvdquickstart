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
 * <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/Uploads/Scripts" target="_blank">/Scripts</a>: This folder contains the three different custom script extensions that are installed: Azure Files enablement, FSLogix configuration, and NotepadPlusPlus installation.
* <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/deploy.json" target="_blank">Deploy.json</a>: This is the ARM template used for the initial DevOps setup deployment.
 
