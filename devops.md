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

#### Definition
```
name: WVD Deployment

variables:
- template: './variables.yml'

trigger: none
```
At the top of the pipeline, you will find its name defined, as well as a link to a *variables.yml* file. This file contains certain parameters used in the automation - to learn more about this, check out the <a href="customize" target="_blank">Customize</a> section. You can also see that there's currently no *trigger* set for the pipeline, which means it will never automatically start running (with the exception of the initial deployment). If you want to further develop the WVD Quickstart and automate future WVD Deployments, you can learn more about <a href="https://docs.microsoft.com/en-us/azure/devops/pipelines/repos/azure-repos-git?view=azure-devops&tabs=yaml#ci-triggers" target="_blank">triggers in DevOps pipelines</a>.

#### Processing Input Parameters
```
stages:
- stage: SBX
  jobs:
  - deployment: Process_input_parameters
    dependsOn: ''
    environment: SBX
    condition: and(succeeded(), true)
    timeoutInMinutes: 120
    pool:
      vmImage: $(vmImage)
    strategy:
        runOnce:
          deploy:
            steps:
              - checkout: self
              - task: AzurePowerShell@4
                displayName: 'Parse input parameters into parameter files'
                name: Process_inputer_parameters_task
                inputs:
                  azureSubscription: $(serviceConnection)
                  ScriptType: InlineScript
                  inline: |
                      Write-Verbose "Load function" -Verbose
                      . '$(Build.Repository.LocalPath)/QS-WVD/Scripts/New-PipelineParameterSetup.ps1'

                      New-PipelineParameterSetup -Verbose
                  errorActionPreference: stop
                  azurePowerShellVersion: LatestVersion
                enabled: true
```
In the first pipeline job, a script called *New-PipelineParameterSetup.ps1* is run. This particular script takes the parameters from *appliedParameters.psd1* (learn more about that file in the <a href="customize" target="_blank">Customize</a> section) and generates ARM template parameter files for the WVD deployment. For every resource that will be deployed, the script generates a parameter file using the templates in the <a href="https://github.com/samvdjagt/wvdquickstart/tree/master/QS-WVD/static/templates/pipelineinput" target="_blank">/templates/pipelineinput</a> folder.
```
              - task: CopyFiles@2
                name: Copy_FSLogix_parameters
                inputs:
                  SourceFolder: '$(Build.Repository.LocalPath)/QS-WVD/Parameters'
                  Contents: 'fslogix.parameters.json'
                  TargetFolder: '$(Pipeline.Workspace)/s/Uploads/WVDScripts/002-FSLogix'
                  OverWrite: true
              - task: CopyFiles@2
                name: Copy_Userconfig_parameters
                inputs:
                  SourceFolder: '$(Build.Repository.LocalPath)/QS-WVD/Parameters'
                  Contents: 'users.parameters.json'
                  TargetFolder: '$(Pipeline.Workspace)/s/Uploads'
                  OverWrite: true
              - task: CopyFiles@2
                name: Copy_AzFiles_parameters
                inputs:
                  SourceFolder: '$(Build.Repository.LocalPath)/QS-WVD/Parameters'
                  Contents: 'azfiles.parameters.json'
                  TargetFolder: '$(Pipeline.Workspace)/s/Uploads/WVDScripts/001-AzFiles'
                  OverWrite: true
              - task: CopyFiles@2
                name: Copy_Deployment_parameters
                inputs:
                  SourceFolder: '$(Build.Repository.LocalPath)/QS-WVD/Parameters'
                  Contents: '**'
                  TargetFolder: '$(Pipeline.Workspace)'
                  OverWrite: true
              - task: PublishPipelineArtifact@1
                name: Publish_Deployment_Files
                inputs:
                  targetPath: '$(Pipeline.Workspace)'
                  artifact: 'parameters'
                  publishLocation: 'pipeline'
```
The next part of this same job consists of a couple of *Copy* tasks. What happens here is that it takes the parameter files generated by the script above, and copies them into the current pipeline build's 'Workspace'. This includes parameters for the configuration of FSLogix and the enablement of Azure Files (which are both custom script extensions). These files being in the pipeline 'Workspace' means that the parameter files are associated with this particular run of the pipeline only, stored as an *Artifact* by the bottom *Publish* task in the code above. Whenever you rerun the pipeline, these parameter files are regenerated based on the parameters in the *appliedParameters.psd1* and *variables.yml* files. In the overview of your pipeline, you can view this Artifact by clicking in the location of the red rectangle in the picture below.

