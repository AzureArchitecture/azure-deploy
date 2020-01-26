
# tools we expect devs across many scenarios will want
choco install git.install -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
choco install visualstudio2019community --All -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
choco install visualstudio2019-workload-databuildtools --All -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
choco install visualstudio2019-workload-datascience --All -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
choco install visualstudio2019-workload-data --All -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
choco install visualstudio2019-workload-azure --All -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" --Force
choco install PowerShell -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache"
choco install dotnetfx -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache"
choco install dotnet4.5 -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache"
choco install dotnet4.6.2 -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache"
choco install dotnet4.7 -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache"
choco install netfx-4.7.1-devpack -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache"
choco install dotnetcore-sdk -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache"
choco install dotnetcore -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache"
choco install powershell-core -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache"
choco install azure-cli -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache"
choco install microsoftazurestorageexplorer -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache"
choco install vscode -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache"
choco install sysinternals -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache"
choco install office365business -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache"
choco install adobereader -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache"
choco install sql-server-management-studio -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache"
choco install ssis-vs2019 -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache"
choco install azure-data-studio -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache"
choco install adobereader -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache"
choco install azuredatastudio-powershell -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache"
choco install github-desktop -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache"
choco install azcopy -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache"
choco install adobereader -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache"
choco install rdcman -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache"

choco install ignorefiles -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache"
choco install packageinstaller
choco install markdowneditor
choco install visualstudio2015-powershelltools
choco install visualstudio2015-nugetpackagemanager
choco install visualstudio2013-webessentials.vsix
choco install batch-install-vsix

#add the AZCOPY path to the path variable
$AZCOPYpath = "C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy"
$actualPath = ((Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment" -Name PATH).path)
$NEWPath = "$actualPath;$AZCOPYpath"
$NEWPath | Out-File $scriptPath\azcopySystemPath.log
Set-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment" -Name PATH -Value $NEWPath