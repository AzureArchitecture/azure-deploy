#Folder Locations
Set-Location -Path $PSScriptRoot  
$psCommonDirectory = "$PSScriptRoot\..\common"
$psConfigDirectory = "$PSScriptRoot\..\config"
$psRunbooks = "$PSScriptRoot\runbooks"

  $adapCMDBfile = 'adap-cmdb.xlsm'
  $adapCMDB = "$psConfigDirectory\$adapCMDBfile"

  if ( -not (Test-path ('{0}\azure-common.psm1' -f "$psCommonDirectory")))
  {
    Write-Information 'Shared PS modules can not be found, Check path {0}\azure-common.psm1.' -f $psCommonDirectory
    Exit
  }
  ## Check path to CMDB
  if ( -not (Test-path -Path $adapCMDB))
  {
    Write-Information  'No file specified or file {0}\{1} does not exist.' -f $psConfigDirectory, $adapCMDBfile
    Exit
  }
  

  try{
    $azureCommon = ('{0}\{1}' -f  $psCommonDirectory, 'azure-common')
    Import-Module -Name $azureCommon -Force

    #Set Config Values
    $configurationFile = ('{0}\{1}' -f  $psConfigDirectory, 'adap-configuration')
    Import-Module -Name $configurationFile -Force
    $config = Get-Configuration
  }
  catch {
    Write-Host -ForegroundColor RED    "Error importing reguired PS modules: $azureCommon, $configurationFile"
    $PSCmdlet.ThrowTerminatingError($_)
    Exit
  }
  
# Logon to Azure
Write-Information 'Logon to Azure...'
Initialize-Subscription
$subscriptionId = $config.subscriptionId
Set-AzContext -SubscriptionId $subscriptionId
$SubscriptionName = $config.subscriptionname
$AutomationAccountName = $config.laAutomationAccount
$ResourceGroupName = $config.sharedResourceGroup
$OutputFolder = $psRunbooks 

select-AzSubscription -SubscriptionName $SubscriptionName

#endregion

#region 1. Exporting Runbooks

$AllRunbooks = Get-AzAutomationRunbook -AutomationAccountName $AutomationAccountName -ResourceGroupName $ResourceGroupName
$AllRunbooks | Export-AzAutomationRunbook -OutputFolder $OutputFolder

#endregion


#region 2. Exporting Variables

$variables = Get-AzAutomationVariable -AutomationAccountName $AutomationAccountName -ResourceGroupName $ResourceGroupName

$variablesFilePath = $OutputFolder + "\variables.csv"

$variables | Export-Csv -Path $variablesFilePath -NoTypeInformation

#endregion
