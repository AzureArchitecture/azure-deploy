<#   
.SYNOPSIS   
    Vertically scale an Azure Service plan up or down according to a 
    schedule using Azure Automation.    

.DESCRIPTION   
    This Azure Automation runbook enables vertically scaling of 
    an Azure Service plan according to a schedule. Autoscaling based 
    on a schedule allows you to scale your solution according to 
    predictable resource demand. 

.PARAMETER resourceGroupName
    Name of the resource group to which the service plan is 
    assigned.

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

.EXAMPLE
        -resourceGroupName myResourceGroup
        -appServicePlan myServicePlan
        -azureRunAsConnectionName AzureRunAsConnection       
        -scalingSchedule [{WeekDays:[1, 2, 3, 4, 5]]
        -scalingScheduleTimeZone Central Europe Standard Time
        -requestUrl https://google.com
        -defaultTier Basic
        -defaultWorkerSize Small
   
.NOTES   
    Last Update: Aug 2018   
#>

param(
[parameter(Mandatory=$true)]
[string] $resourceGroupName,

[parameter(Mandatory=$true)]
[string] $appServicePlan,

[parameter(Mandatory=$false)]
[string] $scalingSchedule = "[{WeekDays:[1, 2, 3, 4, 5]}]",

[parameter(Mandatory=$false)]
[string] $azureRunAsConnectionName = "AzureRunAsConnection",

[parameter(Mandatory=$false)]
[string] $scalingScheduleTimeZone = "Central Europe Standard Time",

[parameter(Mandatory=$false)]
[string] $requestUrl,

[parameter(Mandatory=$false)]
[string] $defaultTier = "Basic",

[parameter(Mandatory=$false)]
[string] $defaultWorkerSize = "Small"
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
    $plan = Get-AzureRmAppServicePlan -Name $appServicePlan -ResourceGroupName $resourceGroupName
    Write-Output $plan.Sku
    Set-AzureRmAppServicePlan -Name $appServicePlan -ResourceGroupName $resourceGroupName -Tier $defaultTier -WorkerSize $defaultWorkerSize
    
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
