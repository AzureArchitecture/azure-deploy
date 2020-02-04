  Clear-Host

  #Folder Locations
  $psCommonDirectory = "$PSScriptRoot\..\common"
  Set-Location -Path $PSScriptRoot  

  if ( -not (Test-path ('{0}\azure-common.psm1' -f $psCommonDirectory)))
  {
    Write-Information 'Shared PS modules can not be found, Check path {0}\azure-common.psm1.' -f $psCommonDirectory -InformationAction "Continue"
    Exit
  }
  else
  {
    $azureCommon = ('{0}\{1}' -f  $psCommonDirectory, 'azure-common')
    Import-Module -Name $azureCommon -Force
  }

    $subscriptionId = Get-SubscriptionId
    $exportPath = "C:\temp\blue1\"
    Write-Information "Exporting Blueprints from $subscriptionId" -InformationAction "Continue"
      $VerbosePreference = "Continue"
    $DebugPreference = "Continue"
    $ErrorActionPreference = "Continue"
     Export-SubscriptionBlueprints -subscriptionId $subscriptionId -exportPath $exportPath