![DevOps Pipeline Artifact](images/devopsArtifact.PNG?raw=true)

#### Assets Storage Account Deployment
```
  - deployment: Deploy_wvdAssetsStorage
    dependsOn:
    - Process_input_parameters
    environment: SBX
    condition:
      and (
          not(canceled()),
          eq(variables['enableJobDeployAssetsStorageAccount'], true),
          or(
            eq(dependencies.Deploy_MgmtResourceGroup.result, ''),
            in(dependencies.Deploy_MgmtResourceGroup.result, 'Succeeded', 'Skipped')
          )
      )
    timeoutInMinutes: 120
    pool:
      vmImage: $(vmImage)
    strategy:
        runOnce:
          deploy:
            steps:
              - checkout: self
              - task: AzurePowerShell@4
                displayName: 'Deploy module [StorageAccounts] in [$(wvdMgmtResourceGroupName)] via [$(serviceConnection)]'
                name: Deploy_StorageAccounts_Task
                inputs:
                  azureSubscription: $(serviceConnection)
                  ScriptType: InlineScript
                  inline: |
                    Write-Verbose "Load function" -Verbose
                    . '$(Build.Repository.LocalPath)/$(orchestrationFunctionsPath)/Invoke-GeneralDeployment.ps1'

                    $parameterFilePath = '$(Pipeline.Workspace)/parameters/storageaccount.parameters.json'
                    $functionInput = @{
                      resourcegroupName             = "$(wvdMgmtResourceGroupName)"
                      location                      = "$(location)"
                      moduleName                    = "StorageAccounts"
                      moduleVersion                 = "2020-06-02"
                      parameterFilePath             = $parameterFilePath
                    }

                    Write-Verbose "Invoke task with" -Verbose
                    $functionInput.Keys | ForEach-Object { Write-Verbose ("PARAMETER: `t'{0}' with value '{1}'" -f $_, $functionInput[$_]) -Verbose }

                    Invoke-GeneralDeployment @functionInput -Verbose
                  errorActionPreference: stop
                  azurePowerShellVersion: LatestVersion
                enabled: true
              - task: AzurePowerShell@4
                displayName: "Trigger module [StorageAccounts] post-deployment"
                name: PostDeploy_StorageAccounts_Task
                inputs:
                  azureSubscription: $(serviceConnection)
                  ScriptType: InlineScript
                  inline: | 
                    Write-Verbose "Load function" -Verbose
                    . '$(Build.Repository.LocalPath)/$(parameterFolderPath)/Scripts/Invoke-StorageAccountPostDeployment.ps1'

                    $functionInput = @{
                      orchestrationFunctionsPath = Join-Path '$(Build.Repository.LocalPath)' '$(orchestrationFunctionsPath)'
                      wvdUploadsPath = Join-Path '$(Pipeline.Workspace)/parameters/s' '$(wvdUploadsPath)'          
                      storageAccountName         = "$(wvdAssetsStorage)"
                    }

                    Write-Verbose "Invoke task with" -Verbose
                    $functionInput.Keys | ForEach-Object { Write-Verbose ("PARAMETER: `t'{0}' with value '{1}'" -f $_, $functionInput[$_]) -Verbose }

                    Invoke-StorageAccountPostDeployment @functionInput -Verbose
                  errorActionPreference: stop
                  azurePowerShellVersion: LatestVersion
                enabled: true
