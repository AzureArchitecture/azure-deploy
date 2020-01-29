<#
    .SYNOPSIS
    Returns default configuration values that will be used by the Reference Architecture Data Platform
#>
function Get-Configuration
{
  $configuration = @{`
    azureEnvironment = "AzureCloud"
    primaryLocation = "eastus"
    primaryLocationName = "East US"
    primaryLocationTag = "eus"
    secondaryLocation = "eastus2"
    secondaryLocationName = "East US 2"
    secondaryLocationTag = "eus2"

    testResourceGroupName = "rg-test"
    smokeResourceGroup = "rg-smoke"
    mgmtResourceGroup = "rg-xazx-mgmtp-dev-eus"
    vnetResourceGroup = "rg-xazx-network-dev-eus"
    sharedResourceGroup = "rg-xazx-shared-dev-eus"
    adapResourceGroup = "rg-xazx-adap-dev-eus"

    subscriptionname = 'AzureArch'
    subscriptionId = "323241e8-df5e-434e-b1d4-a45c3576bf80"
    azureAdmin = "mtad@azuresecurity.net"
    azureAdminPwd = 'Z3#xcvbnmnbvcxz'# (Get-AzKeyVaultSecret -VaultName 'adap-deploy-rg-kv' -Name 'azureAdminPwd' -).SecretValueText

    securityEmails = "p@gallucci.us"
    securityPhoneNo = "88886753909"

    adOUPath = 'OU=Azure,'
    aadDirectoryName = "azurearchitecture"
    tenentId = "3ae449e7-25e5-4e5d-b705-7a39e1ad16f0"

    laAutomationAccount = "auto-xazx-shared-dev-eus"
    laWorkspaceName = "la-xazx-dev-eus"
    laResourceGroup = "rg-xazx-shared-dev-eus"
    alertResourceGroup = "rg-xazx-shared-dev-eus"
    suffix = "-eus"
    orgTag = "azs"
    evTag="dev"

    azdoTAP = "mvvttbrowgdpxms2depmui5lfmksyqx4kx2fjg5es4p42qzyboza"
    azdoOrgName = "QDnA"
  }
  return $configuration
}