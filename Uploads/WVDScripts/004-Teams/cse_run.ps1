[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $false)]
    [Hashtable] $DynParameters,

    [Parameter(Mandatory = $false)]
    [string] $AzureAdminUpn,

    [Parameter(Mandatory = $false)]
    [string] $AzureAdminPassword,

    [Parameter(Mandatory = $false)]
    [string] $domainJoinPassword,
    
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string] $ExecutableName = "Teams_windows_x64.exe"

    #[Parameter(Mandatory = $false)]
    #[ValidateNotNullOrEmpty()]
    #[string] $Switches = "/S /D=${Env:ProgramFiles(x86)}\Notepad++\"
)

#####################################

##########
# Helper #
##########
#region Functions
function LogInfo($message) {
    Log "Info" $message
}

function LogError($message) {
    Log "Error" $message
}

function LogSkip($message) {
    Log "Skip" $message
}
function LogWarning($message) {
    Log "Warning" $message
}

function Log {

    <#
    .SYNOPSIS
   Creates a log file and stores logs based on categories with tab seperation

    .PARAMETER category
    Category to put into the trace

    .PARAMETER message
    Message to be loged

    .EXAMPLE
    Log 'Info' 'Message'

    #>

    Param (
        $category = 'Info',
        [Parameter(Mandatory = $true)]
        $message
    )

    $date = get-date
    $content = "[$date]`t$category`t`t$message`n"
    Write-Verbose "$content" -verbose

    if (! $script:Log) {
        $File = Join-Path $env:TEMP "log.log"
        Write-Error "Log file not found, create new $File"
        $script:Log = $File
    }
    else {
        $File = $script:Log
    }
    Add-Content $File $content -ErrorAction Stop
}

function Set-Logger {
    <#
    .SYNOPSIS
    Sets default log file and stores in a script accessible variable $script:Log
    Log File name "executionCustomScriptExtension_$date.log"

    .PARAMETER Path
    Path to the log file

    .EXAMPLE
    Set-Logger
    Create a logger in
    #>

    Param (
        [Parameter(Mandatory = $true)]
        $Path
    )

    # Create central log file with given date

    $date = Get-Date -UFormat "%Y-%m-%d %H-%M-%S"

    $scriptName = (Get-Item $PSCommandPath ).Basename
    $scriptName = $scriptName -replace "-", ""

    Set-Variable logFile -Scope Script
    $script:logFile = "executionCustomScriptExtension_" + $scriptName + "_" + $date + ".log"

    if ((Test-Path $path ) -eq $false) {
        $null = New-Item -Path $path -type directory
    }

    $script:Log = Join-Path $path $logfile

    Add-Content $script:Log "Date`t`t`tCategory`t`tDetails"
}
#endregion

Set-Logger "C:\WindowsAzure\Logs\Plugins\Microsoft.Compute.CustomScriptExtension\executionLog\Teams" # inside "executionCustomScriptExtension_$scriptName_$date.log"
$SourcePath = $PSScriptRoot

function DoInstall {

    $Installer = "$($SourcePath)\Teams_windows_x64.exe"

    If (!(Test-Path $Installer)) {
        throw "Unable to locate Microsoft Teams client installer at $($installer)"
    }

    LogInfo("Attempting to install Microsoft Teams client")

    try {
        $process = Start-Process -FilePath "$Installer" -ArgumentList "-s" -Wait -PassThru -ErrorAction STOP

        if ($process.ExitCode -eq 0)
        {
            LogInfo("Microsoft Teams setup started without error.")
        }
        else
        {
            Write-Error "Installer exit code  $($process.ExitCode)."
        }
    }
    catch {
        Write-Error $_.Exception.Message
    }

}

#Check if Office is already installed, as indicated by presence of registry key
$installpath = "$($env:LOCALAPPDATA)\Microsoft\Teams"

if (-not(Test-Path "$($installpath)\Update.exe")) {
    DoInstall
}
else {
    if (Test-Path "$($installpath)\.dead") {
        LogInfo("Teams was previously installed but has been uninstalled. Will reinstall.")
        DoInstall
    }
}

LogInfo("Teams was successfully installed.")