```

#### Profiles Storage Account Deployment
```
  - deployment: Deploy_WVDProfilesStorageAccount01
    dependsOn:
    - Deploy_wvdAssetsStorage
    environment: SBX
    condition: and(succeeded(), true)
    timeoutInMinutes: 120
    pool:
      vmImage: $(vmImage)
    strategy:
        runOnce:
          deploy:
            steps:
              - checkout: self
              - task: AzurePowerShell@4
                displayName: 'Deploy module [StorageAccounts] in [$(wvdMgmtResourceGroupName)] via [$(serviceConnection)]'
                name: Deploy_StorageAccounts_Task_01
                inputs:
                  azureSubscription: $(serviceConnection)
                  ScriptType: InlineScript
                  inline: |
                    Write-Verbose "Load function" -Verbose
                    . '$(Build.Repository.LocalPath)/$(orchestrationFunctionsPath)/Invoke-GeneralDeployment.ps1'

                    $parameterFilePath = '$(Pipeline.Workspace)/parameters/wvdprofiles-storageaccount-01.parameters.json'
                    $functionInput = @{
                      resourcegroupName             = "$(wvdMgmtResourceGroupName)"
                      location                      = "$(location)"
                      moduleName                    = "StorageAccounts"
                      moduleVersion                 = "2020-06-02"
                      parameterFilePath             = $parameterFilePath
                    }
                    
                    Write-Verbose "Checking identity approach: $(identityApproach)" -Verbose
                    If("$(identityApproach)" -eq "AADDS") {
                      Write-Verbose "Creating azureFilesIdentityBasedAuthentication object and set to AADDS" -Verbose
                      $parameterObjects=@{
                        azureFilesIdentityBasedAuthentication=@{
                          directoryServiceOptions = "AADDS"
                        }
                      }
                      $functionInput += @{
                        optionalParameters=$parameterObjects
                      }
                    }

                    Write-Verbose "Invoke task with $functionInput" -Verbose
                    $functionInput.Keys | ForEach-Object { Write-Verbose ("PARAMETER: `t'{0}' with value '{1}'" -f $_, $functionInput[$_]) -Verbose }

                    Invoke-GeneralDeployment @functionInput -Verbose
                  errorActionPreference: stop
                  azurePowerShellVersion: LatestVersion
                enabled: true
```

#### WVD Host Pool Deployment
```
  - deployment: Deploy_WVDHostPool
    dependsOn: 
    - Deploy_WVDProfilesStorageAccount01
    environment: SBX
    condition: and(succeeded(), true)
    timeoutInMinutes: 120
    pool:
      vmImage: $(vmImage)
    strategy:
        runOnce:
          deploy:
            steps:
              - checkout: self
              - task: AzurePowerShell@4
                displayName: 'Deploy module [WvdHostPools] in [$(resourceGroupName)] via [$(serviceConnection)]'
                name: Deploy_WVDHostPool_Task
                inputs:
                  azureSubscription: $(serviceConnection)
                  ScriptType: InlineScript
                  inline: |
                    Write-Verbose "Load function" -Verbose
                    . '$(Build.Repository.LocalPath)/$(orchestrationFunctionsPath)/Invoke-GeneralDeployment.ps1'

                    $parameterFilePath = '$(Pipeline.Workspace)/parameters/wvdhostpool.parameters.json'
                    $functionInput = @{
                      resourcegroupName             = "$(resourceGroupName)"
                      location                      = "$(location)"
                      moduleName                    = "WvdHostPools"
                      moduleVersion                 = "0.0.1"
                      parameterFilePath             = $parameterFilePath
                    }

                    Write-Verbose "Invoke task with" -Verbose
                    $functionInput.Keys | ForEach-Object { Write-Verbose ("PARAMETER: `t'{0}' with value '{1}'" -f $_, $functionInput[$_]) -Verbose }

                    Invoke-GeneralDeployment @functionInput -Verbose
                  errorActionPreference: stop
                  azurePowerShellVersion: LatestVersion
                enabled: true  
```

#### Desktop App Group Deployment
```
  - deployment: Deploy_DesktopAppGroup
    dependsOn: 
    - Deploy_WVDHostPool
    - Deploy_WVDSessionHosts
    environment: SBX
    condition: and(succeeded(), true)
    timeoutInMinutes: 120
    pool:
      vmImage: $(vmImage)
    strategy:
        runOnce:
          deploy:
            steps:
              - checkout: self
              - task: AzurePowerShell@4
                displayName: 'Deploy module [WvdApplicationGroups] in [$(resourceGroupName)] via [$(serviceConnection)]'
                name: Deploy_WvdApplicationGroups_Task
                inputs:
                  azureSubscription: $(serviceConnection)
                  ScriptType: InlineScript
                  inline: |
                    Write-Verbose "Load function" -Verbose
                    . '$(Build.Repository.LocalPath)/$(orchestrationFunctionsPath)/Invoke-GeneralDeployment.ps1'

                    $parameterFilePath = '$(Pipeline.Workspace)/parameters/wvddesktoppapplicationgroup.parameters.json'
                    $functionInput = @{
                      resourcegroupName             = "$(resourceGroupName)"
                      location                      = "$(location)"
                      moduleName                    = "WvdApplicationGroups"
                      moduleVersion                 = "2020-06-02"
                      parameterFilePath             = $parameterFilePath
                    }

                    Write-Verbose "Invoke task with" -Verbose
                    $functionInput.Keys | ForEach-Object { Write-Verbose ("PARAMETER: `t'{0}' with value '{1}'" -f $_, $functionInput[$_]) -Verbose }

                    Invoke-GeneralDeployment @functionInput -Verbose
                  errorActionPreference: stop
                  azurePowerShellVersion: LatestVersion
                enabled: true
