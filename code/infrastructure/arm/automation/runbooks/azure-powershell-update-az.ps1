<#
.SYNOPSIS
Function for updating AZ modules in the Azure automation account.

.DESCRIPTION
Function which is downloading all Az modules from the Powershell gallery, creating temporary blob on Azure, hosting them and uploading
them to Azure automation account. After this is done for all of the modules, storage account is being destroyed.

.PARAMETER AutomationAccount
Name of the automation account where you want to update/import AZ set of modules.

.EXAMPLE
Update-AzAutomationModule -AutomationAccount nemanjajovicautomation
#>
Function Update-AzAutomationModule {
    [CmdletBinding()]
    param (
        # Name of the automation account that you want to target.
        [Parameter(Mandatory = $true,
            Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$AutomationAccount
    )
    process {
        $FindAccount = Get-AzAutomationAccount | Where-Object { $_.AutomationAccountName -eq "$AutomationAccount" }
        if ([string]::IsNullOrWhiteSpace($FindAccount)) {
            Write-Error "Cannot find instance of the automation account with the name $AutomationAccount. Terminating!"
            Break
        }
        try {
            $ErrorActionPreference = 'Stop'
            $StorageAccountSplat = @{
                Name = $(Get-Random)
                ResourceGroupName = $FindAccount.ResourceGroupName
                Location = $FindAccount.Location
                SkuName = 'Standard_LRS'
            }
            $StorageAccount = New-AzStorageAccount @StorageAccountSplat
            $StorageKey = (Get-AzStorageAccountKey -ResourceGroupName $StorageAccount.ResourceGroupName -StorageAccountName $StorageAccount.StorageAccountName)[0].Value
            $StorageContext = New-AzStorageContext -StorageAccountName $StorageAccount.StorageAccountName -StorageAccountKey $StorageKey
            $StorageContainer = New-AzStorageContainer -Name $(Get-Random) -Context $StorageContext -Permission Blob
            $AzModuleList = Find-Module 'Az.*'
            foreach ($Module in $AzModuleList) {
                Install-Module $Module.Name -Scope CurrentUser -Force -AllowClobber
                $CompressSplat = @{
                    Path = "$home\Documents\WindowsPowershell\Modules\$($Module.Name)\"
                    DestinationPath = "$home\Documents\WindowsPowershell\Modules\$($Module.Name).zip"
                    ErrorAction = 'Stop'
                    Update = $true
                }
                try {
                    Compress-Archive @CompressSplat
                }
                catch {
                    # If the module files are being locked by another process
                    Copy-Item $CompressSplat.Path -Recurse -Destination "$($CompressSplat.Path).clone" -Force
                    $CompressSplat.Path = $CompressSplat.Path + '.clone\'
                    Compress-Archive @CompressSplat
                }
                $UploadSplat = @{
                    Container = $StorageContainer.Name
                    Context = $StorageContext
                    File = $CompressSplat.DestinationPath
                    Confirm = $false
                }
                $FileUpload = Set-AzStorageBlobContent @UploadSplat
                $ImportSplat = @{
                    Name = $($Module.Name)
                    ResourceGroupName = $FindAccount.ResourceGroupName
                    AutomationAccountName = $FindAccount.AutomationAccountName
                    ContentLinkUri = $FileUpload.Context.BlobEndPoint + $FileUpload.Name
                }
                [void](Import-AzAutomationModule @ImportSplat)
                $RemoveSplat = @{
                    Path = $CompressSplat.Path,$CompressSplat.DestinationPath
                    Recurse = $true
                    Confirm = $false
                    Force = $true
                    ErrorAction = 'SilentlyContinue'
                }
                if (Get-Module $Module.Name) {
                    Remove-Module $Module.Name
                }
                [void](Remove-Item @RemoveSplat)
            }
            Remove-AzStorageAccount $StorageAccount.StorageAccountName -ResourceGroupName $StorageAccount.ResourceGroupName -Confirm:$false -Force
        }
        catch {
            Write-Error "$_" -ErrorAction Stop
        }
    }
}
