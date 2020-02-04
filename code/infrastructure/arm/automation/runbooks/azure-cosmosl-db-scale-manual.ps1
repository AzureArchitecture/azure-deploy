<#   
.SYNOPSIS   
    The script provides the ability to scale an Azure CosmosDb database.   

.DESCRIPTION   
    This Azure Automation runbook enables scaling of an Azure CosmosDB.


.PARAMETER resourceGroupName
    Name of the resource group to which the service plan is 
    assigned.

.PARAMETER accountName
    Azure Automation Run As account name. Needs to be able to access
    the $serverName.
       
.PARAMETER databaseName   
    Azure Cosmos Database

.PARAMETER containerName


.PARAMETER throughput


.EXAMPLE
        
   
.NOTES   
    Last Update: January 17, 2020
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
param(
   
    [Parameter(Mandatory = $true)]
    [string] $resourceGroupName,
    
    [Parameter(Mandatory = $true)]
    [string] $accountName,

    [Parameter(Mandatory = $true)]
    [string] $databaseName,

    [Parameter(Mandatory = $true)]
    [string] $containerName,

    [Parameter(Mandatory = $true, HelpMessage="Values between 400 and 1000000 inclusive in increments of 100")]
    [int] $throughput
)

$connectionName = "AzureRunAsConnection"
try {
    $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName

    Connect-AzAccount `
    -ServicePrincipal `
    -TenantId $servicePrincipalConnection.TenantId `
    -ApplicationId $servicePrincipalConnection.ApplicationId `
    -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint
}
catch {
    if (!$servicePrincipalConnection) {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    }
    else {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

if ( $Throughput -lt 400 -or $Throughput -gt 1000000 -or ($Throughput % 100) -ne 0 ){
    $message = "Invalid Throughput $Throughput. Values between 400 and 1000000 inclusive in increments of 100"
    Write-Error -Message $message
    return
}

$ErrorActionPreference = "Continue"

$p = Get-AzResource `
    -ResourceType "Microsoft.DocumentDb/databaseAccounts" -ApiVersion "2016-03-31" `
    -ResourceGroupName $ResourceGroupName -Name $accountName `
    | Select-Object -expand Properties

$accountType = $p.EnabledApiTypes

$resourceType = ''
$resourceName = ''

if ($accountType -match 'Table'){
    $resourceType = 'Microsoft.DocumentDb/databaseAccounts/apis/tables/settings'
    $resourceName = $accountName + "/table/" + $ContainerName + "/throughput"
}
elseif ($accountType -match 'MongoDB'){
    $resourceType = 'Microsoft.DocumentDb/databaseAccounts/apis/databases/collections/settings';
    $resourceName = $accountName + "/mongodb/" + $DatabaseName + "/" + $ContainerName + "/throughput"
}
elseif ($accountType -match 'Gremlin'){
    $resourceType = 'Microsoft.DocumentDb/databaseAccounts/apis/databases/graphs/settings';
    $resourceName = $accountName + "/gremlin/" + $DatabaseName + "/" + $ContainerName + "/throughput"
}
elseif ($accountType -match 'Cassandra'){
    $resourceType = 'Microsoft.DocumentDB/databaseAccounts/apis/keyspaces/tables/settings';
    $resourceName =  $accountName + "/cassandra/" + $DatabaseName + "/" + $ContainerName + "/throughput"
}
elseif ($accountType -match 'Sql'){
    $resourceType = 'Microsoft.DocumentDb/databaseAccounts/apis/databases/containers/settings';
    $resourceName =  $accountName + "/sql/" + $DatabaseName + "/" + $ContainerName + "/throughput"
}
else{
    $message = "Unsupported CosmosDB account type '$accountType'. Supported APIs are: SQL, Gremlin, MongoDB, Table and Cassandra."
    Write-Error -Message $message
    return
}


$properties = @{
    "resource"=@{"throughput"=$throughput}
}

try {
Set-AzResource `
    -ResourceType $resourceType -ApiVersion "2016-03-31" `
    -ResourceGroupName $ResourceGroupName -Name $resourceName `
    -PropertyObject $properties `
    -Force 
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}
