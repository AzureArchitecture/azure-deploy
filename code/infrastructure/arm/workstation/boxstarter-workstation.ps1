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

disable-computerrestore -drive "C:\"  # http://ss64.com/ps/disable-computerrestore.html  ** Goes >BANG< on Server 2012 but not fatal.

Disable-MicrosoftUpdate # until this is over
Disable-BingSearch # forever
Enable-RemoteDesktop

if (Test-PendingReboot) { Invoke-Reboot }

try {
  # https://github.com/chocolatey/choco/issues/52
  choco feature enable allowInsecureConfirmation

  if (Test-PendingReboot) { Invoke-Reboot }
  ######################################################
  # settings-system.ps1
  ######################################################
  #--- Enable developer mode on the system ---
  Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock -Name AllowDevelopmentWithoutDevLicense -Value 1

  #--- Windows Settings ---
  Write-Output "--Modifying Windows Settings--"

  Write-Output "Modifying Explorer options"
  Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowFileExtensions -EnableShowFullPathInTitleBar
  Set-WindowsExplorerOptions -DisableShowRecentFilesInQuickAccess -DisableShowFrequentFoldersInQuickAccess

  Write-Output "Modifying taskbar options"
  Set-TaskbarOptions -Dock Bottom -Combine Always -AlwaysShowIconsOn

  # disabled bing search in start menu
  Write-Output "Disabling Bing Search in start menu"
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0
  If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
      New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
  }
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Type DWord -Value 1

  # show this pc on desktop
  Write-Output "Showing 'This PC' on desktop"
  If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu")) {
      New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Force | Out-Null
  }
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type DWord -Value 0
  If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel")) {
      New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Force | Out-Null
  }
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type DWord -Value 0

  # show user folder on desktop
  Write-Output "Showing user home on desktop"
  If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu")) {
      New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Force | Out-Null
  }
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -Type DWord -Value 0
  If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel")) {
      New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Force | Out-Null
  }
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -Type DWord -Value 0

  # Disable Cortana
  Write-Output "Disabling Cortana"
  If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings")) {
      New-Item -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Force | Out-Null
  }
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0
  If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization")) {
      New-Item -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Force | Out-Null
  }
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1
  If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore")) {
      New-Item -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Force | Out-Null
  }
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0
  If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
      New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
  }
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0

  # Hide taskbar search box
  Write-Output "Hiding task bar search box"
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 0

  # Hide Task View
  Write-Output "Hiding task view"
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 0

  # Hide task Bar People icon
  Write-Output "Hiding task bar people icon"
  If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")) {
      New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" | Out-Null
  }
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type DWord -Value 0

  ######################################################
  # settings-file-explorer.ps1
  ######################################################
  #--- Configuring Windows properties ---
  #--- Windows Features ---
  # Show hidden files, Show protected OS files, Show file extensions
  Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions

  #--- File Explorer Settings ---
  # will expand explorer to the actual folder you're in
  Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneExpandToCurrentFolder -Value 1
  #adds things back in your left pane like recycle bin
  Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneShowAllFolders -Value 1
  #opens PC to This PC, not quick access
  Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Value 1
  #taskbar where window is open for multi-monitor
  Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name MMTaskbarMode -Value 2

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

  ######################################################
  # Taskbar icons
  ######################################################
  Write-Host "Adding Chrome to the TaskBar"
  Install-ChocolateyPinnedTaskBarItem "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
  Write-Host

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

  #
  # Function to create a path if it does not exist
  #
  function CreatePathIfNotExists($pathName) {
    if(!(Test-Path -Path $pathName)) {
        New-Item -ItemType directory -Path $pathName
    }
  }

  #
  # Creating my code directories
  #
  $repoCoreDir = "C:\repos"
  CreatePathIfNotExists -pathName "$repoCoreDir"
  CreatePathIfNotExists -pathName "$repoCoreDir\github"
  CreatePathIfNotExists -pathName "$repoCoreDir\azdo"
  CreatePathIfNotExists -pathName "$repoCoreDir\github\AzureArchitecture"

  cd "$repoCoreDir\github\AzureArchitecture"
  git clone https://github.com/AzureArchitecture/azure-deploy.git
  git clone https://github.com/AzureArchitecture/azure-data-services.git

  ######################################################
  # installing windows updates
  ######################################################
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