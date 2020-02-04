param(
    [Parameter(Mandatory = $false)][string]$rdpPort = "3389"
)
Process {
  Write-Host "hello world"

    #Add RDP listening ports if needed
    if ($rdpPort -ne 3389) {
        netsh.exe interface portproxy add v4tov4 listenport=$rdpPort connectport=3389 connectaddress=127.0.0.1
        netsh.exe advfirewall firewall add rule name="Open Port $rdpPort" dir=in action=allow protocol=TCP localport=$rdpPort
    }

      Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    . choco.exe feature enable -n=allowGlobalConfirmation

    #install Powershell AZ module
    $ConfirmPreference = "None"
    Install-PackageProvider -Name NuGet -Force -Confirm:0 -ErrorVariable Continue
    Install-Module -Name NuGet -Force -AllowClobber -Confirm:0 -ErrorVariable Continue
    Install-Module -Name PowerShellGet -Force -AllowClobber -Confirm:0 -ErrorVariable Continue
    Install-Module -Name Az -Force -AllowClobber -Confirm:0 -ErrorVariable Continue
    Install-Module -Name PSDocs -Force  -AllowClobber -Confirm:0 -ErrorVariable Continue
    Install-Module -Name ImportExcel -Force  -AllowClobber -Confirm:0 -ErrorVariable Continue
    install-module -Name Az.Blueprint -force -confirm:0 -AllowClobber -ErrorVariable Continue
    install-module -Name AzureAD -force -confirm:0 -AllowClobber -ErrorVariable Continue
    Install-Module -Name AzSK -force -confirm:0 -AllowClobber -ErrorVariable Continue
    Install-Module -Name SqlServer -force -confirm:0 -AllowClobber -ErrorVariable Continue
    Install-Module -Name PsISEProjectExplorer -force -confirm:0 -AllowClobber -ErrorVariable Continue
    Install-Module -Name Pester -force -confirm:0 -AllowClobber -ErrorVariable Continue

    #enable azure alias
    Enable-AzureRmAlias -Scope LocalMachine

}
