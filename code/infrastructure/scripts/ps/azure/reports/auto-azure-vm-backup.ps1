<#
    .DESCRIPTION
        This report outputs a backup status report for all virtual machines within Azure.

    .NOTES
        AUTHOR: J. Michael Taylor <jay.taylor@va.gov | michael.taylor@cognosante.com>
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
    $Report_Name = Get-FileName -Report_Name "AzureVMReport"

    # Fetching subscription list
    $subscription_list = Get-AzureRmSubscription
    
    # Fetching the IaaS inventory list for each subscription
    foreach($subscription in $subscription_list){

        Get-AzureVMBackupReport -subscription_ID $subscription.Id -subscription_name $subscription.Name -Report_Name $Report_Name
       
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

function Get-AzureVMBackupReport ([String]$subscription_ID,[String]$subscription_name,[String]$Report_Name) {

    $subscription_ID=$subscription_ID.Trim()
    $subscription_name=$subscription_name.Trim()

    Write-Output ("Subscription ID: " + $subscription_ID)
    Write-Output ("Subscription Name: " + $subscription_name)

    # Selecting the subscription
    Select-AzureRmSubscription -SubscriptionId $subscription_ID

    $resource_groups = Get-AzureRmResourceGroup

    #Iterate through resource groups
    foreach($resource_group in $resource_groups){
        
        # Initialize Objects
        $VM_array = $null
        $VM_array = @()
        
        $vm_list = Get-AzureRmVM -ResourceGroupName $resource_group.ResourceGroupName -Verbose 
        
        #Iterate through VMs
        foreach($vm in $vm_list){
            
            $virtual_machine_backup = [PSCustomObject]@{
                SubscriptionName = ""
                ResourceGroupName = ""
                VMName = ""
                Location = ""
                VMSize = ""
                OSDisk = ""
            }

            $virtual_machine_backup.SubscriptionName = $subscription_name
            $virtual_machine_backup.ResourceGroupName = $resource_group.ResourceGroupName
            $virtual_machine_backup.VMName = $vm.Name
            $virtual_machine_backup.Location = $vm.Location
            $virtual_machine_backup.VMSize = $vm.HardwareProfile.VmSize
            $virtual_machine_backup.OSDisk = $vm.StorageProfile.OsDisk.OsType

            $VM_array += $virtual_machine_backup

        }
        #$azure_VM_array | Export-Csv "AzureVMReport.csv" -NoTypeInformation -Append

        # Initialize Objects
        $backup_array = $null
        $backup_array = @()
        $recovery_vault_list = Get-AzureRmRecoveryServicesVault -ResourceGroupName $resource_group.Name

        foreach($rsv in $recovery_vault_list) {

            Set-AzureRmRecoveryServicesVaultContext -Vault $rsv
                
            $container_list = Get-AzureRmRecoveryServicesBackupContainer -ContainerType AzureVM 

            foreach($container in $container_list){

                $backup_items = Get-AzureRmRecoveryServicesBackupItem -Container $container -WorkloadType "AzureVM"
                
                foreach($backup in $backup_items) {

                    $backup_object = [PSCustomObject]@{
                        SubscriptionName = ""
                        ResourceGroupName = ""
                        RecoveryVault = ""
                        FriendlyName = ""
                        ProtectionStatus = ""
                        ProtectionState = ""
                        LastBackupTime = ""
                        ProtectionPolicyName = ""
                        LatestRecoveryPoint = ""
                    }

                    $backup_object.SubscriptionName = $subscription_name
                    $backup_object.ResourceGroupName = $resource_group.ResourceGroupName
                    $backup_object.RecoveryVault = $rsv.Name
                    $backup_object.FriendlyName = $container.FriendlyName
                    $backup_object.ProtectionStatus = $backup.ProtectionStatus
                    $backup_object.ProtectionState = $backup.LastBackupStatus
                    $backup_object.LastBackupTime = $backup.LastBackupTime
                    $backup_object.ProtectionPolicyName = $backup.ProtectionPolicyName
                    $backup_object.LatestRecoveryPoint = $backup.LatestRecoveryPoint
                    
                    if(-Not($backup_array.FriendlyName -contains $backup_object.FriendlyName)) {
                        $backup_array += $backup_object
                    }
                }

            }
           
        }
       
        Write-Output ("Building VM Backup Report for RG: " + $resource_group.ResourceGroupName  + " SUB: " + $subscription_name)

        # Initialize Object
        $export_array = $null
        $export_array = @()

        foreach($vm in $VM_array) {

            $export_object = [PSCustomObject]@{
                SubscriptionName = ""
                ResourceGroupName = ""
                VMName = ""
                Location = ""
                VMSize = ""
                OSDisk = ""
                RecoveryVault = ""
                ProtectionStatus = ""
                ProtectionState = ""
                LastBackupTime = ""
                ProtectionPolicyName = ""
                LatestRecoveryPoint = ""
            }

            $backup = $backup_array | ?{($_.FriendlyName.Trim() -eq $vm.VMName.Trim())}
            $export_object.SubscriptionName = $subscription_name
            $export_object.ResourceGroupName = $vm.ResourceGroupName
            $export_object.VMName = $vm.VMName
            $export_object.Location = $vm.Location
            $export_object.VMSize = $vm.VMSize
            $export_object.OSDisk = $vm.OSDisk
            $export_object.RecoveryVault = $backup.RecoveryVault
            $export_object.ProtectionStatus = $backup.ProtectionStatus
            $export_object.ProtectionState = $backup.ProtectionState
            $export_object.LastBackupTime = $backup.LastBackupTime
            $export_object.ProtectionPolicyName = $backup.ProtectionPolicyName
            $export_object.LatestRecoveryPoint = $backup.LatestRecoveryPoint

            $export_array += $export_object

        }
        Write-Output ("Writing to: " + $Report_Name)
        $export_array | Export-Csv $Report_Name -NoTypeInformation -Append
            
    }

    
    
}

Invoke-AzureSubscriptionLoop



