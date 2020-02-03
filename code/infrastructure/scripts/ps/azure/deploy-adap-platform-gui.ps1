<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    AzureDeployment
.SYNOPSIS
    Deploy Microsoft Cloud Adoption Framework (CAF) to Microsoft Azure.
.DESCRIPTION
    This script is used to prepare a Microsoft Azure subscription for the deployment of data and analytics services in the cloud.
.EXAMPLE
    .\deploy-adap-platform -orgTag "xazx" -deployAction "audit" -azAll
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$azureDeploy_form                = New-Object system.Windows.Forms.Form
$azureDeploy_form.ClientSize     = '744,413'
$azureDeploy_form.text           = "Azure Deployment"
$azureDeploy_form.TopMost        = $false

$orgTag_tb                       = New-Object system.Windows.Forms.TextBox
$orgTag_tb.multiline             = $false
$orgTag_tb.text                  = "xazx"
$orgTag_tb.width                 = 200
$orgTag_tb.height                = 20
$orgTag_tb.location              = New-Object System.Drawing.Point(147,75)
$orgTag_tb.Font                  = 'Consolas,10'

$orgTag_lbl                      = New-Object system.Windows.Forms.Label
$orgTag_lbl.text                 = "Organization Tag"
$orgTag_lbl.AutoSize             = $true
$orgTag_lbl.width                = 25
$orgTag_lbl.height               = 10
$orgTag_lbl.location             = New-Object System.Drawing.Point(19,77)
$orgTag_lbl.Font                 = 'Consolas,10'

$azAll_cb                        = New-Object system.Windows.Forms.CheckBox
$azAll_cb.text                   = "Deploy All"
$azAll_cb.AutoSize               = $false
$azAll_cb.width                  = 167
$azAll_cb.height                 = 20
$azAll_cb.location               = New-Object System.Drawing.Point(67,142)
$azAll_cb.Font                   = 'Microsoft Sans Serif,10'

$adUsers_cb                      = New-Object system.Windows.Forms.CheckBox
$adUsers_cb.text                 = "AD Users"
$adUsers_cb.AutoSize             = $false
$adUsers_cb.width                = 167
$adUsers_cb.height               = 20
$adUsers_cb.location             = New-Object System.Drawing.Point(67,169)
$adUsers_cb.Font                 = 'Microsoft Sans Serif,10'

$deployAction_cbx                = New-Object system.Windows.Forms.ComboBox
$deployAction_cbx.text           = "Select Action"
$deployAction_cbx.width          = 200
$deployAction_cbx.height         = 20
@('create','purge','audit') | ForEach-Object {[void] $deployAction_cbx.Items.Add($_)}
$deployAction_cbx.location       = New-Object System.Drawing.Point(145,6)
$deployAction_cbx.Font           = 'Microsoft Sans Serif,10'

$cmdbFile_tb                     = New-Object system.Windows.Forms.TextBox
$cmdbFile_tb.multiline           = $false
$cmdbFile_tb.text                = "CMDB File (Excel)"
$cmdbFile_tb.width               = 200
$cmdbFile_tb.height              = 20
$cmdbFile_tb.location            = New-Object System.Drawing.Point(146,108)
$cmdbFile_tb.Font                = 'Microsoft Sans Serif,10'

$ADGroups                        = New-Object system.Windows.Forms.CheckBox
$ADGroups.text                   = "AD Groups"
$ADGroups.AutoSize               = $false
$ADGroups.width                  = 167
$ADGroups.height                 = 20
$ADGroups.location               = New-Object System.Drawing.Point(67,196)
$ADGroups.Font                   = 'Microsoft Sans Serif,10'

$azPolicies_cb                   = New-Object system.Windows.Forms.CheckBox
$azPolicies_cb.text              = "Policies"
$azPolicies_cb.AutoSize          = $false
$azPolicies_cb.width             = 167
$azPolicies_cb.height            = 20
$azPolicies_cb.location          = New-Object System.Drawing.Point(67,221)
$azPolicies_cb.Font              = 'Microsoft Sans Serif,10'

$azInitiatives_cb                = New-Object system.Windows.Forms.CheckBox
$azInitiatives_cb.text           = "Policy Inititiatives"
$azInitiatives_cb.AutoSize       = $false
$azInitiatives_cb.width          = 167
$azInitiatives_cb.height         = 20
$azInitiatives_cb.location       = New-Object System.Drawing.Point(67,246)
$azInitiatives_cb.Font           = 'Microsoft Sans Serif,10'

$azRoles_cb                      = New-Object system.Windows.Forms.CheckBox
$azRoles_cb.text                 = "Roles"
$azRoles_cb.AutoSize             = $false
$azRoles_cb.width                = 167
$azRoles_cb.height               = 20
$azRoles_cb.location             = New-Object System.Drawing.Point(67,272)
$azRoles_cb.Font                 = 'Microsoft Sans Serif,10'

