<#   
.SYNOPSIS   
    Resizing a specific Resource Group Azure VM according to a 
    schedule using Azure Automation.
    
    This script is based on Jorg Klein script for scaling schedule: https://jorgklein.com/2017/09/19/azure-sql-database-scheduled-autoscaling/
	This script is based on Siebert Timmermans script for VM scaling: https://gallery.technet.microsoft.com/scriptcenter/scheduled-vm-resizes-with-2d74c45b
   
.DESCRIPTION
	This script will adjust the size of a Microsoft Azure virtual machine based on input given into the new schedule.
	Autoscaling based on a schedule allows you to scale your solution according to predictable resource demand.

.PARAMETER resourceGroupName
    Name of the resource group to which the service plan is 
    assigned.

.PARAMETER virtualMachineName
     String name of the VM that will be changed in size.

.PARAMETER virtualMachineSize
     String name of the desired size the specified VM will be receiving.	
	
.PARAMETER azureRunAsConnectionName
    Azure Automation Run As account name. Needs to be able to access
    the $serverName.
       
.PARAMETER appServicePlan   
    Azure Service Plan name (case sensitive).

.PARAMETER scalingSchedule
    AppService Scaling Schedule. It is possible to enter multiple 
    comma separated schedules: [{},{}]
    Weekdays start at 0 (sunday) and end at 6 (saturday).
    If the script is executed outside the scaling schedule time slots
    that you defined, the defaut edition/tier (see below) will be 
    configured.

.PARAMETER scalingScheduleTimeZone
    Time Zone of time slots in $scalingSchedule. 
    Available time zones: [System.TimeZoneInfo]::GetSystemTimeZones().

Allowed 'VMSize'values:

DS:
Standard_DS1,Standard_DS2,Standard_DS3,Standard_DS4,Standard_DS11,Standard_DS12,Standard_DS13,Standa
rd_DS14,Standard_DS1_v2,Standard_DS
2_v2,Standard_DS3_v2,Standard_DS4_v2,Standard_DS5_v2,Standard_DS11_v2,Standard_DS12_v2,Standard_DS13_v2,Standard_DS14_v2
,Standard_DS15_v2

A:
Standard_A0,Standard_A1,Standard_A2,Standard_A3,Standard_A5,Standard_A4,Standard_A6,Standard_A7,Basic_A0,Basic_A
1,Basic_A2,Basic_A3,Basic_A4, Standard_A1_v2,Standard_A2m_v2,Standard_A2_v2,Standard_A4m_v2,Standard_A4_v2,Standard_A8m_v2,Standard_A8_v2,
Standard_A8,Standard_A9,Standard_A10,Standard_A11

B:
Standard_B1s,Standard_B1ms,Standard_B2s,Standard_B2ms,Standard_B4ms,Standard_B8ms

D:
Standard_D1_v2,Standard_D2_v2,Standard_D3_v2,Standard_D4_v2,Standard_D5_v2,Standard_D11_v2,
Standard_D12_v2,Standard_D13_v2,Standard_D14_v2,Standard_D15_v2,Standard_D1,Standard_D2,Standard_D3,Standard_D4,Standard_D11,Standard_D12,Standard_D13,Standard_D14

F:
Standard_F1,Standard_F2,Standard_F4,Standard_F8,Standard_F16,Standard_F1s,Standard_F2s,Standard_F4s,Standard_F8s,Standard_F16s	
	
