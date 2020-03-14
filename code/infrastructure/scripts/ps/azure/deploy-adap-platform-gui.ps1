<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    AzureDeployment
.SYNOPSIS
    Deploy Microsoft Cloud Adoption Framework (CAF) to Microsoft Azure.
.DESCRIPTION
    This script is used to prepare a Microsoft Azure subscription for the deployment of data and analytics services in the cloud.
.EXAMPLE
    .\deploy-adap-platform -orgTag "ORG-TAG" -deployAction "audit" -azAll
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$azureDeploy_form                = New-Object system.Windows.Forms.Form
$azureDeploy_form.ClientSize     = '817,490'
$azureDeploy_form.text           = "Azure Deployment"
$azureDeploy_form.TopMost        = $false
$azureDeploy_form.StartPosition  = "CenterScreen"

$deployAction_lbl                = New-Object system.Windows.Forms.Label
$deployAction_lbl.text           = "Deployment Action"
$deployAction_lbl.AutoSize       = $false
$deployAction_lbl.location       = New-Object System.Drawing.Point(15,20)
$deployAction_lbl.Size           = New-Object System.Drawing.Size(140,20) 
$deployAction_lbl.Font           = 'Microsoft Sans Serif,10'
$deployAction_lbl.TextAlign      = "TopRight"
$azureDeploy_form.Controls.Add($deployAction_lbl) 

$orgTag_lbl                      = New-Object system.Windows.Forms.Label
$orgTag_lbl.text                 = "Organization Tag"
$orgTag_lbl.AutoSize             = $false
$orgTag_lbl.location             = New-Object System.Drawing.Point(15,50)
$orgTag_lbl.Size                 = New-Object System.Drawing.Size(140,20) 
$orgTag_lbl.Font                 = 'Microsoft Sans Serif,10'
$orgTag_lbl.TextAlign            = "TopRight"
$azureDeploy_form.Controls.Add($orgTag_lbl) 

$adapCMDBfile_lbl                = New-Object system.Windows.Forms.Label
$adapCMDBfile_lbl.text           = "CMDB File"
$adapCMDBfile_lbl.AutoSize       = $false
$adapCMDBfile_lbl.location       = New-Object System.Drawing.Point(15,80)
$adapCMDBfile_lbl.Size           = New-Object System.Drawing.Size(140,20) 
$adapCMDBfile_lbl.Font           = 'Microsoft Sans Serif,10'
$adapCMDBfile_lbl.TextAlign      = "TopRight"
$azureDeploy_form.Controls.Add($adapCMDBfile_lbl) 

$features_lbl                    = New-Object system.Windows.Forms.Label
$features_lbl.text               = "Select the Azure scaffolding that you want to deploy. The Blueprint has a dependency on Azure Policy and Initiatives."
$features_lbl.AutoSize           = $false
$features_lbl.location           = New-Object System.Drawing.Point(15,110)
$features_lbl.Size               = New-Object System.Drawing.Size(140,200) 
$features_lbl.Font               = 'Microsoft Sans Serif,10'
$features_lbl.TextAlign          = "TopLeft"
$azureDeploy_form.Controls.Add($features_lbl) 

$deployAction_cbx                = New-Object system.Windows.Forms.ComboBox
$deployAction_cbx.text           = ""
@('create','purge','audit') | ForEach-Object {[void] $deployAction_cbx.Items.Add($_)}
$deployAction_cbx.location       = New-Object System.Drawing.Point(160,20)
$deployAction_cbx.Size           = New-Object System.Drawing.Size(200,20) 
$deployAction_cbx.Font           = 'Microsoft Sans Serif,10'
$azureDeploy_form.Controls.Add($deployAction_cbx) 

$orgTag_tb                       = New-Object system.Windows.Forms.TextBox
$orgTag_tb.multiline             = $false
$orgTag_tb.text                  = "ORG-TAG"
$orgTag_tb.location              = New-Object System.Drawing.Point(160,50)
$orgTag_tb.Size                  = New-Object System.Drawing.Size(200,20) 
$orgTag_tb.Font                  = 'Microsoft Sans Serif,10'
$azureDeploy_form.Controls.Add($orgTag_tb) 

$cmdbFile_tb                     = New-Object system.Windows.Forms.TextBox
$cmdbFile_tb.multiline           = $false
$cmdbFile_tb.text                = "adap-cmdb.xlsm"
$cmdbFile_tb.location            = New-Object System.Drawing.Point(160,80)
$cmdbFile_tb.Size                = New-Object System.Drawing.Size(200,20) 
$cmdbFile_tb.Font                = 'Microsoft Sans Serif,10'
$azureDeploy_form.Controls.Add($cmdbFile_tb) 

$azAll_cb                        = New-Object system.Windows.Forms.CheckBox
$azAll_cb.text                   = "Deploy All"
$azAll_cb.AutoSize               = $false
$azAll_cb.location               = New-Object System.Drawing.Point(160,110)
$azAll_cb.Size                   = New-Object System.Drawing.Size(200,20) 
$azAll_cb.Font                   = 'Microsoft Sans Serif,10'
$azureDeploy_form.Controls.Add($azAll_cb) 

$adUsers_cb                      = New-Object system.Windows.Forms.CheckBox
$adUsers_cb.text                 = "AD Users"
$adUsers_cb.AutoSize             = $false
$adUsers_cb.location             = New-Object System.Drawing.Point(160,140)
$adUsers_cb.Size                 = New-Object System.Drawing.Size(200,20) 
$adUsers_cb.Font                 = 'Microsoft Sans Serif,10'
$azureDeploy_form.Controls.Add($adUsers_cb) 

