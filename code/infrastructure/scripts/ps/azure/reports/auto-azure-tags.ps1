<#
    .DESCRIPTION
        This report is intended for use in Azure Automation. It outputs a report that contains Tags for all resources and resource 
        groups in Azure. The output file is written to temporary storage and transferred to a storage account. 
        NULL tag = No tags for this resource.

    .NOTES
        AUTHOR: Michael Taylor <michael.taylor@cognosante.com>
        LASTEDIT: 8/24/2018
        
    .PARAMETERS
        $StorageAccountName: Name of storage account that will accept transfer of output file
        $StorageAccountResourceGroup: Resource Group that contains storage account.
        $StorageContainerName: Name of container within storage account that will receive output file.

    NAME 
        AzureSubscriptionRBACAudit.ps1    

    SYNOPSIS
        Gathers Azure Role Based Access Control Data for Audit Purposes.

    DESCRIPTION
        Gathers Azure Role Based Access Control Data for Audit Purposes. The script will prompt the user to 
        select a subscription to run the audit against. The user is only presented the scriptions currently 
        available to the users credentials.

    OUTPUTS
        Outputs a CSV file in the same directory that the script is located in. The CSV file will have the 
        name of the subscription in its title followed by "Azure RBAC Audit.csv"
#>

Param (
    [Parameter (Mandatory=$true)]
    [STRING] $StorageAccountName,
    [Parameter (Mandatory=$true)]
    [STRING] $StorageAccountResourceGroup,
    [Parameter (Mandatory=$true)]
    [STRING] $StorageContainerName
)


function Set-AzureLogin{
    
    $connectionName = "AzureRunAsConnection"
    try
    {
        # Get the connection "AzureRunAsConnection "
        $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         
        Write-Output $servicePrincipalConnection

        "Logging in to Azure..."
        Add-AzureRmAccount `
            -ServicePrincipal `
            -TenantId $servicePrincipalConnection.TenantId `
            -ApplicationId $servicePrincipalConnection.ApplicationId `
            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint | Out-Null 
            #-EnvironmentName AzureUSGovernment | Out-Null 
        Write-Output "Logged in."
    }
    catch {
        if (!$servicePrincipalConnection)
        {
            $ErrorMessage = "Connection $connectionName not found."
            throw $ErrorMessage
        } else{
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }

    
}

function Get-FileName ([String]$Report_Name){    
    
    $date=Get-Date -UFormat "%Y%m%d"

    $file_name = $Report_Name + "-" + $date + ".csv"
    
    return $file_name
}

function Invoke-AzureSubscriptionLoop{
    
    Set-AzureLogin
    
    
    # Fetch current working directory 
    $Report_Name = Get-FileName -Report_Name "AzureTagsReport"
    Write-Output ("Writing report " + $Report_Name)

    # Fetching subscription list
    $subscription_list = Get-AzureRmSubscription
    
    # Fetching the IaaS inventory list for each subscription
    foreach($subscription in $subscription_list){

        try {

            #Selecting the Azure Subscription
            Select-AzureRmSubscription -SubscriptionId $subscription 

            $resource_groups = Get-AzureRmResourceGroup 
            
            $export_array = $null
            $export_array = @()
            #Iterate through resource groups
            foreach($resource_group in $resource_groups){
                
                #Get Resource Group Tags
                $rg_tags = (Get-AzureRmResourceGroup -Name $resource_group.ResourceGroupName)
                $Tags = $rg_tags.Tags
                #Checking if tags is null or has value
                if($Tags -ne $null){
                    
                    $Tags.GetEnumerator() | % { 
                        $details = @{            
                            ResourceId = $resource_group.ResourceId
                            Name = $resource_group.ResourceGroupName
                            ResourceType = "Resource-Group"
                            ResourceGroupName =$resource_group.ResourceGroupName
                            Location = $resource_group.Location
                            SubscriptionName = $subscription.Name 
                            Tag_Key = $_.Key
                            Tag_Value = $_.Value
                            }
                         $export_array += New-Object PSObject -Property $details
                         }
                                        

                }else{

                    $TagsAsString = "NULL"
                    $details = @{            
                        ResourceId = $resource_group.ResourceId
                        Name = $resource_group.ResourceGroupName
                        ResourceType = "Resource-Group"
                        ResourceGroupName =$resource_group.ResourceGroupName
                        Location = $resource_group.Location
                        SubscriptionName = $subscription.Name 
                        Tag_Key = "NULL"
                        Tag_Value = "NULL"
                    }                           
                $export_array += New-Object PSObject -Property $details 
                }
            }

            #Getting all Azure Resources
            $resource_list = Get-AzureRmResource
            
            #Declaring Variables
            $TagsAsString = ""

            foreach($resource in $resource_list){
               
                #Fetching Tags
                $Tags = $resource.Tags
    
                #Checking if tags is null or has value
                if($Tags -ne $null){
                    
                    $Tags.GetEnumerator() | % { 
                        $details = @{            
                            ResourceId = $resource.ResourceId
                            Name = $resource.Name
                            ResourceType = $resource.ResourceType
                            ResourceGroupName =$resource.ResourceGroupName
                            Location = $resource.Location
                            SubscriptionName = $subscription.Name 
                            Tag_Key = $_.Key
                            Tag_Value = $_.Value
                            }
                         $export_array += New-Object PSObject -Property $details
                         }
                                        

                }else{

                    $TagsAsString = "NULL"
                    $details = @{            
                    ResourceId = $resource.ResourceId
                    Name = $resource.Name
                    ResourceType = $resource.ResourceType
                    ResourceGroupName =$resource.ResourceGroupName
                    Location = $resource.Location
                    SubscriptionName = $subscription.Name 
                    Tag_Key = "NULL"
                    Tag_Value = "NULL"
                    }                           
                $export_array += New-Object PSObject -Property $details 
                }
            }

            #Generating Output
            Write-Output ("Writing to: " + $Report_Name)
            $export_array | Export-Csv $Report_Name -NoTypeInformation -Append
           
        }
        catch [system.exception]{

	        Write-Output "Error in generating report: $($_.Exception.Message) "
            Write-Output "Error Details are: "
            Write-Output $Error[0].ToString()
	        Exit $ERRORLEVEL
        }
    }     
    # Connect to Storage Account
    Set-AzureRmCurrentestorageAccount `
        -StorageAccountName $StorageAccountName `
        -ResourceGroupName $StorageAccountResourceGroup

    # Transfer output file to Blob storage
    Set-AzureStorageBlobContent `
        -Container $StorageContainerName `
        -File $Report_Name `
        -Blob $Report_Name `
        -Force
}

Invoke-AzureSubscriptionLoop
