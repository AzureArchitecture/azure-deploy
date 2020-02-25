function Get-Configuration
{
  <#
      .SYNOPSIS
      Describe purpose of "Get-Configuration" in 1-2 sentences.

      .DESCRIPTION
      Add a more complete description of what the function does.

      .EXAMPLE
      Get-Configuration
      Describe what this call does

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online Get-Configuration

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>
    $configuration = @{`
      # Update these values
      securityEmails = "user@domain.com"
      securityPhoneNo = "88886753909"

      adOUPath = "OU=Azure,"
      aadDirectoryName = "azurearchitecture"
      tenentId = "3ae449e7-25e5-4e5d-b705-7a39e1ad16f0"
 
      # Do Not change Below
      # ########################################################
      azureEnvironment = "AzureUSGovernment" # AzureUSGovernment, AzureCloud
      primaryLocation = "eastus"
      primaryLocationName = "East US"
      primaryLocationTag = "eus"
      secondaryLocation = "eastus2"
      secondaryLocationName = "East US 2"
      secondaryLocationTag = "eus2"

      orgTag = "yazy"
      tenentDomain = "company.org"
      
    }
  return $configuration
}
