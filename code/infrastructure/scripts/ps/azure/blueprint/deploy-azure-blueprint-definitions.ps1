<#
    .SYNOPSIS
    Deploys all the blueprints in the root folder and child folders.

    .PARAMETER removeRG (default $false)
    Switch to remove resource groups during blueprint purge

    .PARAMETER
    $adapCMDB - Excel Spreadsheet CMDB

    .PARAMETER rootDirectory
    The location of the folder that is the root where the script will start from

    .PARAMETER action (default create)
    Create Azure Assets or Purge Azure Assets

    .PARAMETER subscriptionId
    The subscriptionid where the blueprints will be applied

    .PARAMETER env
    token for deployment (smoke, dev, prod, uat, sandbox)

    .PARAMETER location
    location for Azure Blueprint deployment

    .EXAMPLE
    .\deploy-azure-blueprint-definitions.ps1 -rootDirectory '.\blueprint\' -subscriptionId 323241e8-df5e-434e-b1d4-a45c3576bf80
    .\deploy-azure-blueprint-definitions.ps1 -adapCMDB $adapCMDB -rootDirectory "$armBluePrintDirectory\" -action $deployAction -subscriptionId $subscriptionId -location $location -env $env -removeRG $removeRG
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true,HelpMessage='Excel Spreadsheet with Configuration Information.')]
    [string] $adapCMDB,

    [Parameter(Mandatory=$true,HelpMessage='Root Directory where Blueprint files are located.')]
    [string] $rootDirectory,

    [Parameter(Mandatory=$true,HelpMessage='Action to take.')]
    [ValidateSet("create","purge")]
    [string] $action,

    [Parameter(Mandatory = $true)]
    [string] $subscriptionId,

    [Parameter(Mandatory = $true)]
    [string] $location,

    [Parameter(Mandatory = $true)]
    [string] $env,

    [Parameter(Mandatory = $true)]
    [string] $orgTag,

    [Parameter(Mandatory = $true)]
    [string] $suffix,

    [Parameter(Mandatory = $true)]
    [string] $testRG,

    [Parameter(Mandatory = $true)]
    [string] $smokeRG,

    [Parameter(Mandatory = $true)]
    [string] $adapRG,

    [Parameter(Mandatory = $true)]
    [string] $mgmtRG,

    [Parameter(Mandatory = $true)]
    [string] $networkRG,

    [Parameter(Mandatory = $true)]
    [string] $onpremRG,

    [Parameter(Mandatory = $true)]
    [string] $sharedRG,

    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [switch] $removeRG,

    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string] $logAnalytics

)

# Set working directory to path specified by rootDirectory var
Set-Location -Path  "$rootDirectory" -PassThru 

