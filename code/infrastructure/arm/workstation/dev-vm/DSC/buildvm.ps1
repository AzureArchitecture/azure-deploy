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

  ######################################################
  # Installing Browsers
  ######################################################
  Write-Host "Installing Browsers"
  choco install googlechrome -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" -force
  choco install firefox -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" -force
  Write-Host

  ######################################################
  # Installing Dev Tools
  ######################################################
  choco install git.install -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install visualstudio2019community --All -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install visualstudio2019-workload-databuildtools --All -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install visualstudio2019-workload-datascience --All -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install visualstudio2019-workload-data --All -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install visualstudio2019-workload-azure --All -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install PowerShell -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install dotnetfx -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install dotnet4.5 -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install dotnet4.6.2 -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install dotnet4.7 -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install netfx-4.7.1-devpack -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install dotnetcore-sdk -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install dotnetcore -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install powershell-core -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install azure-cli -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install microsoftazurestorageexplorer -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install vscode -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install sysinternals -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install office365business -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install adobereader -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install sql-server-management-studio -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install ssis-vs2019 -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install azure-data-studio -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install adobereader -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install azuredatastudio-powershell -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install github-desktop -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install azcopy -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install adobereader -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install rdcman -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install cosmosdbexplorer -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
  choco install ignorefiles -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
}