.EXAMPLE
        -resourceGroupName myResourceGroup
        -virtualMachineName myVirtualMachineName
		-virtualMachineSize myVirtualMachineSize
        -azureRunAsConnectionName AzureRunAsConnection       
        -scalingSchedule [{WeekDays:[1, 2, 3, 4, 5]]
        -scalingScheduleTimeZone Central Europe Standard Time
        -requestUrl https://google.com
   
.NOTES   
    Author: Gabor Szoboszlai
    Last Update: Aug 2018   
#>

param(
[parameter(Mandatory=$true)]
[string] $resourceGroupName,

[parameter(Mandatory=$true)]
[String] $virtualMachineName,

[parameter(Mandatory=$true)]
[string] $virtualMachineSize,

[parameter(Mandatory=$false)]
[string] $scalingSchedule = "[{WeekDays:[1, 2, 3, 4, 5]}]",

[parameter(Mandatory=$false)]
[string] $azureRunAsConnectionName = "AzureRunAsConnection",

[parameter(Mandatory=$false)]
[string] $scalingScheduleTimeZone = "Central Europe Standard Time",

[parameter(Mandatory=$false)]
[string] $requestUrl
)

#Authenticate with Azure Automation Run As account (service principal)  
$runAsConnectionProfile = Get-AutomationConnection `
-Name $azureRunAsConnectionName
Add-AzureRmAccount -ServicePrincipal `
-TenantId $runAsConnectionProfile.TenantId `
-ApplicationId $runAsConnectionProfile.ApplicationId `
-CertificateThumbprint ` $runAsConnectionProfile.CertificateThumbprint | Out-Null
Write-Output "Authenticated with Automation Run As Account."

#Get current date/time and convert to $scalingScheduleTimeZone
$stateConfig = $scalingSchedule | ConvertFrom-Json
$startTime = Get-Date

#Get current day of week, based on converted start time
$currentDayOfWeek = [Int]($startTime).DayOfWeek
Write-Output "Current day of week: $currentDayOfWeek."

# Get the scaling schedule for the current day of week
$dayObjects = $stateConfig | Where-Object {$_.WeekDays -contains $currentDayOfWeek } 

if($dayObjects -ne $null) { # Scaling schedule found for this day
    
    Write-Output "Specified VM name: [$virtualMachineName]"
    Write-Output "Specified VM Resource Group: [$resourceGroupName]"
    Write-Output "Desired VM size: [$virtualMachineSize]"
    Write-Output "`n----------------------------------------------------------------------"
    
# Check if specified VM can be found
    try {
		$virtualMachine = Get-AzureRmVm -ResourceGroupName $resourceGroupName -VMName $virtualMachineName -ErrorAction Stop
    } catch {
		Write-Error "Virtual Machine not found"
		exit
    }
	
# Output current VM Size
    $currentVMSize = $virtualMachine.HardwareProfile.vmSize
    
    Write-Output "`nFound the specified Virtual Machine: $virtualMachineName"
    Write-Output "Current size: $currentVMSize"	
	
# Change to new VM Size and report   
	Write-Output "`nNew size will be: $virtualMachineSize"
	Write-Output "`n----------------------------------------------------------------------"
		
	$virtualMachine.HardwareProfile.VmSize = $virtualMachineSize
	Update-AzureRmVm -VM $virtualMachine -ResourceGroupName $resourceGroupName
	
	$updatedVM = Get-AzureRmVm -ResourceGroupName $resourceGroupName -VMName $virtualMachineName
	$updatedVMSize = $updatedVM.HardwareProfile.vmSize
	
	Write-Output "`n----------------------------------------------------------------------"
	Write-Output "`nSize updated to: $updatedVMSize"	
	
    if(-not ([string]::IsNullOrEmpty($requestUrl))) {
        Start-Sleep -s 10
        
        [Net.ServicePointManager]::SecurityProtocol = 
        [Net.SecurityProtocolType]::Tls12 -bor `
        [Net.SecurityProtocolType]::Tls11 -bor `
        [Net.SecurityProtocolType]::Tls
        $response = Invoke-WebRequest -Uri $requestUrl -UseBasicParsing
        Write-Output $response
    }
}
else # Scaling schedule not found for this day
{
    Write-Output "No matching scaling schedule for this day found. Check if current edition/tier matches the default..."
}

Write-Output "Script finished."    
