---
title: Troubleshoot
layout: template
filename: troubleshoot
---

## WVD Quickstart Troubleshooting

- MORE TO COME - 

One important module is <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/Modules/ARM/UserCreation" target="_blank">UserCreation</a>, as this folder contains the script <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/Modules/ARM/UserCreation/scripts/createUsers.ps1" target="_blank">createUsers.ps1</a> that is used in Native AD deployments to create a new user in on the domain controller through a custom script extension. In case you are running a Native AD deployment, and the 'UserCreation' fails, it will likely be due to this script file. You could try and edit it to troubleshoot, but it might be easier to log on to your domain controller and create the user manually. Be sure to then assign that user to a Security Group with the same name as the variable 'targetGroup' in the main <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/deploy.json" target="_blank">deploy.json</a> and to sync this change to Azure with AD Connect. Your deployment will only work if the user is synced to Azure. If you go down this manual route, you do want to get rid of the 'UserCreation' deployment in the main deploy.json to avoid your deployment failing.
