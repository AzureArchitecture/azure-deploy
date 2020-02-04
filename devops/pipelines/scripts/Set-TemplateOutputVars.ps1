<#
    .SYNOPSIS
    Takes ARM template output(s) and converts into Azure DevOps variables.

    .DESCRIPTION
    Takes ARM template output(s), usually from the Azure resource group deployment task in Azure DevOps.
    Creates Azure DevOps variables of the same output name so that the values can be used in subsequent pipeline tasks.

    .PARAMETER ArmOutput
    The JSON output from the ARM template to convert into variables.
    If using the  Azure resource group deployment task in an Azure Pipeline, you can set the output to a variable by specifying `Outputs > Deployment outputs`.

    .EXAMPLE
    Set-ArmTemplateOutputVariables.ps1 -ArmOutput '$(ArmOutputs)'
    where ArmOutputs is the name from Outputs > Deployment outputs from the  Azure resource group deployment task
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$ArmOutput
)

try {
  $json = $Output | convertfrom-json
  foreach ($member in $json.psobject.properties.name) {
      $value = $json.$member.value
      Write-verbose "$member : $value"
      $variableName = $member
      Write-Host "##vso[task.setvariable variable=$variableName;]$value"
  }

    return "Outputs set as pipeline variables successfully."
}

catch {
    throw "$_"
}