$azBlueprint_cb                  = New-Object system.Windows.Forms.CheckBox
$azBlueprint_cb.text             = "Blueprints"
$azBlueprint_cb.AutoSize         = $false
$azBlueprint_cb.width            = 167
$azBlueprint_cb.height           = 20
$azBlueprint_cb.location         = New-Object System.Drawing.Point(67,298)
$azBlueprint_cb.Font             = 'Microsoft Sans Serif,10'

$azRoleAssignments_cb            = New-Object system.Windows.Forms.CheckBox
$azRoleAssignments_cb.text       = "Role Assignments"
$azRoleAssignments_cb.AutoSize   = $false
$azRoleAssignments_cb.width      = 167
$azRoleAssignments_cb.height     = 20
$azRoleAssignments_cb.location   = New-Object System.Drawing.Point(67,325)
$azRoleAssignments_cb.Font       = 'Microsoft Sans Serif,10'

$deployAction_lbl                = New-Object system.Windows.Forms.Label
$deployAction_lbl.text           = "Deployment Action"
$deployAction_lbl.AutoSize       = $true
$deployAction_lbl.width          = 25
$deployAction_lbl.height         = 10
$deployAction_lbl.location       = New-Object System.Drawing.Point(-433,287)
$deployAction_lbl.Font           = 'Microsoft Sans Serif,10'

$verbosePreferenceVariable_cbx   = New-Object system.Windows.Forms.ComboBox
$verbosePreferenceVariable_cbx.text  = "Verbose Preference"
$verbosePreferenceVariable_cbx.width  = 207
$verbosePreferenceVariable_cbx.height  = 20
@('Stop','Inquire','Continue','Suspend') | ForEach-Object {[void] $verbosePreferenceVariable_cbx.Items.Add($_)}
$verbosePreferenceVariable_cbx.location  = New-Object System.Drawing.Point(498,28)
$verbosePreferenceVariable_cbx.Font  = 'Microsoft Sans Serif,10'

$errorActionPreferenceVariable_cbx   = New-Object system.Windows.Forms.ComboBox
$errorActionPreferenceVariable_cbx.text  = "Error Preference"
$errorActionPreferenceVariable_cbx.width  = 207
$errorActionPreferenceVariable_cbx.height  = 20
@('Stop','Inquire','Continue','Suspend') | ForEach-Object {[void] $errorActionPreferenceVariable_cbx.Items.Add($_)}
$errorActionPreferenceVariable_cbx.location  = New-Object System.Drawing.Point(498,96)
$errorActionPreferenceVariable_cbx.Font  = 'Microsoft Sans Serif,10'

$informationPreferenceVariable_cbx   = New-Object system.Windows.Forms.ComboBox
$informationPreferenceVariable_cbx.text  = "Information Preference"
$informationPreferenceVariable_cbx.width  = 207
$informationPreferenceVariable_cbx.height  = 20
@('Stop','Inquire','Ignore','Continue','Suspend') | ForEach-Object {[void] $informationPreferenceVariable_cbx.Items.Add($_)}
$informationPreferenceVariable_cbx.location  = New-Object System.Drawing.Point(498,129)
$informationPreferenceVariable_cbx.Font  = 'Microsoft Sans Serif,10'

$confirmPreferenceVariable_cbx   = New-Object system.Windows.Forms.ComboBox
$confirmPreferenceVariable_cbx.text  = "None"
$confirmPreferenceVariable_cbx.width  = 207
$confirmPreferenceVariable_cbx.height  = 20
@('None','Low','Medium') | ForEach-Object {[void] $confirmPreferenceVariable_cbx.Items.Add($_)}
$confirmPreferenceVariable_cbx.location  = New-Object System.Drawing.Point(498,160)
$confirmPreferenceVariable_cbx.Font  = 'Microsoft Sans Serif,10'

$debugPreferenceVariable_cbx     = New-Object system.Windows.Forms.ComboBox
$debugPreferenceVariable_cbx.text  = "Debug Preference"
$debugPreferenceVariable_cbx.width  = 207
$debugPreferenceVariable_cbx.height  = 20
@('Stop','Inquire','Continue','Suspend') | ForEach-Object {[void] $debugPreferenceVariable_cbx.Items.Add($_)}
$debugPreferenceVariable_cbx.location  = New-Object System.Drawing.Point(498,62)
$debugPreferenceVariable_cbx.Font  = 'Microsoft Sans Serif,10'

$removeRG_cb                     = New-Object system.Windows.Forms.CheckBox
$removeRG_cb.text                = "Remove Resource Groups"
$removeRG_cb.AutoSize            = $false
$removeRG_cb.width               = 174
$removeRG_cb.height              = 20
$removeRG_cb.location            = New-Object System.Drawing.Point(151,38)
$removeRG_cb.Font                = 'Microsoft Sans Serif,10'