```

#### Remote App Group Deployment
```
  - deployment: Deploy_RemoteAppGroup01
    dependsOn: 
    - Deploy_WVDHostPool
    - Deploy_WVDSessionHosts
    environment: SBX
    condition: and(succeeded(), eq(variables['enableApplicationJob'], true))
    timeoutInMinutes: 120
    pool:
      vmImage: $(vmImage)
    strategy:
        runOnce:
          deploy:
            steps:
              - checkout: self
              - task: AzurePowerShell@4
                displayName: 'Deploy module [WvdApplicationGroups] in [$(resourceGroupName)] via [$(serviceConnection)]'
                name: Deploy_WvdApplicationGroups_Task
                inputs:
                  azureSubscription: $(serviceConnection)
                  ScriptType: InlineScript
                  inline: |
                    Write-Verbose "Load function" -Verbose
                    . '$(Build.Repository.LocalPath)/$(orchestrationFunctionsPath)/Invoke-GeneralDeployment.ps1'
                
                    $parameterFilePath = '$(Pipeline.Workspace)/parameters/wvdapplicationgroup01.parameters.json'
                    $functionInput = @{
                      resourcegroupName             = "$(resourceGroupName)"
                      location                      = "$(location)"
                      moduleName                    = "WvdApplicationGroups"
                      moduleVersion                 = "2020-06-02"
                      parameterFilePath             = $parameterFilePath
                    }

                    Write-Verbose "Invoke task with" -Verbose
                    $functionInput.Keys | ForEach-Object { Write-Verbose ("PARAMETER: `t'{0}' with value '{1}'" -f $_, $functionInput[$_]) -Verbose }

                    Invoke-GeneralDeployment @functionInput -Verbose
                  errorActionPreference: stop
                  azurePowerShellVersion: LatestVersion
                enabled: true
```

#### WVD Virtual Machine (Session Host) Deployment
```
  - deployment: Deploy_WVDSessionHosts
    dependsOn:
    - Deploy_WVDHostPool
    environment: SBX
    condition: and(succeeded(), true)
    timeoutInMinutes: 120
    pool:
      vmImage: $(vmImage)
    strategy:
        runOnce:
          deploy:
            steps:
              - checkout: self
              - powershell: |
                  if(-not (Get-Module Az.DesktopVirtualization -ListAvailable)) {
                      Write-Verbose "Installing module 'Az.DesktopVirtualization'" -Verbose
                      Install-Module Az.DesktopVirtualization -Repository PSGallery -Force -Scope CurrentUser
                  } else {
                      Write-Verbose "Module 'Az.DesktopVirtualization' already installed" -Verbose
                  }
                displayName: 'Install required module'
              - task: AzurePowerShell@4
                displayName: 'Deploy module [VirtualMachines] in [$(resourceGroupName)] via [$(serviceConnection)]'
                name: Deploy_SessionHosts_Task
                inputs:
                  azureSubscription: $(serviceConnection)
                  ScriptType: InlineScript
                  inline: |
                    Write-Verbose "Load function" -Verbose
                    . '$(Build.Repository.LocalPath)/$(orchestrationFunctionsPath)/Invoke-GeneralDeployment.ps1'
                    . '$(Build.Repository.LocalPath)/$(orchestrationFunctionsPath)/Add-CustomParameters.ps1'

                    $parameterFilePath = '$(Pipeline.Workspace)/parameters/wvdsessionhost.parameters.json'
                    $functionInput = @{
                      resourcegroupName             = "$(resourceGroupName)"
                      location                      = "$(location)"
                      moduleName                    = "VirtualMachines"
                      moduleVersion                 = "2020-06-02"
                      parameterFilePath             = $parameterFilePath
                    }

                    Write-Verbose "Invoke task with" -Verbose
                    $functionInput.Keys | ForEach-Object { Write-Verbose ("PARAMETER: `t'{0}' with value '{1}'" -f $_, $functionInput[$_]) -Verbose }

                    Write-Verbose "Fetch and populated pipeline outputs" -Verbose
                    $regInfo = Get-AzWvdRegistrationInfo -HostPoolName '$(hostpoolname)' -ResourceGroupName '$(resourceGroupName)'

                    $overwriteInputObject = @{
                      parameterFilePath = $parameterFilePath
                      valueMap         = @(
                        @{ path = 'dscConfiguration.value.protectedSettings.configurationArguments.registrationInfoToken'; value = $regInfo.Token }
                      )
                    }
                    Add-CustomParameters @overwriteInputObject

                    $parameterObjects = $()
                    if (-not [String]::IsNullOrEmpty('$(customImageReferenceId)')) {
                      Write-Verbose "Using custom image ref ['$(customImageReferenceId)']" -Verbose
                      $parameterObjects += @{
                        imageReference = @{
                          id = '$(customImageReferenceId)'
                        }
                      }
                    }
                    else {
                      $imageReference = @{
                        publisher = '$(publisher)'
                        offer     = '$(offer)'
                        sku       = '$(sku)'
                        version   = '$(version)'
                      }
                      Write-Verbose ("Using published image ref [{0}]" -f ($imageReference | ConvertTo-Json)) -Verbose
                      $parameterObjects += @{
                        imageReference = $imageReference
                      }
                    }

                    $storageAccount = Get-AzResource -Name $(profilesStorageAccountName) -ResourceType 'Microsoft.Storage/storageAccounts'
                    $SASKey = (Get-AzStorageAccountKey -AccountName $storageAccount.Name -ResourceGroupName $storageAccount.ResourceGroupName)[0]                    
                    $windowsScriptExtensionCommandToExecute = 'powershell -ExecutionPolicy Unrestricted -Command "& .\scriptExtensionMasterInstaller.ps1 -AzureAdminUpn $(azureAdminUpn) -AzureAdminPassword $(azureAdminPassword) -domainJoinPassword $(domainJoinPassword) -Dynparameters @{storageaccountkey=\"'+ $($SASKey.Value) +'\"}"'
                    $windowsScriptExtensionCommandToExecute = ConvertTo-SecureString -String $windowsScriptExtensionCommandToExecute -AsPlainText -Force
                    
                    $parameterObjects += @{
                      windowsScriptExtensionCommandToExecute = $windowsScriptExtensionCommandToExecute
                    }

                    $functionInput += @{
                      optionalParameters = $parameterObjects
                    }

                    Invoke-GeneralDeployment @functionInput -Verbose
                  errorActionPreference: stop
                  azurePowerShellVersion: LatestVersion
                enabled: true 