if ($action -eq 'purge')
      {
    $bpas = Get-AzBlueprintAssignment  
    foreach ($bpa in $bpas) {
      $temp = "    Removing Azure BlueprintAssignment: {0}" -f $bpa.Name
      Write-Information $temp  
      Remove-AzBlueprintAssignment -Name $bpa.Name -Subscription $subscriptionId -ErrorAction Continue  
    }
    $bps = Get-AzBlueprint
    foreach ($bp in $bps) {
      $temp = "    Removing Azure Blueprint: {0}" -f $bp.Name
      Write-Information $temp  
    }
      if($removeRG)
      {
        # loop through each rg in a sub
      $rgs = Get-AzResourceGroup | Where ResourceGroupName -like *$orgTag* 
      Get-AzResourceLock | Where Name -NE 'dnd' | Remove-AzResourceLock -Force -ErrorAction Continue
        foreach ($rg in $rgs) {
          if($rg.ResourceGroupName.StartsWith("rg-"))
            {
              $temp = "    Deleting {0}..." -f $rg.ResourceGroupName
              Write-Information $temp  
              Remove-AzResourceGroup -Name $rg.ResourceGroupName -Force   -ErrorAction Continue
              }
          <#
              $bps = Get-AzBlueprint
              foreach ($bp in $bps) {
              $temp = "    Removing Azure Blueprint: {0}" -f $bp.Name
              Write-Information $temp  

            #>
          }
        }
      Exit
  }

# parameters are listed in a single hashtable, with a key/value pair for each parameter
$parameters = @{ Env=$env; orgTag=$orgTag; logAnalytics=$logAnalytics; suffix=$suffix; testRG=$testRG; smokeRG=$smokeRG; mgmtRG=$mgmtRG; networkRG=$networkRG; sharedRG=$sharedRG; adapRG=$adapRG ;onpremRG=$onpremRG; location=$location; AzureRegion=$location}

$BPFolders = Get-ChildItem $rootDirectory  
foreach($BPFolder in $BPFolders) {
  $BPName = $BPFolder.Name
  $temp = "    Deploying Azure Blueprint: {0}" -f $BPName
  Write-Information $temp  
  #write-host Import-AzBlueprintWithArtifact -Name "$BPName" -InputPath $BPFolder.FullName -SubscriptionId "$subscriptionId"
  Import-AzBlueprintWithArtifact -Name $BPName -InputPath $BPFolder.FullName -SubscriptionId "$subscriptionId" -Force 
  # success
  if ($?) {
    $temp = "    Azure Blueprint imported successfully: {0}" -f $BPName
    Write-Information $temp  

    $date = Get-Date -UFormat %Y%m%d%H%M%S
    $genVersion = "$date" # todo - use the version from DevOps

    $importedBp = Get-AzBlueprint -Name $BPName -SubscriptionId $subscriptionId 
    Publish-AzBlueprint -Blueprint $importedBp -Version $genVersion 

    $temp = "    Azure Blueprint published successfully: {0}" -f $BPName
    Write-Information $temp  

    $publishedBp = Get-AzBlueprint -SubscriptionId $subscriptionId -Name $BPName -LatestPublished 

    $bpNameVersion = New-BlueprintName -blueprintName $BPName -blueprintVersion $genVersion
    New-AzBlueprintAssignment -Name "$bpNameVersion" -Blueprint $publishedBp -SubscriptionId $subscriptionId -Location $location -Parameter $parameters 

    $temp = "    Azure Blueprint assigned successfully: {0}" -f $BPName
    Write-Information $temp  

    # TODO - Clean up old test version(s)
  } else {
    $temp = "    Error Azure Blueprint: {0}" -f $BPName
    Write-Host -foreground RED $temp  
    exit 1
  }
}
<#
  $importedBp = Get-AzBlueprint -Name $BPName -LatestPublished
  # Urgent TODO - this should be idemopotent...
  # todo - should auto-insert blueprintId into parameters file
  $bpfile = ('{0}\{1}' -f  $BPFolder.FullName, "Blueprint.json")
  $bpfile
  New-AzBlueprintAssignment -Name "$BPName" -Blueprint $importedBp -AssignmentFile $bpfile -SubscriptionId $subscriptionId

  # Wait for assignment to complete
  $timeout = new-timespan -Seconds 500
  $sw = [diagnostics.stopwatch]::StartNew()

  while (($sw.elapsed -lt $timeout) -and ($Assignemntestatus.ProvisioningState -ne "Succeeded") -and ($Assignemntestatus.ProvisioningState -ne "Failed")) {
    $Assignemntestatus = Get-AzBlueprintAssignment -Name "$BPName" -SubscriptionId $subscriptionId
    if ($Assignemntestatus.ProvisioningState -eq "failed") {
      Throw "Assignment Failed. See Azure Portal for details."
      break
    }
  }

  if ($Assignemntestatus.ProvisioningState -ne "Succeeded") {
    Write-Warning "Assignment has timed out, activity is exiting."
  }

  # publish 'stable' version
  $date = Get-Date -UFormat %Y%m%d.%H%M%S
  $genVersion = "$date.STABLE" # todo - use the version from DevOps
  #Publish-AzBlueprint -Blueprint $importedBp -Version $genVersion

  #>
