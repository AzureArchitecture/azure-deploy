function Export-cAZPolicyDefinitions {
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
    
  $VerbosePreference = "Continue"
  $DebugPreference = "Continue"
  $ErrorActionPreference = "Stop"

    #Get Policy Definitions
    $definitions = Get-AzPolicyDefinition 

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
        $fileName = $def.Properties.displayName.Replace('[', '').Replace(']', '').Replace(':',' ').Replace(' ', '.').Replace('\', '-').Replace('/', '-').Replace('|', '-')
        $fileName = $fileName.Replace('..', '.').Replace('.-.', '.')
        write-host $fileName -InformationAction Continue
        $inventoryData += $iObj

        if($def.Properties.metadata.category -eq "afc")
        {
          #Create output json
          Write-Host $fileName -InformationAction Continue
          $jsonshort | out-file -FilePath "$outputFolder\policy-$($fileName).json" -Force
        }
        Write-Host $fileName -InformationAction Continue
        $jsonshort | out-file -FilePath "$outputFolder\policy-$($fileName).json" -Force
    }

    #Export Inventory
    $inventoryData | Export-Csv -Path "$outputFolder\_policyinventory.csv" -NoClobber -Delimiter ',' -Encoding UTF8 -Force -NoTypeInformation
}
Clear-Host
Export-cAZPolicyDefinitions -outputFolder "C:\000\policy"
