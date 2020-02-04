function Export-cAZPolicyInitiativesDefinitions {
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

    #Get Policy Definitions
    $definitions = Get-AzPolicySetDefinition

    #Instantiate Inventory
    $inventoryData = @()
    Foreach ($def in $definitions)
    {
        $json = $def | ConvertTo-Json -Depth 50 | Foreach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }
        $jsonshort = trim-jsontabs -inputData $json -depth 3
        #Add to Inventory
        $iObj = [pscustomobject][ordered]@{
            Name = $def.Name
            DisplayName = $def.Properties.displayName
            PolicyType = $def.Properties.policyType
            Category = $def.Properties.metadata.category
            Description = $def.Properties.description
        }
        $fileName = $def.Properties.displayName.Replace('[', '').Replace(']', '').Replace(':','.').Replace(' ', '.').Replace('\', '-')
        $fileName = $fileName.Replace('..', '.')
        write-host $fileName
        $inventoryData += $iObj

        if($def.Properties.metadata.category -eq "afc")
        {
          #Create output json
          $jsonshort | out-file -FilePath "$outputFolder\policyset-$($fileName).json" -Force
        }
        $jsonshort | out-file -FilePath "$outputFolder\policyset-$($fileName).json" -Force
    }

    #Export Inventory
    $inventoryData | Export-Csv -Path "$outputFolder\_policysetinventory.csv" -NoClobber -Delimiter ',' -Encoding UTF8 -Force -NoTypeInformation
}
Clear-Host
Export-cAZPolicyinitiativesDefinitions -outputFolder "C:\000\policy"
