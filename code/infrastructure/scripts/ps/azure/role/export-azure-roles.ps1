function Export-cAZRoleDefinitions {
    [cmdletBinding()]
    param(
        [parameter(mandatory)]
        [string]$outputFolder
    )

    function trim-jsontabs {
        param(
        [parameter(mandatory)]
        [string]$inputData,

        [parameter(mandatory=$false)]
        [int]$depth=3
        )

        $outputData = (($inputData -split '\r\n' | Foreach-Object {
          $line = $_
          if ($_ -match '^ +') {
            $len  = $Matches[0].Length / $depth
            $line = ' ' * $len + $line.TrimStart()
          }
          $line
        }) -join "`r`n")

        return $outputData
    }

    #Get role Definitions
    $definitions = Get-AzRoleDefinition

    #Instantiate Inventory
    $inventoryData = @()
    Foreach ($def in $definitions)
    {
        $json = $def | ConvertTo-Json -Depth 50 | Foreach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }
        $jsonshort = trim-jsontabs -inputData $json -depth 3
        #Add to Inventory
        $iObj = [pscustomobject][ordered]@{
            Name = $def.Name
            Description = $def.Properties.Description
        }
        $fileName = $def.Properties.Name.Replace('[', '').Replace(']', '').Replace(':','.').Replace(' ', '.').Replace('\', '-')
        $fileName = $fileName.Replace('..', '.')
        write-host $fileName
        $inventoryData += $iObj

        $jsonshort | out-file -FilePath "$outputFolder\role-$($fileName).json" -Force
    }

    #Export Inventory
    $inventoryData | Export-Csv -Path "$outputFolder\_roleinventory.csv" -NoClobber -Delimiter ',' -Encoding UTF8 -Force -NoTypeInformation
}
Clear-Host
Export-cAZroleDefinitions -outputFolder "C:\000\role"

##############################################################################
# Main Program
##############################################################################
