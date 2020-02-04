<#
    NAME 
        AzureSubscriptionRBACAudit.ps1    

    SYNOPSIS
        Gathers Azure Role Based Access Control Data for Audit Purposes.

    DESCRIPTION
        Gathers Azure Role Based Access Control Data for Audit Purposes. The script will prompt the user to 
        select a subscription to run the audit against. The user is only presented the scriptions currently 
        available to the users credentials.

    OUTPUTS
        Outputs a CSV file in the same directory that the script is located in. The CSV file will have the 
        name of the subscription in its title followed by "Azure RBAC Audit.csv"

#>

#Requires –Modules AzureRM
#Requires –Modules ReportHTML
#Requires -Modules ReportHTMLHelpers

[CmdletBinding(DefaultParameterSetName='ReportParameters')]
param 
(
    
    [Parameter (Mandatory=$true)]
    [STRING] $StorageAccountName,
    [Parameter (Mandatory=$true)]
    [STRING] $StorageAccountResourceGroup,
    [Parameter (Mandatory=$true)]
    [STRING] $StorageContainerName
)

function Set-AzureLogin{
    
    $connectionName = "AzureRunAsConnection"
    try
    {
        # Get the connection "AzureRunAsConnection "
        $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         
        Write-Output $servicePrincipalConnection

        "Logging in to Azure..."
        Add-AzureRmAccount `
            -ServicePrincipal `
            -TenantId $servicePrincipalConnection.TenantId `
            -ApplicationId $servicePrincipalConnection.ApplicationId `
            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint | Out-Null 
            #-EnvironmentName AzureUSGovernment | Out-Null 
        Write-Output "Logged in."
    }
    catch {
        if (!$servicePrincipalConnection)
        {
            $ErrorMessage = "Connection $connectionName not found."
            throw $ErrorMessage
        } else{
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }

    
}

function Get-FileName ([String]$Report_Name){    
    
    $date=Get-Date -UFormat "%Y%m%d"

    $file_name = $Report_Name + "-" + $date + ".csv"
    
    return $file_name
}


function Invoke-AzureSubscriptionLoop{
    
    Set-AzureLogin

    # Fetching subscription list
    $subscription_list = Get-AzureRmSubscription 
    
    # Fetching the IaaS inventory list for each subscription
    foreach($subscription_list_iterator in $subscription_list){

        Run-AzureRBACReport -subscription_ID $subscription_list_iterator.id -subscription_name $subscription_list_iterator.Name
       
    }

    # Connect to Storage Account
    Set-AzureRmCurrentestorageAccount `
    -StorageAccountName $StorageAccountName `
    -ResourceGroupName $StorageAccountResourceGroup

    # Transfer output file to Blob storage
    Set-AzureStorageBlobContent `
    -Container $StorageContainerName `
    -File $Report_Name `
    -Blob $Report_Name `
    -Force
}

function Run-AzureRBACReport([String]$subscription_ID,[String]$subscription_name) {

    $TitleText = 'VA Azure RBAC Report'
    $RightLogo ='https://azurefieldnotesblog.blob.core.windows.net/wp-content/2017/02/ReportHTML.png'
    $LeftLogo ='https://www.oit.va.gov/design-guide/_media/img/logos/OIT_logo.png'

    $subscription_ID=$subscription_ID.Trim()
    $subscription_name=$subscription_name.Trim()
    $Name = "AzureAccessReport-" + $subscription_name

    $ReportPath = Get-FileName -Type "Path"
    $ReportName = Get-FileName -Report_Name $Name -Type "File"

    Select-AzureRmSubscription -SubscriptionName $subscription_list_iterator.Name
  
    $RoleDefinitions = Get-AzureRmRoleDefinition 
    $AssignedRoles = Get-AzureRmRoleAssignment 
    $AzureUsers = $AssignedRoles | select SignInName -Unique
    $GroupAssignedRoles = $AssignedRoles  | group DisplayName 

    $ResourceGroups = Get-AzureRmResourceGroup 
    $i=0;$Records = $ResourceGroups.Count
    $RGRoleAssignments = @()
    $Activity = $subscription_name + ": Getting role assignments from Resource Groups"
    foreach ($RG in $ResourceGroups ) {
        Write-Progress -PercentComplete ($i/$Records *100) -Activity $Activity 
        $RoleData = Get-AzureRmRoleAssignment -ResourceGroupName $RG.ResourceGroupName | select DisplayName, SignInName, RoleDefinitionName, Scope
        foreach($User in $RoleData) {
                
            $RGRoleAssignment = '' | select Role, RoleData
            $NewUser = '' | Select DisplayName, SignInName, RoleDefinitionName, Scope, ResourceGroup
            $NewUser.ResourceGroup = $RG.ResourceGroupName
            $NewUser.DisplayName = $User.DisplayName
            $NewUser.SignInName = $User.SignInName
            $NewUser.RoleDefinitionName = $User.RoleDefinitionName
            $NewUser.Scope = $User.Scope
                
            $found = $FALSE
            $index = 0
            foreach($Role in $RGRoleAssignments) {
                if($Role.Role -eq $User.RoleDefinitionName) {
                    $found = $TRUE
                } else {
                    $index++
                }
            }

            if($found) {

                $RGRoleAssignments[$index].RoleData += $NewUser

            } else {

                #$RGRoleAssignment = '' | select Role, RoleData
                $RGRoleAssignment.Role = $User.RoleDefinitionName
                $RGRoleAssignment.RoleData = @($NewUser)
                $RGRoleAssignments += $RGRoleAssignment

            }

        }
        $I++
    }

    $UserAssignedRBAC = @()
    foreach ($AzureUser in ($AzureUsers | ? {$_.SignInName -ne $null}) ) {
        $UserAssignedRBAC  += Get-AzureRmRoleAssignment -SignInName $AzureUser.SignInName | Select DisplayName, RoleDefinitionName, Scope
        #GROUP... $UserAssignedRBAC += Get-AzureRmRoleAssignment -SignInName $AzureUser.SignInName -ExpandPrincipalGroups | FL DisplayName, RoleDefinitionName, Scope
    }
    $GroupedUserAssignedRBAC = $UserAssignedRBAC | group DisplayName
    

    $ReportTitle = $TitleText + " - " + $subscription_name 
    $rpt = @()
    $rpt += Get-HTMLOpenPage -LeftLogoString $LeftLogo -TitleText $ReportTitle  -RightLogoString $RightLogo
        $rpt += Get-HTMLContentOpen -HeaderText RoleDefinitions -IsHidden    
            #$Roles = Get-HTMLAnchorLink -AnchorName $_.name.replace(' ','') -AnchorText $_.name
            $rpt += Get-HTMLContentTable ($RoleDefinitions | select Name, Description, IsCustom)
        $rpt += Get-HTMLContentClose
        $rpt += Get-HTMLContentOpen -HeaderText ("RBAC Role Definitions") -BackgroundShade 2 -IsHidden
     
            foreach ($RoleDefinition in $RoleDefinitions ) {
            
                $rpt +=  Get-HTMLContentOpen -HeaderText $RoleDefinition.Name  -BackgroundShade 1 -Anchor ($RoleDefinition.Name.Replace(' ','')) -IsHidden
                    $rpt +=  Get-HTMLContenttext -Heading "Description" -Detail $RoleDefinition.Description 
                    $rpt +=  Get-HTMLContentOpen -HeaderText "actions" 
                       $ofs = "<BR>" 
                       $actions = ([string]$RoleDefinition.Actions)
                       $Nonactions = ([string]$RoleDefinition.NotActions)
                        $ofs = "" 
                        $rpt +=  Get-HTMLContenttext -Heading "Actions" -Detail $Actions
                        $rpt +=  Get-HTMLContenttext -Heading "Not Actions" -Detail $Nonactions
                    $rpt +=  get-htmlcontentclose
                $rpt +=  get-htmlcontentclose
            }
        $rpt += Get-HTMLContentClose
    
        # This one --------------------==/
        $rpt +=  Get-HTMLContentOpen -HeaderText "Resource Groups & Roles" -BackgroundShade 2 -IsHidden
        foreach ($RGRole in $RGRoleAssignments) {
            $rpt +=  Get-HTMLContentOpen -HeaderText $RGRole.Role -BackgroundShade 1 -IsHidden
                $rpt += Get-HTMLContentTable ( $RGRole.RoleData  | select ResourceGroup, DisplayName, Scope)
            $rpt += get-htmlcontentclose
        }
        $rpt += get-htmlcontentclose

        # This one --------------------==/
        $rpt +=  Get-HTMLContentOpen -HeaderText "User Assigned Roles" -BackgroundShade 1 -IsHidden
            $rpt += get-htmlcontenttable ($UserAssignedRBAC) -GroupBy    displayname
        $rpt += get-htmlcontentclose
    $rpt += get-htmlclosepage


    Save-HTMLReport -ReportContent $rpt -ReportPath $ReportPath -ReportName $ReportName 

}

Invoke-AzureSubscriptionLoop
