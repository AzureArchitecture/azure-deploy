<#
	.NOTES
	===========================================================================
	 Created on:   	2018-06-01
	 Created by:   	Arash Nabi - arash@nabi.nu
	===========================================================================


	.SYNOPSIS
		Copy-ToAzureBlob will copy files from $path to Azure Blob.
		The Azure powershell module should be installed, otherwise the script will fail.
		You can download it from https://www.powershellgallery.com/.

        
	
	.EXAMPLE
				PS C:\> Copy-ToAzureBlob -Path $value1
		
#>
function Copy-ToAzureBlob
{
	[CmdletBinding()]
	[Alias()]
	[OutputType([int])]
	param
	(
		[Parameter(Mandatory = $true,
				   ValueFromPipelineByPropertyName = $true,
				   Position = 0)]
		$Path
	)
	
	Begin
	{
	}
	Process
	{
		try
		{
			
			$VerbosePreference = 'Ignore'
			# Check if the Azure modules are loaded
			If ((Get-Module -Name Azure.Storage -ListAvailable).Count -le 0)
			{
				# Azure Storage module is not available Exit script
				Write-Warning "ERROR: The Azure module is not available, exiting script"
				Write-Warning "Please download the Azure PowerShell modules from https://www.powershellgallery.com/"
				
				return
			}
			else
			{
				Write-Output "The Azure module is available and loaded..."
			}
			
			# details about Service Principal account. This part will authenticat to Azure.
			$u = "APPLICATION_id@COMPANYNAME.onmicrosoft.com" # application ID
			$key = "KEY" # Key
			$tenantid = "TENANT_ID"
			$pass = ConvertTo-SecureString $key -AsPlainText –Force
			$cred = New-Object -TypeName pscredential –ArgumentList $u, $pass
			Login-AzureRmAccount -Credential $cred -ServicePrincipal –TenantId $tenantid
			
			
			$Global:AzureStorageAccountName = "STORAGE ACCOUNT" # STORAGE ACCOUNT NAME
			$Global:AzureStorageAccountKey = "STORAGE ACCOUNT KEY" # STORAGE ACCOUNT KEY
			$Container = "backup" # Name of Container where the backup will be store.
			
			
			# Initiate the Azure Storage Context
			$context = New-AzureStorageContext -StorageAccountName $Global:AzureStorageAccountName -StorageAccountKey $Global:AzureStorageAccountKey
			
			# Check if the defined container already exists
			Write-Output "Checking availability of Azure container `"$Container`""
			$azcontainer = Get-AzureStorageContainer -Name $Container -Context $context -ErrorAction stop
			Get-AzureStorageBlob -Container $Container -Context $context | ForEach-Object {
				Write-Output "Removing Azure container and $($_.Name) `"$Container`""
				Remove-AzureStorageBlob -Blob $_.Name -Container $Container -Context $context -ErrorAction stop
			}
			
			If ($? -eq $false)
			{
				# Something went wrong, check the last error message
				If ($Error[0] -like "*Can not find the container*")
				{
					# Container doesn't exist, create a new one
					Write-Output "Container `"$Container`" does not exist, trying to create container"
					$azcontainer = New-AzureStorageContainer -Name $Container -Context $context -ErrorAction stop
				}
			}
			# Retrieve the files in the given folders
			if (Test-Path -Path $path)
			{
				ForEach ($localpath in $Path) 
				{
					$GetFiles = get-childitem -Path $Path -Recurse 
					ForEach ($file in $GetFiles | Where-Object { $_.PSIsContainer -eq $false })
					{
						Set-AzureStorageBlobContent -File $file.FullName -Blob $blobname -Container $Container -Context $context -Force -ErrorAction stop
					}
				}
			}
			else
			{
				Write-Warning "$path is not correct!"
			}
			
			
		}
		    # Catch specific types of exceptions thrown by one of those commands
		    catch [System.Net.WebException], [System.Exception] {
			Write-Warning -Message $Error[0].Exception.Message
		}
		
		
	}
	
}		
