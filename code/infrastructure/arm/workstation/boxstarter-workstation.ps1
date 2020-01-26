######################################################
# To run this, use browser and go to http://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/AzureArchitecture/azure-deploy/master/code/infrastructure/arm/workstation/boxstarter-workstation.ps1
######################################################
# instructions at http://boxstarter.org/Learn/WebLauncher

# Description: Boxstarter Script
# Author: Quisitive
# Common settings for azure devops

# Boxstarter Options
$Boxstarter.RebootOk=$true # Allow reboots?
$Boxstarter.NoPassword=$false # Is this a machine with no login password?
$Boxstarter.AutoLogin=$true # Save my password securely and auto-login after a reboot

# Boxstarter (not Chocolatey) commands
Update-ExecutionPolicy Unrestricted
# Enable-RemoteDesktop  # already enabled on Azure VMs and no thanks for my laptop.
Disable-InternetExplorerESC  #Turns off IE Enhanced Security Configuration that is on by default on Server OS versions
Disable-UAC  # until this is over

if (Test-PendingReboot) { Invoke-Reboot }
disable-computerrestore -drive "C:\"  # http://ss64.com/ps/disable-computerrestore.html  ** Goes >BANG< on Server 2012 but not fatal.
if (Test-PendingReboot) { Invoke-Reboot }

Disable-MicrosoftUpdate # until this is over
Disable-BingSearch # forever
Enable-RemoteDesktop

try {
  # https://github.com/chocolatey/choco/issues/52
  choco feature enable allowInsecureConfirmation

  ######################################################
  # General Apps
  ######################################################
  Write-Host "Installing applications from Chocolatey"
  choco install DotNet3.5 # not installed by default on Windows Server 2012
  if (Test-PendingReboot) { Invoke-Reboot }

  # Get the base URI path from the ScriptToCall value
  $bstrappackage = "-bootstrapPackage"
  $helperUri = $Boxstarter['ScriptToCall']
  $strpos = $helperUri.IndexOf($bstrappackage)
  $helperUri = $helperUri.Substring($strpos + $bstrappackage.Length)
  $helperUri = $helperUri.TrimStart("'", " ")
  $helperUri = $helperUri.TrimEnd("'", " ")
  $helperUri = $helperUri.Substring(0, $helperUri.LastIndexOf("/"))
  $helperUri += "/scripts"
  write-host "helper script base URI is $helperUri"

  function executeScript {
      Param ([string]$script)
      write-host "executing $helperUri/$script ..."
	  iex ((new-object net.webclient).DownloadString("$helperUri/$script"))
  }

  ######################################################
  # settings-system.ps1
  ######################################################
  Write-Host "executing settings-system.ps1"
  executeScript "settings-system.ps1";
  RefreshEnvironment
  Write-Host

  ######################################################
  # settings-file-explorer.ps1
  ######################################################
  Write-Host "executing settings-file-explorer.ps1"
  executeScript "settings-file-explorer.ps1";
  RefreshEnvironment
  Write-Host

  ######################################################
  # install-browsers.ps1
  ######################################################
  Write-Host "executing install-browsers.ps1"
  executeScript "install-browsers.ps1";
  RefreshEnvironment
  Write-Host

  ######################################################
  # install-ps-modules.ps1
  ######################################################
  Write-Host "executing install-ps-modules.ps1"
  executeScript "install-ps-modules.ps1";
  RefreshEnvironment
  Write-Host

  ######################################################
  # install-devtools.ps1
  ######################################################
  Write-Host "executing install-devtools.ps1"
  executeScript "install-devtools.ps1";
  RefreshEnvironment
  Write-Host

  ######################################################
  # install-vsix.ps1
  ######################################################
  Write-Host "executing install-vsix.ps1"
  executeScript "install-vsix.ps1";
  RefreshEnvironment
  Write-Host

  ######################################################
  # clone-repos.ps1
  ######################################################
  Write-Host "executing clone-repos.ps1"
  executeScript "clone-repos.ps1";
  RefreshEnvironment
  Write-Host

  ######################################################
  # installing windows updates
  ######################################################
  Write-Host "executing install-devtools.ps1"
  Write-Output "Installing Windows Updates"
  Enable-MicrosoftUpdate
  Install-WindowsUpdate -AcceptEula -GetUpdatesFromMS

  Read-Host "Restart required for some modifications to take effect. Please reboot."
}
catch {
  throw $_
}

Exit
#
# End of Chocolatey
#
###########################################################################################################

#
# Function for refreshing environment variables
#
function RefreshEnvironment() {
    foreach($envLevel in "Machine","User") {
        [Environment]::GetEnvironmentVariables($envLevel).GetEnumerator() | ForEach-Object {
            # For Path variables, append the new values, if they're not already in there
            if($_.Name -match 'Path$') {
               $_.Value = ($((Get-Content "Env:$($_.Name)") + ";$($_.Value)") -Split ';' | Select-Object -Unique) -Join ';'
            }
            $_
         } | Set-Content -Path { "Env:$($_.Name)" }
    }
}
#
# Function to create a path if it does not exist
#
function CreatePathIfNotExists($pathName) {
    if(!(Test-Path -Path $pathName)) {
        New-Item -ItemType directory -Path $pathName
    }
}
#
# Function to Download and Extract ZIP Files for CLIs and the likes
#
function DownloadAndExtractZip($link, $targetFolder, $tempName) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $downloadPath = ($env:TEMP + "\$tempName")
    if(!(Test-Path -Path $downloadPath)) {
        Invoke-WebRequest $link -OutFile $downloadPath
    }
    $shell = New-Object -ComObject Shell.Application
    $targetZip = $shell.NameSpace($downloadPath)

    CreatePathIfNotExists($targetFolder)
    foreach($item in $targetZip.items()) {
        $shell.Namespace($targetFolder).CopyHere($item)
    }
}
#
# Function to Download and Copy Files to location
#
function DownloadAndCopy($link, $targetFolder) {
    CreatePathIfNotExists($targetFolder)

    if(!(Test-Path -Path $targetFolder)) {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest $link -OutFile $targetFolder
    }
}
#
# Function to Download and ExecuteMSI
#
function DownloadAndInstallMsi($link, $targetFolder, $targetName) {
    CreatePathIfNotExists($targetFolder)

    $targetName = [System.IO.Path]::Combine($targetFolder, $targetName)

    if(!(Test-Path -Path $targetName)) {
        Invoke-WebRequest $link -OutFile $targetName
    }

    # Execute the MSI
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$targetName`" /passive" -Wait

    # After completed, delete the MSI-package, again
    Remove-Item -Path $targetName
}
#
# Function to Download and Execute exe
#
function DownloadAndInstallExe($link, $targetFolder, $targetName, $targetParams) {
    # .\FiddlerSetup.exe /S /D=C:\tools\Fiddler
    CreatePathIfNotExists($targetFolder)

    $targetName = [System.IO.Path]::Combine($targetFolder, $targetName)

    if(!(Test-Path -Path $targetName)) {
        Invoke-WebRequest $link -OutFile $targetName
    }

    # Execute the Installer-EXE
    Start-Process -FilePath "$targetName" -ArgumentList "$targetParams" -Wait

    # After completed, delete the MSI-package, again
    Remove-Item -Path $targetName
}