```

#### Remote Application Deployment
```
  - deployment: Deploy_Application
    dependsOn:
    - Deploy_WVDSessionHosts
    - Deploy_RemoteAppGroup01
    environment: SBX
    condition: and(succeeded(), eq(variables['enableApplicationJob'], true))
    timeoutInMinutes: 120
    pool:
      vmImage: $(vmImage)
    strategy:
        runOnce:
          deploy:
            steps:
              - checkout: self
              - task: AzurePowerShell@4
                displayName: 'Deploy module [WvdApplications] in [$(resourceGroupName)] via [$(serviceConnection)]'
                name: Deploy_WvdApplications_Task
                inputs:
                  azureSubscription: $(serviceConnection)
                  ScriptType: InlineScript
                  inline: |
                    Write-Verbose "Load function" -Verbose
                    . '$(Build.Repository.LocalPath)/$(orchestrationFunctionsPath)/Invoke-GeneralDeployment.ps1'

                    $parameterFilePath = '$(Pipeline.Workspace)/parameters/wvdapplication.parameters.json'
                    $functionInput = @{
                      resourcegroupName             = "$(resourceGroupName)"
                      location                      = "$(location)"
                      moduleName                    = "WvdApplications"
                      moduleVersion                 = "2020-06-02"
                      parameterFilePath             = $parameterFilePath
                    }

                    Write-Verbose "Invoke task with" -Verbose
                    $functionInput.Keys | ForEach-Object { Write-Verbose ("PARAMETER: `t'{0}' with value '{1}'" -f $_, $functionInput[$_]) -Verbose }

                    Invoke-GeneralDeployment @functionInput -Verbose
                  errorActionPreference: stop
                  azurePowerShellVersion: LatestVersion
                enabled: true
