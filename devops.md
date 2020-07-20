---
title: DevOps
layout: template
filename: devops
---

## Breakdown of the DevOps Automation
To understand the second of the two major deployments in the WVD Quickstart (for an overview, please see <a href="concepts">Concepts</a> section), the Azure DevOps pipeline that deploys a WVD environment for you, let's first take a look at <a href="https://dev.azure.com" target="_blank">Azure DevOps</a> itself.

### Understanding Azure DevOps
Azure DevOps is a very powerful platform and it therefore comes with a lot of possibilites and components. To understand the structure of the WVD Quickstart automation, we'll take a look at some of the aspects of DevOps. The main two features that we will make use of are the *Repos* and the *Pipelines*, both available in the left-side menu in your DevOps project (after running the initial ARM deployment, which creates this project). The *Repos* section will look like this:

![DevOps Repository](images/devopsRepo.PNG?raw=true)

This repository functions just like any other git repository. By default, it will be set to private and it holds all the files used by the WVD Quickstart to deploy a WVD environment for you. In this repository, you can do many of the customizations explained in the <a href="customize" target="_blank">Customize</a> section. The more exciting part of DevOps will be under the *Pipelines* section, which will look something like the image below:

![DevOps Pipeline Overview](images/devopsPipelineOverview.PNG?raw=true)

DevOps pipelines are very powerful tools that allow you to create custom build and/or release automization. In our case, the pipeline in the DevOps project takes care of the deployment of all WVD resources in an automated and repeatable way. The Quickstart uses only part of the pipeline functionalities, which are described in a high-level overview <a href="https://azure.microsoft.com/en-us/services/devops/pipelines/" target="_blank">here</a>. A pipeline is based on a *.yml* or *YAML* file, which in our case can be found in  QS-WVD/pipeline.yml - We will dive deeper into this file later. 

As you can see in the above image, one of the options in the Pipelines menu on the left is *Library*. A library can be used to store (secret) variable groups or files, that can hold values that can be accessed by the pipeline. In the WVD Quickstart case, the initial ARM deployment will create a variable group called *WVDSecrets*, which holds certain authentication credentials used by the pipeline to authenticate against Azure and agains the domain controller. 

#### Service Connection
Because Azure DevOps and the Azure Resource Manager are separate services, DevOps needs a way to authenticate with the Azure Resource Manager for it to get permission to deploy the WVD resources. To do so, the initial ARM deployment will create something called a *Service Connection*. You can find this service connection under your project settings -> Service Connections, and by default it will be called *WVDServiceConnection*.

### Understanding the Automation Pipeline
Now that you are a little more familiar of the DevOps structure, we can dive straight into our <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/QS-WVD/pipeline.yml" target="_blank">automation pipeline</a> itself. However, before doing so, it's recommended to familiarize yourself with the YAML pipeline file structure first, which you can do <a href="https://docs.microsoft.com/en-us/azure/devops/pipelines/yaml-schema?view=azure-devops&tabs=schema%2Cparameter-schema" target="_blank">here</a>.

# MORE TO COME
