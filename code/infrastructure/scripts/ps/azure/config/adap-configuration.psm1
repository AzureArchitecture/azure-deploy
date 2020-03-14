function Get-Configuration
{
  <#
      .SYNOPSIS
      This file stores the orgTag that must be replaced during the deployment.
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
      # Do Not change Below
      # ########################################################
      orgTag = "ORG-TAG"
    }
  return $configuration
}