$adapCMDBfile_lbl                = New-Object system.Windows.Forms.Label
$adapCMDBfile_lbl.text           = "CMDB File"
$adapCMDBfile_lbl.AutoSize       = $true
$adapCMDBfile_lbl.width          = 25
$adapCMDBfile_lbl.height         = 10
$adapCMDBfile_lbl.location       = New-Object System.Drawing.Point(70,111)
$adapCMDBfile_lbl.Font           = 'Consolas,10'

$ProgressBar1                    = New-Object system.Windows.Forms.ProgressBar
$ProgressBar1.width              = 720
$ProgressBar1.height             = 29
$ProgressBar1.location           = New-Object System.Drawing.Point(9,368)

$verbose_lbl                     = New-Object system.Windows.Forms.Label
$verbose_lbl.text                = "Verbose"
$verbose_lbl.AutoSize            = $false
$verbose_lbl.width               = 75
$verbose_lbl.height              = 10
$verbose_lbl.location            = New-Object System.Drawing.Point(415,28)
$verbose_lbl.Font                = 'Microsoft Sans Serif,10'

$debug_lbl                       = New-Object system.Windows.Forms.Label
$debug_lbl.text                  = "Debug"
$debug_lbl.AutoSize              = $false
$debug_lbl.width                 = 75
$debug_lbl.height                = 10
$debug_lbl.location              = New-Object System.Drawing.Point(415,62)
$debug_lbl.Font                  = 'Microsoft Sans Serif,10'

$error_lbl                       = New-Object system.Windows.Forms.Label
$error_lbl.text                  = "Error"
$error_lbl.AutoSize              = $false
$error_lbl.width                 = 75
$error_lbl.height                = 10
$error_lbl.location              = New-Object System.Drawing.Point(415,96)
$error_lbl.Font                  = 'Microsoft Sans Serif,10'

$information_lbl                 = New-Object system.Windows.Forms.Label
$information_lbl.text            = "Information"
$information_lbl.AutoSize        = $false
$information_lbl.width           = 75
$information_lbl.height          = 10
$information_lbl.location        = New-Object System.Drawing.Point(415,129)
$information_lbl.Font            = 'Microsoft Sans Serif,10'

$confirm_lbl                     = New-Object system.Windows.Forms.Label
$confirm_lbl.text                = "Confirm"
$confirm_lbl.AutoSize            = $false
$confirm_lbl.width               = 75
$confirm_lbl.height              = 10
$confirm_lbl.location            = New-Object System.Drawing.Point(415,160)
$confirm_lbl.Font                = 'Microsoft Sans Serif,10'

$deploy_lbl                      = New-Object system.Windows.Forms.Label
$deploy_lbl.text                 = "Deploy Action"
$deploy_lbl.AutoSize             = $true
$deploy_lbl.width                = 25
$deploy_lbl.height               = 10
$deploy_lbl.location             = New-Object System.Drawing.Point(30,13)
$deploy_lbl.Font                 = 'Microsoft Sans Serif,10'

$deploy_btn                      = New-Object system.Windows.Forms.Button
$deploy_btn.text                 = "Deploy"
$deploy_btn.width                = 60
$deploy_btn.height               = 30
$deploy_btn.location             = New-Object System.Drawing.Point(625,300)
$deploy_btn.Font                 = 'Microsoft Sans Serif,10'

$cancel_btn                      = New-Object system.Windows.Forms.Button
$cancel_btn.text                 = "Cancel"
$cancel_btn.width                = 60
$cancel_btn.height               = 30
$cancel_btn.location             = New-Object System.Drawing.Point(550,300)
$cancel_btn.Font                 = 'Microsoft Sans Serif,10'

$save_btn                        = New-Object system.Windows.Forms.Button
$save_btn.text                   = "Save"
$save_btn.width                  = 60
$save_btn.height                 = 30
$save_btn.location               = New-Object System.Drawing.Point(470,300)
$save_btn.Font                   = 'Microsoft Sans Serif,10'

$ToolTip1                        = New-Object system.Windows.Forms.ToolTip

$azureDeploy_form.controls.AddRange(@($orgTag_tb,$orgTag_lbl,$azAll_cb,$adUsers_cb,$deployAction_cbx,$cmdbFile_tb,$ADGroups,$azPolicies_cb,$azInitiatives_cb,$azRoles_cb,$azBlueprint_cb,$azRoleAssignments_cb,$deployAction_lbl,$verbosePreferenceVariable_cbx,$errorActionPreferenceVariable_cbx,$informationPreferenceVariable_cbx,$confirmPreferenceVariable_cbx,$debugPreferenceVariable_cbx,$removeRG_cb,$adapCMDBfile_lbl,$ProgressBar1,$verbose_lbl,$debug_lbl,$error_lbl,$information_lbl,$confirm_lbl,$deploy_lbl,$deploy_btn,$cancel_btn,$save_btn))




$azureDeploy_form.Add_Shown({$azureDeploy_form.Activate()})
[void] $azureDeploy_form.ShowDialog()