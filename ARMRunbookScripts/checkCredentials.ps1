#Initializing variables from automation account
$SubscriptionId = Get-AutomationVariable -Name 'subscriptionid'
$ResourceGroupName = Get-AutomationVariable -Name 'ResourceGroupName'
$fileURI = Get-AutomationVariable -Name 'fileURI'

# Download files required for this script from github ARMRunbookScripts/static folder
$FileNames = "msft-wvd-saas-api.zip,msft-wvd-saas-web.zip,AzureModules.zip"
$SplitFilenames = $FileNames.split(",")
foreach($Filename in $SplitFilenames){
Invoke-WebRequest -Uri "$fileURI/ARMRunbookScripts/static/$Filename" -OutFile "C:\$Filename"
}

#New-Item -Path "C:\msft-wvd-saas-offering" -ItemType directory -Force -ErrorAction SilentlyContinue
Expand-Archive "C:\AzureModules.zip" -DestinationPath 'C:\Modules\Global' -ErrorAction SilentlyContinue

# Install required Az modules and AzureAD
Import-Module Az.Accounts -Global
Import-Module Az.Resources -Global
Import-Module Az.Websites -Global
Import-Module Az.Automation -Global
Import-Module Az.Managedserviceidentity -Global
Import-Module Az.Keyvault -Global
Import-Module AzureAD -Global

Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope Process -Force -Confirm:$false
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force -Confirm:$false
Get-ExecutionPolicy -List

#The name of the Automation Credential Asset this runbook will use to authenticate to Azure.
$AzCredentialsAsset = 'AzureCredentials'

#Authenticate Azure
#Get the credential with the above name from the Automation Asset store
$AzCredentials = Get-AutomationPSCredential -Name $AzCredentialsAsset
$AzCredentials.password.MakeReadOnly()
Connect-AzAccount -Environment 'AzureCloud' -Credential $AzCredentials
Select-AzSubscription -SubscriptionId $SubscriptionId

$context = Get-AzContext
if ($context -eq $null)
{
	Write-Error "Please authenticate to Azure & Azure AD using Login-AzAccount and Connect-AzureAD cmdlets and then run this script"
	throw
}
$AADUsername = $context.Account.Id

#region connect to Azure and check if Owner
Try {
	Write-Output "Try to connect AzureAD."
	Connect-AzureAD -Credential $AzCredentials
	
	Write-Output "Connected to AzureAD."
	
	# get user object 
	$userInAzureAD = Get-AzureADUser -Filter "UserPrincipalName eq `'$AADUsername`'"

	$isOwner = Get-AzRoleAssignment -ObjectID $userInAzureAD.ObjectId | Where-Object { $_.RoleDefinitionName -eq "Owner"}

	if ($isOwner.RoleDefinitionName -eq "Owner") {
		Write-Output $($AADUsername + " has Owner role assigned")        
	} 
	else {
		Write-Output "Missing Owner role."   
		Throw
	}
}
Catch {    
	Write-Output  $($AADUsername + " does not have Owner role assigned")
}
#endregion

#region connect to Azure and check if admin on Azure AD 
Try {
	# this depends on the previous segment completeing 
	$role = Get-AzureADDirectoryRole | Where-Object {$_.displayName -eq 'Company Administrator'}
	$isMember = Get-AzureADDirectoryRoleMember -ObjectId $role.ObjectId | Get-AzureADUser | Where-Object {$_.UserPrincipalName -eq $AADUsername}
	
	if ($isMember.UserType -eq "Member") {
		Write-Output $($AADUsername + " has " + $role.DisplayName + " role assigned")        
	} 
	else {
		Write-Output "Missing Owner role."   
		Throw
	}
}
Catch {    
	Write-Output  $($AADUsername + " does not have " + $role.DisplayName + " role assigned")
}
#endregion

#region check Microsoft.DesktopVirtualization resource provider has been registerred 
$wvdResourceProviderName = "Microsoft.DesktopVirtualization"
try {
	Get-AzResourceProvider -ListAvailable | Where-Object { $_.ProviderNamespace -eq $wvdResourceProviderName  }
	Write-Output  $($wvdResourceProviderName + " is registered!" )
}
Catch {
	Write-Output  $("Resource provider " + $wvdResourceProviderName + " is not registered")
	try {
		Write-Output  $("Registering " + $wvdResourceProviderName )
		Register-AzResourceProvider -ProviderNamespace $wvdResourceProviderName
		Write-Output  $("Registration of " + $wvdResourceProviderName + " completed!" )
	} 
	catch {
		Write-Output  $("Registering " + $wvdResourceProviderName + " has failed!" )
	}
}
#endregion

# Grant managed identity contributor role on subscription level
$identity = Get-AzUserAssignedIdentity -ResourceGroupName $ResourceGroupName -Name "WVDServicePrincipal"
New-AzRoleAssignment -RoleDefinitionName "Contributor" -ObjectId $identity.PrincipalId -Scope "/subscriptions/$subscriptionId"
Start-Sleep -Seconds 5
