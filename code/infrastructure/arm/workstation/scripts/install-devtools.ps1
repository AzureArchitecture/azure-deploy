# tools we expect devs across many scenarios will want
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

######################################################
# Taskbar icons
######################################################
Write-Host "DevTools to the TaskBar"
Install-ChocolateyPinnedTaskBarItem "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.exe"
Install-ChocolateyPinnedTaskBarItem "%windir%\system32\WindowsPowerShell\v1.0\PowerShell_ISE.exe"
Install-ChocolateyPinnedTaskBarItem "C:\Windows\explorer.exe"
Install-ChocolateyPinnedTaskBarItem "C:\Program Files\console\console.exe"
Write-Host

#add the AZCOPY path to the path variable
######################################################
# Add AZCOPY path to the path variable
######################################################
Write-Host "Adding Git\bin to the path"
Add-Path "C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy"
Write-Host

######################################################
# Add Git to the path
######################################################
Write-Host "Adding Git\bin to the path"
Add-Path "C:\Program Files (x86)\Git\bin"
Write-Host    