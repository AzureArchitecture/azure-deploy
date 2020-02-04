<#
    .DESCRIPTION
        This report outputs a backup status report for SQL PaaS servers in Azure.

    .NOTES
        AUTHOR: Michael Taylor <jay.taylor@va.gov> <michael.taylor@cognosante.com>
        LASTEDIT: 8/24/2018

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

#Requires –Modules AzureRM
#Requires –Modules AzureRM.Backup
#Requires –Modules AzureRM.RecoveryServices
#Requires –Modules AzureRM.SiteRecovery

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
    $Report_Name = Get-FileName -Report_Name "AzureSQLBackupReport"

    # Fetching subscription list
    $subscription_list = Get-AzureRmSubscription 
    
    # Fetching the IaaS inventory list for each subscription
    foreach($subscription_list_iterator in $subscription_list){

        echo $subscription_list_iterator.Name
        Get-AzureSQLBackupReport -subscription_ID $subscription_list_iterator.id -subscription_name $subscription_list_iterator.Name -Report_Name $Report_Name
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

 function Get-AzureSQLBackupReport ([String]$subscription_ID,[String]$subscription_name,[String]$Report_Name) {

    #$ErrorActionPreference = "SilentlyContinue"

    $subscription_ID=$subscription_ID.Trim()
    $subscription_name=$subscription_name.Trim()

    # Selecting the subscription
    Select-AzureRmSubscription -Subscription $subscription_ID

    $resource_groups = Get-AzureRmResourceGroup -Verbose
    $export_array = $null
    $export_array = @()
    
    #Iterate through resource groups
    foreach($resource_group in $resource_groups){
        
        $resource_group_name = $resource_group.ResourceGroupName

        $sqlServers = Get-AzureRmSqlServer -ResourceGroupName $resource_group_name

        #Iterate through VMs
        foreach($sqlServer in $sqlServers){
            
            $sqlDatabases = Get-AzureRmSqlDatabase -ResourceGroupName $resource_group_name -ServerName $sqlServer.ServerName
         
            foreach($sqlDatabase in $sqlDatabases) {

                if(-NOT ($sqlDatabase.DatabaseName -eq 'master')) {
                    
                    $azureSQLDatabaseBackup = Get-AzureRmSqlDatabaseGeoBackup -ResourceGroupName $resource_group_name -ServerName $sqlServer.ServerName -DatabaseName $sqlDatabase.DatabaseName
                    
                    $azure_SQL_Backup_object = [PSCustomObject]@{
                        SubscriptionName = ""
                        ResourceGroupName = ""
                        SQLServerName = ""
                        SQLDatabaseName = ""
                        Edition = ""
                        LastAvailableBackupDate = ""
                        ResourceId = ""
                    }

                    $azure_SQL_Backup_object.SubscriptionName = $subscription_name
                    $azure_SQL_Backup_object.ResourceGroupName = $azureSQLDatabaseBackup.ResourceGroupName
                    $azure_SQL_Backup_object.SQLServerName = $azureSQLDatabaseBackup.ServerName
                    $azure_SQL_Backup_object.SQLDatabaseName = $azureSQLDatabaseBackup.DatabaseName
                    $azure_SQL_Backup_object.Edition = $azureSQLDatabaseBackup.Edition
                    $azure_SQL_Backup_object.LastAvailableBackupDate = $azureSQLDatabaseBackup.LastAvailableBackupDate
                    $azure_SQL_Backup_object.ResourceId = $azureSQLDatabaseBackup.ResourceId

                    $export_array += New-Object PSObject -Property $azure_SQL_Backup_object
                }
            }
        }
      
    }
    $echo = "Writing to: " + $Report_Name
    echo $echo
    $export_array | Export-Csv $Report_Name -NoTypeInformation -Append

}

Invoke-AzureSubscriptionLoop
