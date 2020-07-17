---
title: Concepts
layout: template
filename: concepts
---

## Conceptual breakdown of the WVD Quickstart
To understand how the WVD Quickstart works, this page will walk you through a conceptual overview. In addition to the overview on this page, the links below provide a more in-depth walkthrough of certain components of the solution, which can be very helpful in case you want to understand the code behind the solution or when you want to more advanced customizations.

* For an in-depth breakdown of the ARM template used to configure DevOps, which is the template used when you click the blue "Deploy to Azure" button, please see <a href="armdeployment">Azure Resource Manager deployment: DevOps setup</a>
* For an in-depth analysis of the DevOps automation used to deploy the WVD environment, please visit <a href="devops">DevOps Automation</a>
* To understand this GitHub repository, its structure and all its individual files, the <a href="repo">Respository breakdown by file</a> gives an in-depth walkthrough of the entire repository with explanations on individual files' purpose and role.

### Conceptual Deployment Overview
As stated in the overview, the WVD Quickstart takes much of the WVD deployment complexity away, simplifying and automating the process, making the platform more accessible to non-expert users. As a WVD-centric end-to-end solution, the quickstart addressess reported pain points, challenges and feature gaps, empowering IT professionals to get started with WVD in a matter of clicks. This page will help you answer how exactly the Quickstart achieves that. In short, the deployment consists of two main parts:

* An Azure Resource Manager (ARM) deployment that deploys a number of supporting resource and creates an Azure DevOps (ADO) automation pipeline
* An Azure DevOps pipeline, created by the above deployment, that will automatically deploy a WVD environment for you

After clicking the "Deploy to Azure" button, the first of the two can be kicked off after providing some limited user input. Following that deployment, the DevOps pipeline will automatically start and deploy a WVD environment for you.

### Resources
The diagram below gives a good overview of all components of the Quickstart, as well as all the resources that are deployed in the process.

![Deployment overview](images/newDiagram.PNG?raw=true)

As can be seen in the image, the DevOps automation will deploy a host pool, a desktop application group, a workspace and virtual machines, that upon completion of the pipeline will be ready for use. By default, the virtual machines will utilize a gallery OS image of Windows 10 Enterprise Multi-Session, build 2004, with Office 365 installed. Additionally, the virtual machines will be configured with <a href="https://docs.microsoft.com/en-us/fslogix/overview">FSLogix</a> for user profile management.

# MORE TO COME
