param(
    [Parameter(Mandatory = $false)][string]$rdpPort = "3389"
)

<#function writeToLog {
param ([string]$message)
$scriptPath = "."
$deploylogfile = "$scriptPath\deploymentlog.log"
$temptime = get-date -f yyyy-MM-dd--HH:mm:ss
"whhooo Went to test function $message $temptime" | out-file $deploylogfile -Append
}#>

Process {
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
    . choco.exe install git.install
    . choco.exe install vscode
    . choco.exe install googlechrome -y
    . choco.exe install azcopy
	  . choco.exe install github-desktop -y
	  . choco.exe install azuredatastudio-powershell -y
	  . choco.exe install azure-data-studio -y
	  . choco.exe install ssis-vs2019 -y
	  . choco.exe install sql-server-management-studio -y
	  . choco.exe install office365business -y
	  . choco.exe install adobereader -y
	  . choco.exe install sysinternals -y

	  Invoke-Expression "c:\users\vmAdmin\scripts\taskbarpin.vbs 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'"

    # . choco.exe install visioviewer2016

    #add the AZCOPY path to the path variable
    $AZCOPYpath = "C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy"
    $actualPath = ((Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment" -Name PATH).path)
    $NEWPath = "$actualPath;$AZCOPYpath"
    $NEWPath | Out-File $scriptPath\azcopySystemPath.log
    Set-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment" -Name PATH -Value $NEWPath

    #install Powershell AZ module
    Install-PackageProvider -name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Module -Name Az -AllowClobber -force



    #setting the time zone to eastern
    & "$env:windir\system32\tzutil.exe" /s "Eastern Standard Time"

    #disable IE enhache Security
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
    Stop-Process -Name Explorer

    #copy batch file to install VSC extention on the public desktop
    Copy-Item -Path "$scriptpath\InstallVSCExtensions.bat" -Destination "C:\Users\devAdmin\Desktop\InstallVSCExtensions.bat"
	Copy-Item -Path "$scriptpath\dpi30.ico" -Destination "C:\Azure\dpi30.ico"
	Copy-Item -Path "$scriptpath\change-desktop-icon-size.psm1" -Destination "C:\Azure\change-desktop-icon-size.psm1"
	Copy-Item -Path "$scriptpath\set-rv-short.psm1" -Destination "C:\Azure\set-rv-short.psm1"
	Copy-Item -Path "$scriptpath\use-small.psm1" -Destination "C:\Azure\use-small.psm1"
	Copy-Item -Path "$scriptpath\task-bar.vbs" -Destination "C:\Azure\task-bar.vbs"

	 #adding a VSC shortcut on the public desktop
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("c:\Users\devAdmin\Desktop\Visual Studio Code.lnk")
    $Shortcut.TargetPath = "C:\Program Files\Microsoft VS Code\Code.exe"
    $Shortcut.Arguments = '"C:\Azure\DPi30"'
    $Shortcut.Save()

    #disable server manager at login time
    Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask -Verbose

    # Clone Azure DPi30 repo
    New-Item -ItemType directory -Path "C:\Azure"
    Set-Location -Path "C:\Azure"
    . "C:\Program Files\Git\bin\git.exe" clone https://github.com/DPi30-Team/ARM
    Set-Location -Path $scriptPath

    Install-Module PSWindowsUpdate -force
	Get-WUInstall -AcceptAll -MicrosoftUpdate -Verbose

	$temptime = Get-Date -f yyyy-MM-dd--HH:mm:ss
    "Ending deployment script - $temptime" | Out-File $deploylogfile -Append
	Copy-Item -Path $deploylogfile -Destination "C:\Azure\deploymentlog.log"
}