$ADGroups_cb                        = New-Object system.Windows.Forms.CheckBox
$ADGroups_cb.text                   = "AD Groups"
$ADGroups_cb.AutoSize               = $false
$ADGroups_cb.location               = New-Object System.Drawing.Point(160,170)
$ADGroups_cb.Size                 = New-Object System.Drawing.Size(200,20) 
$ADGroups_cb.Font                   = 'Microsoft Sans Serif,10'
$azureDeploy_form.Controls.Add($ADGroups_cb) 

$azPolicies_cb                   = New-Object system.Windows.Forms.CheckBox
$azPolicies_cb.text              = "Policies"
$azPolicies_cb.AutoSize          = $false
$azPolicies_cb.location          = New-Object System.Drawing.Point(160,200)
$azPolicies_cb.Size                 = New-Object System.Drawing.Size(200,20) 
$azPolicies_cb.Font              = 'Microsoft Sans Serif,10'
$azureDeploy_form.Controls.Add($azPolicies_cb) 

$azInitiatives_cb                = New-Object system.Windows.Forms.CheckBox
$azInitiatives_cb.text           = "Policy Inititiatives"
$azInitiatives_cb.AutoSize       = $false
$azInitiatives_cb.location       = New-Object System.Drawing.Point(160,230)
$azInitiatives_cb.Size                 = New-Object System.Drawing.Size(200,20) 
$azInitiatives_cb.Font           = 'Microsoft Sans Serif,10'
$azureDeploy_form.Controls.Add($azInitiatives_cb) 

$azRoles_cb                      = New-Object system.Windows.Forms.CheckBox
$azRoles_cb.text                 = "Roles"
$azRoles_cb.AutoSize             = $false
$azRoles_cb.location             = New-Object System.Drawing.Point(160,260)
$azRoles_cb.Size                 = New-Object System.Drawing.Size(200,20) 
$azRoles_cb.Font                 = 'Microsoft Sans Serif,10'
$azureDeploy_form.Controls.Add($azRoles_cb) 

$azBlueprint_cb                  = New-Object system.Windows.Forms.CheckBox
$azBlueprint_cb.text             = "Blueprints"
$azBlueprint_cb.AutoSize         = $false
$azBlueprint_cb.location         = New-Object System.Drawing.Point(160,290)
$azBlueprint_cb.Size                 = New-Object System.Drawing.Size(200,20) 
$azBlueprint_cb.Font             = 'Microsoft Sans Serif,10'
$azureDeploy_form.Controls.Add($azBlueprint_cb) 

$azRoleAssignments_cb            = New-Object system.Windows.Forms.CheckBox
$azRoleAssignments_cb.text       = "Role Assignments"
$azRoleAssignments_cb.AutoSize   = $false
$azRoleAssignments_cb.location   = New-Object System.Drawing.Point(160,320)
$azRoleAssignments_cb.Size       = New-Object System.Drawing.Size(200,20) 
$azRoleAssignments_cb.Font       = 'Microsoft Sans Serif,10'
$azureDeploy_form.Controls.Add($azRoleAssignments_cb) 

$ToolTip1                        = New-Object system.Windows.Forms.ToolTip

$primaryLocation_cb              = New-Object system.Windows.Forms.ComboBox
$primaryLocation_cb.text         = "comboBox"
@('East US','East US 2','Central US','North Central US','South Central US','West Central US','West US','West US 2') | ForEach-Object {[void] $primaryLocation_cb.Items.Add($_)}
$primaryLocation_cb.location     = New-Object System.Drawing.Point(501,200)
$primaryLocation_cb.Size                 = New-Object System.Drawing.Size(200,20) 
$primaryLocation_cb.Font         = 'Microsoft Sans Serif,10'
$azureDeploy_form.Controls.Add($primaryLocation_cb) 

$ListView1                       = New-Object system.Windows.Forms.ListView
$ListView1.text                  = "listView"
$ListView1.location              = New-Object System.Drawing.Point(473,94)
$ListView1.Size                 = New-Object System.Drawing.Size(200,40) 
$azureDeploy_form.Controls.Add($ListView1) 

$deploy_btn                      = New-Object system.Windows.Forms.Button
$deploy_btn.text                 = "Deploy"
$deploy_btn.location             = New-Object System.Drawing.Point(625,300)
$deploy_btn.Size                 = New-Object System.Drawing.Size(60,30) 
$deploy_btn.Font                 = 'Microsoft Sans Serif,10'
$azureDeploy_form.Controls.Add($deploy_btn) 

$cancel_btn                      = New-Object system.Windows.Forms.Button
$cancel_btn.text                 = "Cancel"
$cancel_btn.location             = New-Object System.Drawing.Point(550,300)
$cancel_btn.Size                 = New-Object System.Drawing.Size(60,30) 
$cancel_btn.Font                 = 'Microsoft Sans Serif,10'
$azureDeploy_form.Controls.Add($cancel_btn) 

$save_btn                        = New-Object system.Windows.Forms.Button
$save_btn.text                   = "Save"
$save_btn.location               = New-Object System.Drawing.Point(470,300)
$save_btn.Size                 = New-Object System.Drawing.Size(60,30) 
$save_btn.Font                   = 'Microsoft Sans Serif,10'
$azureDeploy_form.Controls.Add($save_btn) 

$result = $azureDeploy_form.ShowDialog()
