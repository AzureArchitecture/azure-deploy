<#
    .SYNOPSIS
        Scale-HDInsightClusterNodes is a simple PowerShell workflow runbook that will help you automate the process of scaling in or out your HDInsight clusters depending on your needs.
    
    .DESCRIPTION
        Scale-HDInsightClusterNodes is a simple PowerShell workflow runbook that will help you automate the process of scaling in or out your HDInsight clusters depending on your needs.

    .PARAMETER ResourceGroupName
        The name of the resource group where the cluster resides
    
    .PARAMETER ClusterName
        The name of your HDInsight cluster
    
    .PARAMETER Nodes
        The number of nodes you want for the cluster

    .PARAMETER ConnectionName
        The name of your automation connection account
   
    .NOTES 
        AUTHOR: Carlos Mendible 
        LASTEDIT: June 13, 2017 
#>
Workflow azure-hdinsight-scale-manual {
    Param
    (   
        [Parameter(Mandatory = $true)]
        [String]$ResourceGroupName,

        [Parameter(Mandatory = $true)]
        [String]$ClusterName,

        [Parameter(Mandatory = $true)]
        [Int]$Nodes,

        [Parameter(Mandatory = $false)]
        [String]$ConnectionName
    )

    # This Workflow requieres the following powershell modules: AzureRM.Profile, AzureRM.HDInsight

    $automationConnectionName = $ConnectionName
    if (!$ConnectionName) {
        $automationConnectionName = "AzureRunAsConnection"
    }
	
    # Get the connection by name (i.e. AzureRunAsConnection)
    $servicePrincipalConnection = Get-AutomationConnection -Name $automationConnectionName         

    Write-Output "Logging in to Azure..."
    
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint
 
    Write-Output "Scaling cluster $ClusterName to $Nodes nodes..."
    Set-AzureRmHDInsightClusterSize `
        -ResourceGroupName $ResourceGroupName `
        -ClusterName $ClusterName `
        -TargetInstanceCount $Nodes
}
