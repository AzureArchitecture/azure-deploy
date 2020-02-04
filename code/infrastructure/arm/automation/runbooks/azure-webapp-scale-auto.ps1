function Set-WebAppServicePlan
{

    <#
    .SYNOPSIS
    Function scale a website in Azure

    .DESCRIPTION
    This function can change a website in Azure. It can change the
    app service plan and turn autoscale on.

    It is meant as sample code for doing something similiar, and
    not really for production use without some added error handling
    and extra checking.

    It can also be argued that it should be split into two
    different functions, one for changing the app service plan
    and one for doing the autoscale settings.

    .EXAMPLE
    Set-WebAppServicePlan -WebAppResourceId $MyResourceId -Sku Free

    Will set the website to the "free" tier.

    .EXAMPLE
    Set-WebAppServicePlan -WebAppResourceId $MyResourceId -Sku Standard -AutoScale

    Will change the website to be using the "Standard" tier with AutoScale turned
    on.

    .PARAMETER WebAppResourceId
    The ResourceId of the web app.

    .PARAMETER Sku
    The tier to use, can be 'Free', 'Shared', 'Basic' or 'Standard'.

    .PARAMETER ApiVersion
    Which version of the Azure API to use.

    .PARAMETER AutoScale
    If this switch is specified, the function will attempt to
    configure Autoscale as well. This is only available on the
    free tier.

    #>

    [cmdletbinding()]
    Param([Parameter(Mandatory=$true)]
          [string] $WebAppResourceId,
          [Parameter(Mandatory=$true)]
          [ValidateSet('Free','Shared','Basic', 'Standard')]
          [string] $Sku,
          [string] $ApiVersion = '2014-04-01-preview',
          [switch] $AutoScale)


    $WebsiteResourceObj = Get-AzureRmResource -ResourceId $WebAppResourceId

    $AppServicePlanName = $WebsiteResourceObj.Name + '-AppServicePlan'

    $PropertyHash = @{
                       'Name'= $AppServicePlanName
                       'Sku' = $Sku
                       'WorkerSize' = '0'
                       'NumberOfWorkers' = 1
                     }

    $AppServicePlan = New-AzureRmResource -ApiVersion $APIVersion -Name $AppServicePlanName -ResourceGroupName $WebsiteResourceObj.ResourceGroupName -ResourceType 'Microsoft.Web/serverFarms' -Location $WebsiteResourceObj.Location -PropertyObject $PropertyHash -Force

    $PropertyHash = @{
                        'Sku' = $Sku
                        'serverFarm' = $AppServicePlanName
                     }

    $null = Set-AzureRmResource -ResourceId $WebAppResourceId -ApiVersion $APIVersion -Properties $PropertyHash -Force

    if ($AutoScale) {
        $AutoScaleUpHash = @{
                                'MetricName' = 'CpuPercentage'
                                'MetricResourceId' = $AppServicePlan.ResourceId
                                'Operator' = 'GreaterThanOrEqual'
                                'MetricStatistic' = 'Average'
                                'Threshold' = 80
                                'TimeGrain' = '00:01:00'
                                'TimeWindow' = '00:45:00'
                                'ScaleActionCooldown' = '00:05:00'
                                'ScaleActionDirection' = 'Increase'
                                'ScaleActionScaleType' = 'ChangeCount'
                                'ScaleActionValue' = 1
                            }

        $AutoScaleDownHash = @{
                                'MetricName' = 'CpuPercentage'
                                'MetricResourceId' = $AppServicePlan.ResourceId
                                'Operator' = 'LessThanOrEqual'
                                'MetricStatistic' = 'Average'
                                'Threshold' = 60
                                'TimeGrain' = '00:01:00'
                                'TimeWindow' = '00:45:00'
                                'ScaleActionCooldown' = '02:00:00'
                                'ScaleActionDirection' = 'Decrease'
                                'ScaleActionScaleType' = 'ChangeCount'
                                'ScaleActionValue' = 1
                            }

        $AutoScaleUpRule = New-AutoscaleRule @AutoScaleUpHash
        $AutoScaleDownRule = New-AutoscaleRule @AutoScaleDownHash

        $AutoScaleProfile = New-AutoscaleProfile -DefaultCapacity '0' -MaximumCapacity '10' -MinimumCapacity '0' -Rules $AutoScaleUpRule, $AutoScaleDownRule -Name 'DefaultAutoScaleProfile'
        $AutoScaleProfile.FixedDate = $null
        
        $null = Add-AutoscaleSetting -Location $WebsiteResourceObj.Location -Name DefaultAutoScaleSetting -ResourceGroup $WebsiteResourceObj.ResourceGroupName -TargetResourceId $AppServicePlan.ResourceId -AutoscaleProfiles $AutoScaleProfile -ErrorAction Stop
    }
}