```

#### WVD Workspace Deployment
```
  - deployment: Deploy_Workspace
    dependsOn:
    - Deploy_DesktopAppGroup
    environment: SBX
    condition: and(succeeded(), true)
    timeoutInMinutes: 120
    pool:
      vmImage: $(vmImage)
    strategy:
        runOnce:
          deploy:
            steps:
              - checkout: self
              - task: AzurePowerShell@4
                displayName: 'Deploy module [WvdWorkspaces] in [$(resourceGroupName)] via [$(serviceConnection)]'
                name: Deploy_WvdWorkspaces_Task
                inputs:
                  azureSubscription: $(serviceConnection)
                  ScriptType: InlineScript
                  inline: |
                    Write-Verbose "Load function" -Verbose
                    . '$(Build.Repository.LocalPath)/$(orchestrationFunctionsPath)/Invoke-GeneralDeployment.ps1'

                    $parameterFilePath = '$(Pipeline.Workspace)/parameters/wvdworkspace.parameters.json'
                    $functionInput = @{
                      resourcegroupName             = "$(resourceGroupName)"
                      location                      = "$(location)"
                      moduleName                    = "WvdWorkspaces"
                      moduleVersion                 = "0.0.1"
                      parameterFilePath             = $parameterFilePath
                    }

                    Write-Verbose "Invoke task with" -Verbose
                    $functionInput.Keys | ForEach-Object { Write-Verbose ("PARAMETER: `t'{0}' with value '{1}'" -f $_, $functionInput[$_]) -Verbose }

                    Invoke-GeneralDeployment @functionInput -Verbose
                  errorActionPreference: stop
                  azurePowerShellVersion: LatestVersion
                enabled: true
```

#### Updating Existing Host Pool With New Image Definition (NOT IMPLEMENTED)
```
  - deployment: Update_Session_HostPool_with_new_image
    dependsOn:
      - Deploy_WVDSessionHosts
      - Deploy_Application
      - Deploy_Workspace
    environment: SBX
    condition: |
      and (
          not(canceled()),
          eq(variables['enableJobUpdateSessionHosts'], true),
          or(
            eq(dependencies.Deploy_WVDSessionHosts.result, ''),
            in(dependencies.Deploy_WVDSessionHosts.result, 'Succeeded', 'Skipped')
          ),
          or(
            eq(dependencies.Deploy_Application.result, ''),
            in(dependencies.Deploy_Application.result, 'Succeeded', 'Skipped')
          ),
          or(
            eq(dependencies.Deploy_Workspace.result, ''),
            in(dependencies.Deploy_Workspace.result, 'Succeeded', 'Skipped')
          )
      )
    timeoutInMinutes: 120
    pool:
      vmImage: $(vmImage)
    strategy:
        runOnce:
          deploy:
            steps:
              - checkout: self
              - powershell: |
                  if(-not (Get-Module Az.DesktopVirtualization -ListAvailable)) {
                      Write-Verbose "Installing module 'Az.DesktopVirtualization'" -Verbose
                      Install-Module Az.DesktopVirtualization -Repository PSGallery -Force -Scope CurrentUser
                  } else {
                      Write-Verbose "Module 'Az.DesktopVirtualization' already installed" -Verbose
                  }
                displayName: 'Install required module'
              - task: AzurePowerShell@4
                displayName: 'Run image lifecycle update via [$(serviceConnection)]'
                name: ImageLifecycleUpdate
                inputs:
                  azureSubscription: $(serviceConnection)
                  ScriptType: InlineScript
                  inline: |
                    Write-Verbose "Load function" -Verbose
                    . '$(Build.Repository.LocalPath)/$(parameterFolderPath)/Scripts/Invoke-UpdateHostPool.ps1'

                    $functionInput = @{
                      HostPoolName       = '$(HostPoolName)'
                      HostPoolRGName     = '$(resourceGroupName)'
                      LogoffDeadline     = '$(LogoffDeadline)'
                      LogOffMessageTitle = '$(LogOffMessageTitle)'
                      LogOffMessageBody  = '$(LogOffMessageBody)'
                      UTCOffset          = '$(TimeDifference)'
                    }

                    if (-not [String]::IsNullOrEmpty('$(customImageReferenceId)')) {
                      $functionInput += @{ customImageReferenceId = '$(customImageReferenceId)' }
                    }

                    else {
                      $functionInput += @{ MarketplaceImageVersion = '$(version)' }
                    }

                    Write-Verbose "Invoke task with" -Verbose
                    $functionInput.Keys | ForEach-Object { Write-Verbose ("PARAMETER: `t'{0}' with value '{1}'" -f $_, $functionInput[$_]) -Verbose }

                    Invoke-UpdateHostPool @functionInput -Verbose
                  errorActionPreference: stop
                  azurePowerShellVersion: LatestVersion
                enabled: true

```
