<#
    .SYNOPSIS
        This Azure Automation runbook automates the scaling of virtual machines in an Azure subscription. 

    .DESCRIPTION
        This script resizes your Azure VMs using the tags specified on the VMs. The script has 3 parameters - RGEXCEPTIONS,VMEXCEPTIONS,SCALEUP.
        To make this automation script work, we have to specify 2 tags on each desired VM - 'ScaleupSize' and 'ScaledownSize'.
        Specify the VM scale up VM size in the ScaleupSize tag. In the ScaledownSize tag, specify the VM scale down size. Please note that both scale up and scale down
        occurs only if both tags are set correctly on desired VMs. If you want to include a VM in auto scaling later, just add the two tags and they will be added automatically for the schedule.
        
        Example: https://i1.gallery.technet.s-msft.com/rescale-azure-vms-by-using-c6a6a5ae/image/file/206741/1/tags.png

        The script works best with Runbook Scheduler with 2 schedules - For Scale up and Scale down.In Scale Up schedule, set the 'SCALEUP' parameter to $True and in 
        Scale Down schedule, set the 'SCALEUP' parameter to $False.
        
        Also, script assumes that you have created 'Azure Run as Account' and has the default Azure Connection asset 'AzureRunAsConnection'.
         

    .PARAMETER RGEXCEPTIONS

        In 'RGEXCEPTIONS', you can specify the Resource Groups which you need to exclude from scaling. The RGs specified here will not be considered for scaling even if the VMs
        in that RG has scaling tags.

        By default, the value will be null. If you are excluding multiple Resource Groups, enter the names comma separated.

        Example: https://i1.gallery.technet.s-msft.com/rescale-azure-vms-by-using-c6a6a5ae/image/file/206742/1/parameters.png
    
    .PARAMETER VMEXCEPTIONS

        In 'VMEXCEPTIONS', you can specify the Virtual Machines which you need to exclude from scaling. The VMs specified here will not be considered for scaling even if the VMs
        have the scaling tags.

        By default, the value will be null. If you are excluding multiple Virtual Machines, enter the names comma separated.

        Example: https://i1.gallery.technet.s-msft.com/rescale-azure-vms-by-using-c6a6a5ae/image/file/206742/1/parameters.png

    
    .PARAMETER SCALEUP
        The third parameter 'SCALEUP' acts as a switch. If it is set to 'True', all the VMs in the subscription which have scaling tags set and not in
        RGEXCEPTIONS/VMEXCEPTIONS will be scaled up. Else if it is set to 'False', they will be scaled down.
        Defaut value is 'False'.

#>


param( 
    [parameter(Mandatory=$false)] 
    [String] $RGexceptions, 
    [parameter(Mandatory=$false)] 
    [String] $VMexceptions, 
    [parameter(Mandatory=$false)] 
    [bool]$scaleUp = $false 
) 
 
 
$connectionName = "AzureRunAsConnection" 
try 
{ 
    # Get the connection "AzureRunAsConnection " 
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName          
 
    "Logging in to Azure..." 
    Add-AzureRmAccount ` 
        -ServicePrincipal ` 
        -TenantId $servicePrincipalConnection.TenantId ` 
        -ApplicationId $servicePrincipalConnection.ApplicationId ` 
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint  
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
 
 
 
############## TypeCast arrays ################## 
 
[array]$RGexceptions = $RGexceptions.Split(',') 
[array]$VMexceptions = $VMexceptions.Split(',') 
 
############## Switch Scaling Tag ############### 
 
if($scaleUp){ 
$scaleTagSwitch= 'ScaleupSize' 
} 
else{ 
$scaleTagSwitch= 'ScaledownSize' 
 
} 
############## Function for autoscaling ########## 
 
Function Start-VMAutoScaling{ 
    $RGs = Get-AzureRMResourceGroup 
    foreach($RG in $RGs){ 
        $RGN = $RG.ResourceGroupName 
        if($RGN -notin $RGexceptions){ 
            $VMs = Get-AzureRmVM -ResourceGroupName $RGN 
            foreach ($VM in $VMs){ 
                $VMName = $VM.Name 
                if($VMName -notin $VMexceptions){ 
                    $VMDetail = Get-AzureRmVM -ResourceGroupName $RGN -Name $VMName 
                    $ScaleSize = $VMDetail.Tags[$scaleTagSwitch] 
                    $VMSize = $VMDetail.HardwareProfile.VmSize 
                    if(($VMSize -ne $ScaleSize) -and ($ScaleSize)){ 
                        Write-Output "Resource Group: $RGN", ("VM Name: " + $VMName), "Current VM Size: $VMSize", "$scaleTagSwitch : $ScaleSize"  
                        $VMStatus = Get-AzureRmVM -ResourceGroupName $RGN -Name $VMName -Status 
                        if($VMStatus.Statuses[1].DisplayStatus -eq "VM running"){ 
                        Write-Output "Stopping VM '$VMName'" 
                        Stop-AzureRmVM -ResourceGroupName $RGN -Name $VMName -Force | Out-Null 
                        } 
 
                        $VM.HardwareProfile.VmSize = $ScaleSize 
                        Update-AzureRmVM -VM $VM -ResourceGroupName $RGN | Out-Null 
                        Start-AzureRmVM -ResourceGroupName $RGN -Name $VMName | Out-Null 
                        Write-Output "Resized VM '$VMName'" `n 
 
                    } 
                    elseif(!$ScaleSize) { 
                        Write-Output "VM '$VMName' is exempted from scaling (No scale size Tag in VM)" 
                    } 
                    else{ 
                        Write-Output "VM '$VMName' is exempted from scaling (Currrent VM size matches scaling size)" 
                    }            
                }#VM Exception Ends 
                else{ 
                    Write-Output "VM '$VMName' is exempted from scaling (Exemption List)" 
                } 
            } 
        } 
        else{ 
            Write-Output "RG '$RGN' is exempted from scaling (Exemption List)" 
        }#RG Exception Ends 
    } 
} 
 
############## Start autoscaling function ########## 
 
Start-VMAutoScaling 
Write-Output "VM Scaling Completed" 
