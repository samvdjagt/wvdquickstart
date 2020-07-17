---
title: Customize
layout: template
filename: customize
---

## How To Customize the WVD Quickstart

- MORE TO COME -

### Customize the WVD Deployment in DevOps
Customization of the WVD Deployment has been made easy through the curation of two central parameter files that are used in the deployment of all the WVD resources. By simply adapting these files in the repository of your DevOps project (which has been created in the inital ARM deployment), you can fully customize the DevOps pipeline and the resources that are being deployed.

#### AppliedParameters.psd1
#### Variables.yml
#### Pipeline.yml

#### Example: Deploying Personal Desktops
In this example, we'll walkthrough the necessary steps to deploy a WVD environment with a number of personal desktops. In order to do so, we're going to change some of the parameters in the files listed above.

### Advanced: Customize the WVD Quickstart Code
In case the above customization is not sufficient to support your needs, a more advanced customization is possible. 
Clone this git repo and change the URLs in all file to point towards your repository, which has to be public.
