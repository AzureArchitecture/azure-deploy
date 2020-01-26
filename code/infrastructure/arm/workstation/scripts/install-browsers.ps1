######################################################
# Installing Browsers
######################################################
Write-Host "Installing Browsers"
choco install googlechrome -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" -force
choco install firefox -y --cacheLocation "$env:UserProfile\AppData\Local\ChocoCache" -force
Write-Host

######################################################
# Taskbar icons
######################################################
Write-Host "Adding Chrome to the TaskBar"
Install-ChocolateyPinnedTaskBarItem "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
Write-Host