Process {
  Write-Host "hello world"
  <#
  $temptime = Get-Date -f yyyy-MM-dd--HH:mm:ss
  New-Item -Path $env:UserProfile\AppData\Local\ChocoCache -ItemType directory -force

  Update-ExecutionPolicy Unrestricted
  $ConfirmPreference = "None" #ensure installing powershell modules don't prompt on needed dependencies
  Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

  Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  . choco.exe feature enable -n=allowGlobalConfirmation

  $scriptPath = "."
  $deploylogfile = "$scriptPath\deploymentlog.log"
  if ($PSScriptRoot) {
      $scriptPath = $PSScriptRoot
  }
  else {
      $scriptPath = Split-Path -parent $MyInvocation.MyCommand.Definition
  }

  #Install stuff

  $temptime = Get-Date -f yyyy-MM-dd--HH:mm:ss
  "Starting deployment script - $temptime" | Out-File $deploylogfile
  Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  . choco.exe feature enable -n=allowGlobalConfirmation

  Import-Module Boxstarter.Chocolatey -Force -Confirm:0 -ErrorVariable Continue
  CINST Boxstarter.Azure

  $temptime = Get-Date -f yyyy-MM-dd--HH:mm:ss
  "Ending deployment script - $temptime" | Out-File $deploylogfile -Append
  Copy-Item -Path $deploylogfile -Destination "C:\repos\deploymentlog.log"

  #>
}