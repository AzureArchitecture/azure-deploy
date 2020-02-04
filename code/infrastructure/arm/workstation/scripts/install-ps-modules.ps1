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
