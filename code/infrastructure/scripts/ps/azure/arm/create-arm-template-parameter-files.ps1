<#
    .SYNOPSIS
      This script opens the CMDB spreadsheet and creates ARM Parameter files for each worksheet that begins with "Az-"

    .PARAM
        $adapCMDB - Excel Spreadsheet CMDB

    .PARAMETER paramDirectory
      Template Parameter file folder location where .json files will be created

    .EXAMPLE
    .\create-arm-template-parameter-files.ps1  -$adapCMDB adap-cmdb.xlsx
#>
param(
    [string]$adapCMDB                     = $adapCMDB,
    [Parameter(Mandatory=$true,HelpMessage='Root Directory where Blueprint files are located')]
    [string] $paramDirectory,
    [string] $env
)

 function ConvertFrom-ExcelToJson {
     <#
      .SYNOPSIS
        Reads data from a sheet, and for each row, calls a custom scriptblock with a list of property names and the row of data.
        This is added to a PSCustomObject

      .EXAMPLE
        $paramFiles = ConvertFrom-ExcelToJson -WorkSheetname $worksheetName -Path $adapCMDB
    #>
    [CmdletBinding()]
    param(
        [Alias("FullName")]
        [Parameter(ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true, Mandatory = $true)]
        [ValidateScript( { Test-Path $_ -PathType Leaf })]
        $Path,
        [Alias("Sheet")]
        $WorkSheetname = 1,
        [Alias('HeaderRow', 'TopRow')]
        [ValidateRange(1, 9999)]
        [Int]$StartRow,
        [string[]]$Header,
        [switch]$NoHeader

    )
    $params = @{} + $PSBoundParameters
    ConvertFrom-ExcelData @params {
        [CmdletBinding()]
        param($propertyNames, $record)

      $ParametersFile = [PSCustomObject]@{
        "`$schema"     = "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#"
        contentVersion = "1.0.0.0"
        parameters     = @{ }
      }
      foreach ($pn in $propertyNames) {
        $ParametersFile.parameters.Add($pn, @{ value = $record.$pn })
      }
      #Return the paramater files for export to json file
      return $ParametersFile
    }
}

$e = Open-ExcelPackage "$adapCMDB"
foreach ($worksheets in $e.workbook.worksheets) {
  $worksheetName = $worksheets.Name
  if ($worksheetName.StartsWith("Az-")) {
    $paramFiles = ConvertFrom-ExcelToJson -WorkSheetname $worksheetName -Path $adapCMDB
    Write-Verbose -Message ("Creating $worksheetName parameter files.")
    $p=0
    $f=0
    foreach($file in $paramFiles){
      $jsonFile = $worksheetName.Remove(0,3)
      $TemplateParametersFilePath = "$paramDirectory\$jsonFile.$env.$f.parameter.json"
      Write-Information "    Creating $jsonFile.$env.$f.parameter.json parameter files."
      Set-Content -Path $TemplateParametersFilePath -Value ([Regex]::Unescape(($file | ConvertTo-Json -Depth 10))) -Force
      $f++
      $p++
    }
    $paramFiles = $null
    $p = $null
    $f = $null
  }
}


  <#
$cmdbExcel = Open-Excel
$wb = Get-Workbook -ObjExcel $cmdbExcel -Path $adapCMDB
$worksheets = Get-WorksheetNames -Workbook $wb
Close-Excel -ObjExcel $cmdbExcel
for ($w=0; $w -lt $worksheets.length; $w++) {
  Write-Verbose -Message ($worksheets.length)
  [string]$worksheetName = $worksheets[$w]
  Write-Verbose -Message ($w)
  Write-Verbose -Message ($worksheetName)
  if ($worksheetName.StartsWith("Az-")) {
    #$e = Open-ExcelPackage $adapCMDB
    $paramFiles = ConvertFrom-ExcelToJson -WorkSheetname $worksheetName -Path $adapCMDB
    Write-Verbose -Message ("Creating $worksheetName parameter files.")
    $p=0
    $f=0
    foreach($file in $paramFiles){
        #if ($p%2 -eq 0) {
          $jsonFile = $worksheetName.Remove(0,3)
          $TemplateParametersFilePath = "$paramDirectory\$jsonFile.$env.$f.parameter.json"
          Write-Information "    Creating $jsonFile.$env.$f.parameter.json parameter files."
          Set-Content -Path $TemplateParametersFilePath -Value ([Regex]::Unescape(($file | ConvertTo-Json -Depth 10))) -Force
          $f++
        #}
          $p++
        }
     $paramFiles = $null
     $p = $null
     $f = $null
  }
}
#>
