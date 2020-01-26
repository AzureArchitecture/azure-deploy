# Description: Boxstarter Script
# Author: Quisitive
# Common settings for azure devops
$temptime = Get-Date -f yyyy-MM-dd--HH:mm:ss
New-Item -Path $env:UserProfile\AppData\Local\ChocoCache -ItemType directory -force
Disable-UAC
Update-ExecutionPolicy Unrestricted
$ConfirmPreference = "None" #ensure installing powershell modules don't prompt on needed dependencies
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
. choco.exe feature enable -n=allowGlobalConfirmation

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

#--- Setting up Windows ---
executeScript "settings-file-explorer.ps1";
executeScript "settings-system.ps1";
RefreshEnv
executeScript "install-devtools.ps1";
RefreshEnv
executeScript "install-browsers.ps1";
RefreshEnv
executeScript "install-ps-modules.ps1";

Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula

Read-Host "Restart required for some modifications to take effect. Please reboot."
