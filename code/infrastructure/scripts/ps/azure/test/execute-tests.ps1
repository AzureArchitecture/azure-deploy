<#
.SYNOPSIS
Test Runner 

.DESCRIPTION
Run quality, unit and acceptance tests

.EXAMPLE
execute-tests.ps1
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $false)]
    [String] $CodeCoveragePath
)

$TestParameters = @{
    OutputFormat = 'NUnitXml'
    OutputFile   = "$PSScriptRoot\arm-test.xml"
    Script       = "$PSScriptRoot"
    PassThru     = $True
}
$TestParameters['Tag'] = "functional"

# Remove previous runs
Remove-Item "$PSScriptRoot\arm-test.xml"

# Invoke tests
$Result = Invoke-Pester @TestParameters

# report failures
if ($Result.FailedCount -ne 0) {
    Write-Error "Pester returned $($result.FailedCount) errors"
}
