 $psscriptsRoot = $PSScriptRoot
 $extensionFilepath = "..\dev-vm\files\$psscriptsRoot"
 Set-Location -Path "$psscriptsRoot"

 #
 # Function for installing Visual Studio Extension
 #
 function Install-VSExtension($extensionUrl, $extensionFileName, $extensionFilepath) {
    $vsixInstallerCommand = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\IDE\VsixInstaller.exe"
    $vsixInstallerCommandGeneralArgs = " /q /a "

    Write-Host "Installing extension $extensionFileName"
    Write-Host "Using devnev $vsixInstallerCommand"

    # Download the extension
    # Write-Host $psscriptsRoot\$extensionFileName
    # Invoke-WebRequest $extensionUrl -OutFile $psscriptsRoot\$extensionFileName

    # Quiet Install of the Extension
    $proc = Start-Process -FilePath "$vsixInstallerCommand" -ArgumentList ($vsixInstallerCommandGeneralArgs + $extensionFilepath +'\' + $extensionFileName) -PassThru
    $proc.WaitForExit()
    if ( $proc.ExitCode -ne 0 ) {
        Write-Host "Unable to install extension " $extensionFileName " due to error " $proc.ExitCode -ForegroundColor Red
    }

    # Delete the downloaded extension file from the local system
    Remove-Item $extensionFileName
 }

 #
 # Function to create a path if it does not exist
 #
 function CreatePathIfNotExists($pathName) {
    if(!(Test-Path -Path $pathName)) {
        New-Item -ItemType directory -Path $pathName
    }
 }
 function DownloadAndCopy($link, $targetFolder) {
    CreatePathIfNotExists($targetFolder)

    if(!(Test-Path -Path $targetFolder)) {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest $link -OutFile $targetFolder
    }
 }

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

Install-VSExtension -extensionUrl "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/GitHub/vsextensions/GitHubExtensionforVisualStudio/2.10.8.8132/vspackage" -extensionFileName "GitHub.VisualStudio-v2.10.8.8132.vsix"
