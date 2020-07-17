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
* QS-WVD: This folder contains many of the files associated with the DevOps pipeline. This folder is also where you'll do most of your customization. The pipeline.yml file is the main DevOps automation pipeline, and the variables.yml file is where the pipeline gets all its parameters. 
  * /parameters: This folder is populated in the automation to store ARM deployment parameter files. 
  * /scripts: This folder contains scripts that are called by the DevOps pipeline.
  * /static: This folder contains the important appliedParameters.psd1 file (created in the inital ARM deployment). The parameters in this file are used for the deployment of your WVD resources, and changing the parameters here can be an easy way to customize your WVD deployment.
    * /templates/pipelineinput: In here, all the ARM parameter file templates are located, which are populated in the automation based on the parameters in appliedParameters.psd1.
 * SharedDeploymentFunctions
 