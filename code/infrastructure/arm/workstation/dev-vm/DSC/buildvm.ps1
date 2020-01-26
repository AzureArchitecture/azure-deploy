param(
    [Parameter(Mandatory = $false)][string]$rdpPort = "3389"
)

Process {
  $temptime = Get-Date -f yyyy-MM-dd--HH:mm:ss
  New-Item -Path $env:UserProfile\AppData\Local\ChocoCache -ItemType directory -force
  Disable-UAC
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

  #Add RDP listening ports if needed
  if ($rdpPort -ne 3389) {
      netsh.exe interface portproxy add v4tov4 listenport=$rdpPort connectport=3389 connectaddress=127.0.0.1
      netsh.exe advfirewall firewall add rule name="Open Port $rdpPort" dir=in action=allow protocol=TCP localport=$rdpPort
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
}