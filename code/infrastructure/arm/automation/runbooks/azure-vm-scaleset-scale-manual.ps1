<#
    .DESCRIPTION
        A runbook that will scale up the Virtual Machine Scale Set instances

    .NOTES
        AUTHOR: Azure Compute Team
        LAST EDIT: March 27, 2019
#>

param (
	[parameter(Mandatory = $false)]
    [object]$WebhookData
)

if ($WebhookData -ne $null) {  
	
	# Returns strings with status messages
	[OutputType([String])]
	
	# Collect properties of WebhookData.
	$WebhookBody    =   $WebhookData.RequestBody
	
	# Obtain the WebhookBody containing the AlertContext
    $WebhookBody = (ConvertFrom-Json -InputObject $WebhookBody)
	
	if ($WebhookBody.status -eq "Activated") {
		
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
		
		# Obtain the AlertContext
		$AlertContext = [object]$WebhookBody.context
		
		$ResourceGroupName = $AlertContext.resourceGroupName
		$VmssName = $AlertContext.resourceName
		
		$noResize = "noresize"
		
		$scaleUp = @{ 
            # A-Series 
            "Basic_A0"         = "Basic_A1" 
            "Basic_A1"         = "Basic_A2" 
            "Basic_A2"         = "Basic_A3" 
            "Basic_A3"         = "Basic_A4" 
            "Basic_A4"         = $noResize
            "Standard_A0"      = "Standard_A1" 
            "Standard_A1"      = "Standard_A2" 
            "Standard_A2"      = "Standard_A3" 
            "Standard_A3"      = "Standard_A4" 
            "Standard_A4"      = $noResize 
            "Standard_A5"      = "Standard_A6" 
            "Standard_A6"      = "Standard_A7" 
            "Standard_A7"      = $noResize 
            "Standard_A8"      = "Standard_A9" 
            "Standard_A9"      = $noResize 
            "Standard_A10"     = "Standard_A11" 
            "Standard_A11"     = $noResize 
            "Standard_A1_v2"   = "Standard_A2_v2" 
            "Standard_A2_v2"   = "Standard_A4_v2" 
            "Standard_A4_v2"   = "Standard_A8_v2" 
            "Standard_A8_v2"   = $noResize 
            "Standard_A2m_v2"  = "Standard_A4m_v2" 
            "Standard_A4m_v2"  = "Standard_A8m_v2" 
            "Standard_A8m_v2"  = $noResize
            # B-Series 
            "Standard_B1s"     = "Standard_B2s" 
            "Standard_B2s"     = $noResize
            "Standard_B1ms"    = "Standard_B2ms" 
            "Standard_B2ms"    = "Standard_B4ms" 
            "Standard_B4ms"    = "Standard_B8ms"
            "Standard_B8ms"    = $noResize
            # D-Series 
            "Standard_D1"      = "Standard_D2"  
            "Standard_D2"      = "Standard_D3" 
            "Standard_D3"      = "Standard_D4" 
            "Standard_D4"      = $noResize 
            "Standard_D11"     = "Standard_D12" 
            "Standard_D12"     = "Standard_D13" 
            "Standard_D13"     = "Standard_D14" 
            "Standard_D14"     = $noResize
            "Standard_DS1"     = "Standard_DS2" 
            "Standard_DS2"     = "Standard_DS3" 
            "Standard_DS3"     = "Standard_DS4" 
            "Standard_DS4"     = $noResize 
            "Standard_DS11"    = "Standard_DS12" 
            "Standard_DS12"    = "Standard_DS13" 
            "Standard_DS13"    = "Standard_DS14" 
            "Standard_DS14"    = $noResize 
            "Standard_D1_v2"   = "Standard_D2_v2" 
            "Standard_D2_v2"   = "Standard_D3_v2" 
            "Standard_D3_v2"   = "Standard_D4_v2" 
            "Standard_D4_v2"   = "Standard_D5_v2" 
            "Standard_D5_v2"   = $noResize 
            "Standard_D11_v2"  = "Standard_D12_v2" 
            "Standard_D12_v2"  = "Standard_D13_v2" 
            "Standard_D13_v2"  = "Standard_D14_v2" 
            "Standard_D14_v2"  = $noResize 
            "Standard_DS1_v2"  = "Standard_DS2_v2" 
            "Standard_DS2_v2"  = "Standard_DS3_v2" 
            "Standard_DS3_v2"  = "Standard_DS4_v2" 
            "Standard_DS4_v2"  = "Standard_DS5_v2" 
            "Standard_DS5_v2"  = $noResize 
            "Standard_DS11_v2" = "Standard_DS12_v2" 
            "Standard_DS12_v2" = "Standard_DS13_v2" 
            "Standard_DS13_v2" = "Standard_DS14_v2" 
            "Standard_DS14_v2" = $noResize                        
            "Standard_D2_v3"   = "Standard_D4_v3" 
            "Standard_D4_v3"   = "Standard_D8_v3" 
            "Standard_D8_v3"   = "Standard_D16_v3" 
            "Standard_D16_v3"  = "Standard_D32_v3" 
            "Standard_D32_v3"  = "Standard_D64_v3" 
            "Standard_D64_v3"  = $noResize
            "Standard_D2s_v3"  = "Standard_D4s_v3" 
            "Standard_D4s_v3"  = "Standard_D8s_v3" 
            "Standard_D8s_v3"  = "Standard_D16s_v3" 
            "Standard_D16s_v3" = "Standard_D32s_v3" 
            "Standard_D32s_v3" = "Standard_D64s_v3" 
            "Standard_D64s_v3" = $noResize
            "Standard_DC2s"    = "Standard_DC4s" 
            "Standard_DC4s"    = $noResize
            # E-Series 
            "Standard_E2_v3"   = "Standard_E4_v3" 
            "Standard_E4_v3"   = "Standard_E8_v3" 
            "Standard_E8_v3"   = "Standard_E16_v3" 
            "Standard_E16_v3"  = "Standard_E20_v3" 
            "Standard_E20_v3"  = "Standard_E32_v3" 
            "Standard_E32_v3"  = "Standard_E64_v3" 
            "Standard_E64_v3"  = $noResize
            "Standard_E2s_v3"  = "Standard_E4s_v3" 
            "Standard_E4s_v3"  = "Standard_E8s_v3" 
            "Standard_E8s_v3"  = "Standard_E16s_v3" 
            "Standard_E16s_v3" = "Standard_E20s_v3" 
            "Standard_E20s_v3" = "Standard_E32s_v3" 
            "Standard_E32s_v3" = "Standard_E64s_v3" 
            "Standard_E64s_v3" = $noResize
            # F-Series
            "Standard_F1"      = "Standard_F2"  
            "Standard_F2"      = "Standard_F4" 
            "Standard_F4"      = "Standard_F8" 
            "Standard_F8"      = "Standard_F16" 
            "Standard_F16"     = $noResize 
            "Standard_F1s"     = "Standard_F2s"  
            "Standard_F2s"     = "Standard_F4s" 
            "Standard_F4s"     = "Standard_F8s" 
            "Standard_F8s"     = "Standard_F16s" 
            "Standard_F16s"    = $noResize 
            "Standard_F2s_v2"  = "Standard_F4s_v2"  
            "Standard_F4s_v2"  = "Standard_F8s_v2" 
            "Standard_F8s_v2"  = "Standard_F16s_v2" 
            "Standard_F16s_v2" = "Standard_F32s_v2" 
            "Standard_F32s_v2" = "Standard_F64s_v2" 
            "Standard_F64s_v2" = "Standard_F7s_v2" 
            "Standard_F72s_v2" = $noResize
            # G-Series 
            "Standard_G1"      = "Standard_G2"  
            "Standard_G2"      = "Standard_G3" 
            "Standard_G3"      = "Standard_G4"  
            "Standard_G4"      = "Standard_G5"   
            "Standard_G5"      = $noResize 
            "Standard_GS1"     = "Standard_GS2"  
            "Standard_GS2"     = "Standard_GS3" 
            "Standard_GS3"     = "Standard_GS4" 
            "Standard_GS4"     = "Standard_GS5" 
            "Standard_GS5"     = $noResize
            # H-Series
            "Standard_H8"      = "Standard_H16"  
            "Standard_H16"     = $noResize 
            "Standard_H8m"     = "Standard_H16m"                         
            "Standard_H16m"    = $noResize             
            # L-Series             
            "Standard_L4s"     = "Standard_L8s"  
            "Standard_L8s"     = "Standard_L16s" 
            "Standard_L16s"    = "Standard_L32s"  
            "Standard_L32s"    = $noResize
            "Standard_L8s_v2"  = "Standard_L16s_v2"  
            "Standard_L16s_v2" = "Standard_L32s_v2" 
            "Standard_L32s_v2" = "Standard_L64s_v2"  
            "Standard_L64s_v2" = "Standard_L80s_v2"
            "Standard_L80s_v2" = $noResize
            # M-Series 
            "Standard_M8ms"    = "Standard_M16ms"  
            "Standard_M16ms"   = "Standard_M32ms" 
            "Standard_M32ms"   = "Standard_M64ms"  
            "Standard_M64ms"   = "Standard_M128ms"  
            "Standard_M128ms"  = $noResize
            "Standard_M32ls"   = "Standard_M64ls"
            "Standard_M64ls"   = $noResize  
            "Standard_M64s"    = "Standard_M128s" 
            "Standard_M128s"   = $noResize  
            "Standard_M64"     = "Standard_M128"  
            "Standard_M128"    = $noResize  
            "Standard_M64m"    = "Standard_M128m"  
            "Standard_M128m"   = $noResize              
            # N-Series
            "Standard_NC6"     = "Standard_NC12"  
            "Standard_NC12"    = "Standard_NC24" 
            "Standard_NC24"    = $noResize 
            "Standard_NC6s_v2" = "Standard_NC12s_v2"  
            "Standard_NC12s_v2"= "Standard_NC24s_v2" 
            "Standard_NC24s_v2"= $noResize 
            "Standard_NC6s_v3" = "Standard_NC12s_v3"  
            "Standard_NC12s_v3"= "Standard_NC24s_v3" 
            "Standard_NC24s_v3"= $noResize
             "Standard_ND6"    = "Standard_ND12"  
            "Standard_ND12"    = "Standard_ND24" 
            "Standard_ND24"    = $noResize 
            "Standard_NV6"     = "Standard_NV12"  
            "Standard_NV12"    = "Standard_NV24" 
            "Standard_NV24"    = $noResize 
            "Standard_NV6s_v2" = "Standard_NV12s_v2"  
            "Standard_NV12s_v2"= "Standard_NV24s_v2" 
            "Standard_NV24s_v2"= $noResize             
        } 
		
		try {
		    $vmss = Get-AzureRmVmss -ResourceGroupName $ResourceGroupName -VMScaleSetName $VmssName -ErrorAction Stop
		} catch {
		    Write-Error "Virtual Machine Scale Set not found"
		    exit
		}
		
		$currentVmssSize = $vmss.Sku.Name
		
		Write-Output "`nFound the specified Virtual Machine Scale Set: $VmssName"
		Write-Output "Current size: $currentVmssSize"
		
		$newVmssSize = ""
		
		$newVmssSize = $scaleUp[$currentVmssSize]
		
		if($newVmssSize -eq $noResize -or [string]::IsNullOrEmpty($newVMSize)) {
		    Write-Output "Sorry the current Virtual Machine Scale Set size $currentVmssSize can't be scaled up. You'll need to recreate the specified Virtual Machine Scale Set with your requested size"
		} else {
		    Write-Output "`nNew size will be: $newVmssSize"

			$vmss.Sku.Name = $newVmssSize
		    Update-AzureRmVmss -ResourceGroupName $ResourceGroupName -Name $VmssName -VirtualMachineScaleSet $vmss
			Update-AzureRmVmssInstance -ResourceGroupName $ResourceGroupName -VMScaleSetName $VmssName -InstanceId "*"
				
		    $updatedVmss = Get-AzureRmVmss -ResourceGroupName $ResourceGroupName -VMScaleSetName $VmssName
		    $updatedVmssSize = $updatedVmss.Sku.Name

		    Write-Output "`nSize updated to: $updatedVmssSize"
		}
	} else {
		Write-Output "`nAlert not activated"
		exit
	}
}
else 
{
    Write-Error "This runbook is meant to only be started from a webhook." 
}
