Function Start-Countdown 
{   <#
    .SYNOPSIS
        Provide a graphical countdown if you need to pause a script for a period of time
        Test
    #>
    Param(
        [Int32]$Seconds = 300,
        [string]$Message = "Pausing for 10 seconds..."
    )
    ForEach ($Count in (1..$Seconds))
    {   Write-Progress -Id 1 -Activity $Message -Status "Waiting for $Seconds seconds, $($Seconds - $Count) left" -PercentComplete (($Count / $Seconds) * 100)
        Start-Sleep -Seconds 1
    }
    Write-Progress -Id 1 -Activity $Message -Status "Completed" -PercentComplete 100 -Completed
}

function Update-StringInFile
{
  <#
      .SYNOPSIS
      Updates one string for another in a file
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$true, Position=0)]
    [System.String]
    $searchStr,
 
    [Parameter(Mandatory=$true, Position=1)]
    [System.String]
    $replaceStr,
    
    [Parameter(Mandatory=$true, Position=2)]
    [System.String]
    $rootDirectory,

    [Parameter(Mandatory=$true, Position=3)]
    [validateset('json','ps1','psm1','md', 'yml','xml','*')]
    [System.String]$fileExtension
  )
  
  # Set working directory to path specified by rootDirectory var
  Set-Location -Path  $rootDirectory -PassThru
  
  $searchFiles = Get-ChildItem . *.$fileExtension -rec
  foreach ($file in $searchFiles)
  {
    (Get-Content $file.PSPath -Force -ErrorAction SilentlyContinue) |
    Foreach-Object { $_ -replace $searchStr, $replaceStr } |
    Set-Content $file.PSPath
  }
}
<#
    .SYNOPSIS
    Checks if a module is loaded and does just that...
#>
function Load-Module ($m) {
    # If module is imported say that and do nothing
    if (Get-Module | Where-Object {$_.Name -eq $m}) {
        write-host "Module $m is already imported."
    }
    else {
        # If module is not imported, but available on disk then import
        if (Get-Module -ListAvailable | Where-Object {$_.Name -eq $m}) {
            Import-Module $m -Force
        }
        else {
            # If module is not imported, not available on disk, but is in on-line gallery then install and import
            if (Find-Module -Name $m | Where-Object {$_.Name -eq $m}) {
                Install-Module -Name $m -Force -Verbose -Scope CurrentUser -InformationVariable Ignore -AllowClobber -Confirm:0
                Import-Module $m -Force
            }
            else {
                # If module is not imported, not available and not in online gallery then abort
                write-host "Module $m not imported, not available and not in online gallery, exiting."
                EXIT 1
            }
        }
    }
}

<#
    .SYNOPSIS
    If not currently logged in to Azure, prompts for login and selection of subscription to use.
#>
function Initialize-Subscription
{
  param(
    # Force reyazyres the user selects a subscription explicitly
    [parameter(Mandatory=$false)]
    [switch] $Force=$false,

    # NoEcho stops the output of the signed in user to prevent double echo
    [parameter(Mandatory=$false)]
    [switch] $NoEcho
  )

  If(!$Force)
  {
    try
    {
      # Use previous login credentials if already logged in
      $AzureContext = Get-AzContext

      if (!$AzureContext.Account)
      {
        # Fall through and reyazyre login
      }
      else
      {
        # Don't display subscription details if already logged in
        if (!$NoEcho)
        {
          $subscriptionId = Get-SubscriptionId
          $subscriptionName = Get-SubscriptionName
          $tenantId = Get-TenantId
          Write-Output "Signed-in as $($AzureContext.Account), Subscription '$($subscriptionId)' '$($subscriptionName)', Tenant Id '$($tenantId)'"
        }
        return
      }
    }
    catch
    {
      # Fall through and reyazyre login - (Get-AzContext fails with Az. modules < 4.0 if there is no logged in acount)
    }
  }
  else
  {
    Clear-AzContext -Scope CurrentUser -Force
  }
  try
  {
    #Login to Azure
    Connect-AzAccount
    $Azurecontext = Get-AzContext
    Write-Host "You are signed-in as: $($Azurecontext.Account)"
    }
    catch
    {
      $temp = "    Error Connect-AzAccount"
      Write-Host -foreground RED $temp
      exit 1
    }

  # Get subscription list
  # $subscriptionList = Get-SubscriptionList
  $subscriptionList = get-AzSubscription
  if($subscriptionList.Length -lt 1)
  {
    Write-Host -foreground RED "    Your Azure account does not have any active subscriptions. Exiting..."
    exit
  }
  elseif($subscriptionList.Length -eq 1)
  {
    Set-AzContext -SubscriptionId $subscriptionList[0].Id > $null
  }
  elseif($subscriptionList.Length -gt 1)
  {
    # Display available subscriptions
    $index = 1
    foreach($subscription in $subscriptionList)
    {
      $subscription | Add-Member -type NoteProperty -name "Row" -value $index
      $index++
    }

    # Prompt for selection
    Write-Output "Your Azure subscriptions: "
    $subscriptionList | Format-Table Row, Id, Name -AutoSize

    # Select single Azure subscription for session
    try
    {
      [int]$selectedRow = Read-Host "Enter the row number to select the subscription to use" -ErrorAction Stop

      Set-AzContext -SubscriptionId $subscriptionList[($selectedRow - 1)] -ErrorAction Stop > $null

      Write-Output "Subscription Id '$($subscriptionList[($selectedRow - 1)].Id)' selected."
    }
    catch
    {
      Write-Host -ForegroundColor RED   'Invalid selection. Exiting...'
      exit
    }
  }
}

function Get-SubscriptionId
{
  $Azurecontext = Get-AzContext
  if ($Azurecontext) {
    return (Get-AzContext).Subscription.Id
  }
  else {
    Write-Host "No current Azure Context"
  }
}

function Get-SubscriptionName
{
  $Azurecontext = Get-AzContext
  if ($Azurecontext) {
      return (Get-AzContext).Subscription.Name
  }
  else {
    Write-Host "No current Azure Context"
  }
}

function Get-AccountId
{
  $Azurecontext = Get-AzContext
  if ($Azurecontext) {
      return (Get-AzContext).Account.Id
  }
  else {
    Write-Host "No current Azure Context"
  }
}

function Get-TenantId
{
  $Azurecontext = Get-AzContext
  if ($Azurecontext) {
      return (Get-AzContext).Tenant.Id
  }
  else {
    Write-Host "No current Azure Context"
  }
}

function Get-SubscriptionList
{
  # Add 'id' and 'name' properties to subscription object returned for Az. modules less than 4.0
  $subscriptionObject = get-AzSubscription

  foreach ($subscription in $subscriptionObject)
  {
    $subscription | Add-Member -type NoteProperty -name "Id" -Value $($subscription.SubscriptionId) -Force
    $subscription | Add-Member -type NoteProperty -Name "Name" -Value $($subscription.SubscriptionName) -Force
  }

  return $subscriptionObject
}

function Get-DbId
{
  $Azurecontext = Get-AzContext
  $AzureModuleVersion = Get-Module Az.Resources -list

  # Check PowerShell version to accommodate breaking change in Az. modules greater than 4.0
  if ($AzureModuleVersion.Version.Major -ge 4)
  {
    return $Azurecontext.Db.Id
  }
  else
  {
    return $Azurecontext.Db.DbId
  }
}

<#
    .SYNOPSIS
    Tests if a db key is registered. Returns true if the key exists in the catalog (whether on-line or off-line) or false if it does not.
#>
function Test-ResourceGroupExists
{
  param(
    [parameter(Mandatory=$true)]
    [string] $ResourceGroupName
  )

  try
  {
    Get-AzResourceGroup -Name $ResourceGroupName
    return $true
  }
  catch
  {
    return $false
  }
}

<#
    .SYNOPSIS
    Gets the region from the Resource Group.
#>
function Get-ResourceGroupLocation
{
  param(
    [parameter(Mandatory=$true)]
    [string] $ResourceGroupName
  )

  try
  {
    $rg = Get-AzResourceGroup -Name $ResourceGroupName
    Write-Host $rg.Location

    $AzureLocation = Get-Azlocation | Where-Object {$_.location -eq $rg.Location}
    return $rg.Location
  }
  catch
  {
    return $null
  }
}
function Remove-ResourceGroup
{
  param(
    [parameter(Mandatory=$true)]
    [string] $Name
  )

  try
  {
    $rgexists = Get-AzResourceGroup $Name
    if ($rgexists) {
      Remove-AzResourceGroup -Name $Name -Force -Verbose
      $rgexists=$false
    }
  }
  catch
  {
    Write-Host -ForegroundColor RED   "An error occurred during RG removal."
    throw
  }
}

function Get-PSModules
{     <#
      .SYNOPSIS
        Checks for reyazyred PS Modules

      .EXAMPLE

    #>
  ## Install ImportExcel module
  if ( -not (get-module -listavailable | Where-Object name -match 'ImportExcel'))
  {
    Install-Module -Name ImportExcel -force -AllowClobber -confirm:$false
  }
  else
  {
    Import-Module ImportExcel -verbose:0 -ErrorAction SilentlyContinue
  }

  ## Install Azure AD
  if ( -not (get-module -listavailable | Where-Object name -match 'AzureAD'))
  {
    install-Module AzureAD -force -AllowClobber -confirm:$false
  }
    else
  {
    Import-Module AzureAD -verbose:0 -ErrorAction SilentlyContinue
  }

  ## Install Az module
  if ( -not (get-module -listavailable | Where-Object name -match 'Az'))
  {
    Install-Module -Name Az -force -AllowClobber -confirm:$false
  }
      else
  {
    Import-Module Az -verbose:0 -ErrorAction SilentlyContinue
  }
}

function Open-Excel {
  <#
      .SYNOPSIS
      This advanced function opens an instance of the Microsoft Excel application.

      .DESCRIPTION
      The function opens an instance of Microsoft Excel but keeps it hidden unless the Visible parameter is used.

      .PARAMETER Visible
      The parameter switch Visible when specified will make Excel visible on the desktop.

      .EXAMPLE
      The example below returns the Excel COM object when used.

      Open-Excel [-Visible] [-DisplayAlerts] [-AskToUpdateLinks]

      PS C:\> $myObjExcel = Open-Excel

      or

      PS C:\> $myObjExcel = Open-Excel -Visible

      .NOTES

  #>
  [cmdletbinding()]
    Param (
            [Parameter(Mandatory = $false,
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true)]
                [Switch]$Visible = $false,
            [Parameter(Mandatory = $false,
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true)]
                [Switch]$DisplayAlerts = $false,
            [Parameter(Mandatory = $false,
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true)]
                [Switch]$AskToUpdateLinks = $false
        )
    Begin {
            # Create an Object Excel.Application using Com interface
            $objExcel = New-Object -ComObject Excel.Application
        }
    Process {
            # Disable the 'visible' property if not specified.
            $objExcel.Visible = $Visible
            # Disable the 'DisplayAlerts' property if not specified.
            $objExcel.DisplayAlerts = $DisplayAlerts
            # Disable the 'AskToUpdateLinks' property if not specified.
            $objExcel.AskToUpdateLinks = $AskToUpdateLinks
    }
    End {
            # Return the Excel COM object.
      Return $objExcel
    }
}

function ConvertTo-Hashtable {
    <#
      .SYNOPSIS
        This advanced function returns a hashtable converted from a PSObject.

      .DESCRIPTION
        This advanced function returns a hashtable converted from a PSObject and will return work with nested PSObjects.

      .PARAMETER InputObject
        The mandatory parameter InputObject is a PSObject.

      .EXAMPLE
        The example below returns a hashtable created from the myPSObject PSObject.

        ConvertTo-Hashtable -InputObject <PSObject>

        PS C:\> $myNewHash = ConvertTo-Hashtable -InputObject $myPSObject

      .NOTES

    #>

    param (
        [Parameter(ValueFromPipeline)]
        $InputObject)

    process
    {
        # If the inputObject is empty, return $null.
        if ($null -eq $InputObject) { return $null }

        # IF the InputObject can be iterated through and is not a string.
        if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string])
        {
            # Call this function recursively for each object in InputObjects.
            $collection = @(
                foreach ($object in $InputObject) { ConvertTo-Hashtable $object }
            )

            Write-Output -NoEnumerate $collection
        }
        # If the InputObject is already an Object.
        elseif ($InputObject -is [psobject])
        {
            # Define an hashtable called hash.
            $hash = @{}

            # Iterate through all the properties in the PSObject.
            foreach ($property in $InputObject.PSObject.Properties)
            {
                # Add a key value pair to the hashtable and call the ConvertTo-Hashtable function on the property value.
                $hash[$property.Name] = ConvertTo-Hashtable $property.Value
            }

            # Return the hashtable.
            $hash
        }
        else
        {
            # Return the InputObject.
            $InputObject
        }
    }
}

function Export-Yaml {
    <#
      .SYNOPSIS
        This advanced function exports a Hashtable or PSObject to a Yaml file.

      .DESCRIPTION
        This advanced function exports a hashtable or PSObject to a Yaml file

      .PARAMETER InputObject
        The mandatory parameter InputObject is a hashtable or PSObject.

      .PARAMETER Path
        The mandatory parameter Path is the location string of the Yaml file.

      .EXAMPLE
        The example below returns a hashtable created from the myPSObject PSObject.

        Export-Yaml -InputObject <PSObject> -Path <String>

        PS C:\> Export-Yaml -InputObject $myHastable -FilePath "C:\myYamlFile.yml"

        or

        PS C:\> Export-Yaml -InputObject $myPSObject -FilePath "C:\myYamlFile.yml"

      .NOTES

    #>
    param (
    [Parameter(Mandatory=$true, Position=0)]
        $InputObject,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [String]$Path)
    begin {
        # Check to see if the path is relative or absolute. A rooted path is absolute.
        if (-not [System.IO.Path]::IsPathRooted($Path)) {
            # Resolve absolute path from relative path.
            $Path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
            $Workbook.Activate()
        }
        # Install powershell-yaml if not already installed.
        if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Confirm:$false -Force
            Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
            Install-Module -Name powershell-yaml -AllowClobber -Confirm:$false
        }
        # Import the powershell-yaml module.
        Import-Module powershell-yaml
    }
    process {
        # Convert the InputObject to Yaml and save it to the Path location with overwrite.
        $InputObject | ConvertTo-Yaml | Set-Content -Path $Path -Force
    }
    end {}
}

function Export-Json {
    <#
      .SYNOPSIS
        This advanced function exports a hashtable or PSObject to a Json file.

      .DESCRIPTION
        This advanced function exports a hashtable or PSObject to a Json file

      .PARAMETER InputObject
        The mandatory parameter InputObject is a hashtable or PSObject.

      .PARAMETER Path
        The mandatory parameter Path is the location string of the Json file.

      .EXAMPLE
        The example below returns a hashtable created from the myPSObject PSObject.

        Export-Json -InputObject <PSObject> -Path <String>

        PS C:\> Export-Json -InputObject $myHastable -FilePath "C:\myJsonFile.json"

        or

        PS C:\> Export-Json -InputObject $myPSObject -FilePath "C:\myJsonFile.json"

      .NOTES

    #>
    param (
    [Parameter(Mandatory=$true, Position=0)]
        $InputObject,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [String]$Path)
    begin {
        # Check to see if the path is relative or absolute. A rooted path is absolute.
        if (-not [System.IO.Path]::IsPathRooted($Path)) {
            # Resolve absolute path from relative path.
            $Path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
        }
    }
    process {
        # Convert the InputObject to Json and save it to the Path location with overwrite.
        $InputObject | ConvertTo-Json | Set-Content -Path $Path -Force
    }
    end {}
}

function Import-Json {
    <#
      .SYNOPSIS
        This advanced function imports a Json file and returns a PSCustomObject.

      .DESCRIPTION
        This advanced function imports a Json file and returns a PSCustomObject.

      .PARAMETER Path
        The mandatory parameter Path is the location string of the Json file.

      .EXAMPLE
        The example below returns a pscustomobject created from the contents of C:\myJasonFile.json.

        Import-Json -Path <String>

        PS C:\> Import-Json -Path "C:\myJsonFile.json"

      .NOTES

    #>
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [String]$Path)
    begin {
        if (-not [System.IO.Path]::IsPathRooted($Path)) {
            # Resolve absolute path from relative path.
            $Path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
        }
    }
    process {
        # Load the raw content from the Path provided file and convert it from Json.
        $InputObject = Get-Content -Raw -Path $Path | ConvertFrom-Json
    }
    end {
        # Return the result set as an array of PSCustom Objects.
        Return $InputObject
    }
}

function Import-Yaml {
    <#
      .SYNOPSIS
        This advanced function imports a Yaml file and returns a PSCustomObject.

      .DESCRIPTION
        This advanced function imports a Yaml file and returns a PSCustomObject.

      .PARAMETER Path
        The mandatory parameter Path is the location string of the Yaml file.

      .EXAMPLE
        The example below returns a pscustomobject created from the contents of C:\myYamlFile.yml.

        Import-Yaml -Path <String>

        PS C:\> Import-Yaml -Path "C:\myYamlFile.yml"

      .NOTES

    #>
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [String]$Path)
    begin {
        if (-not [System.IO.Path]::IsPathRooted($Path)) {
            # Resolve absolute path from relative path.
            $Path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
        }
        # Install powershell-yaml if not already installed.
        if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Confirm:$false -Force
            Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
            Install-Module -Name powershell-yaml -AllowClobber -Confirm:$false
        }
        # Import the powershell-yaml module.
        Import-Module powershell-yaml
    }
    process {
        # Load the raw content from the provided path and convert it from Yaml to Json and then from Json to an Array of Custom Objects.
        $InputObject = [pscustomobject](Get-Content -Raw -Path $Path | ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json)
    }
    end {
        # Return the result array of custom objects.
        Return $InputObject
    }
}

function Read-FilePath {
    <#
      .SYNOPSIS
      This function opens a gui window dialog to navigate to an excel file.

      .DESCRIPTION
      This function opens a gui window dialog to navigate to an excel file and returns the path.

      .PARAMETER Title
        The mandatory parameter Title, is a string that appears on the navigation window.

      .PARAMETER Extension
        The optional parameter Extension, is a string array that filters the file extensions to allow selection of.

      .EXAMPLE
        The example below shows the command line use with Parameters.

        Read-FilePath -Title <String> -Extension <String[]>

        PS C:\> Read-FilePath -Title "Select a file to upload" -Extension exe,msi,intunewin

      .NOTES

    #>

    [cmdletbinding()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [String]$Title,
        [Parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [String[]]$Extension
    )
    # https://docs.microsoft.com/en-us/previous-versions/windows/silverlight/dotnet-windows-silverlight/cc189944(v%3dvs.95)

    Add-Type -AssemblyName System.Windows.Forms
    $topform = New-Object System.Windows.Forms.Form
  $topform.Topmost = $true
    $topform.MinimizeBox = $true

    $openFileDialog = New-Object windows.forms.openfiledialog
    $openFileDialog.title = $Title
    $openFileDialog.InitialDirectory = $pwd.path
    if ($Extension) {
        $openFileDialog.filter = "File types ($(($Extension -join "; *.").Insert(0,"*.")))|$(($Extension -join ";*.").Insert(0,"*."))"
    }
    $openFileDialog.ShowHelp = $false
    $openFileDialog.ShowDialog($topform) | Out-Null

    if ($openFileDialog.FileName -eq "") {
        Return $null
    }
    else {
        Return $openFileDialog.FileName
    }
}

########################################################################################################################
function Get-UserVariables() {
    Compare-Object (Get-Variable) $AutomaticVariables -Property Name -PassThru | Where-Object -Property Name -ne "AutomaticVariables"
}
########################################################################################################################
function Test-KeyVaultName {
    Param(
    [Parameter(Mandatory=$true)]
    [string]$keyVaultName
  )
    $firstchar = $keyVaultName[0]
    if ($firstchar -match '^[0-9]+$') {
        $keyVaultNew = Read-Host "Key Vault name can't start with numeric value. Please enter a new Key Vault Name."
        checkKeyVaultName -keyVaultName $keyVaultNew
        return;
    }
    return $keyVaultName;
}

########################################################################################################################
function Test-AdminUserName {
    $username = Read-Host "Enter an Admin Username"
    if ($username.ToLower() -eq "admin") {
        Write-Verbose -Message "Not a valid Admin username, please select another."
        checkAdminUserName
        return
    }
    return $username
}

########################################################################################################################
function Test-DomainName {
    $domain = Read-Host "Domain Name"
    if ($domain.length -gt "15") {
        Write-Verbose -Message "Domain Name is too long. Must be less than 15 characters."
        CheckDomainName
        return
    }
    if ($domain -notmatch "^[a-zA-Z0-9.-]*$") {
        Write-Verbose -Message "Invalid character set utilized. Please verify domain name contains only alphanumeric, hyphens, and at least one period."
        CheckDomainName
        return
    }
    if ($domain -notmatch "[.]") {
        Write-Verbose -Message "Invalid Domain Name specified. Please verify domain name contains only alphanumeric, hyphens, and at least one period."
        CheckDomainName
        return
    }
    Return $domain
}

########################################################################################################################
function Test-Passwords {
  Param(
    [Parameter(Mandatory=$true)]
    [string]$name
  )
  $password = Read-Host -assecurestring "Enter an $($name)"
    $Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($password)
    $pw2test = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)
  $passLength = 14
  $isGood = 0
  if ($pw2test.Length -ge $passLength) {
    $isGood = 1
        if ($pw2test -match " ") {
          Write-Verbose -Message "Password does not meet complexity reyazyrements. Password cannot contain spaces."
          checkPasswords -name $name
          return
        }
        else {
          $isGood = 2
        }
        if ($pw2test -match "[^a-zA-Z0-9]") {
          $isGood = 3
        }
        else {
            Write-Verbose -Message "Password does not meet complexity reyazyrements. Password must contain a special character."
            checkPasswords -name $name
            return
        }
      if ($pw2test -match "[0-9]") {
          $isGood = 4
        }
        else {
            Write-Verbose -Message "Password does not meet complexity reyazyrements. Password must contain a numerical character."
            checkPasswords -name $name
            return
        }
      if ($pw2test -cmatch "[a-z]") {
          $isGood = 5
        }
        else {
            Write-Verbose -Message "Password must contain a lowercase letter."
            Write-Verbose -Message "Password does not meet complexity reyazyrements."
            checkPasswords -name $name
            return
        }
      if ($pw2test -cmatch "[A-Z]") {
          $isGood = 6
        }
        else {
            Write-Verbose -Message "Password must contain an uppercase character."
            Write-Verbose -Message "Password does not meet complexity reyazyrements."
            checkPasswords -name $name
        }
      if ($isGood -ge 6) {
            $passwords | Add-Member -MemberType NoteProperty -Name $name -Value $password
            return
        }
        else {
            Write-Verbose -Message "Password does not meet complexity reyazyrements."
            checkPasswords -name $name
            return
        }
    }
    else {
        Write-Verbose -Message "Password is not long enough - Passwords must be at least $passLength characters long."
        checkPasswords -name $name
        return
    }
}

########################################################################################################################
Function New-AlphaNumericPassword () {
    [CmdletBinding()]
    param(
        [int]$Length = 14
    )
        $ascii=$NULL
        $AlphaNumeric = @(48..57;65..90;97..122)
        Foreach ($Alpha in $AlphaNumeric) {
            $ascii+=,[char][byte]$Alpha
            }
        for ($loop=1; $loop -le $length; $loop++) {
            $RandomPassword+=($ascii | GET-RANDOM)
        }
    return $RandomPassword
}
########################################################################################################################
function New-Cert() {
  [CmdletBinding()]
  param(
    [securestring]$certPassword,
    [string]$domain = $domainused
    )
    ## This script generates a self-signed certificate
    $filePath = ".\"
    $cert = New-SelfSignedCertificate -certestorelocation cert:\localmachine\my -dnsname $domain
    $path = 'cert:\localMachine\my\' + $cert.thumbprint
    $certPath = $filePath + '\cert.pfx'
    $outFilePath = $filePath + '\cert.txt'
    Export-PfxCertificate -cert $path -FilePath $certPath -Password $certPassword
    $fileContentBytes = get-content $certPath -Encoding Byte
    [System.Convert]::ToBase64String($fileContentBytes) | Out-File $outFilePath
}
########################################################################################################################
function Write-Color([String[]]$Text, [ConsoleColor[]]$Color = "White", [int]$StartTab = 0, [int] $LinesBefore = 0, [int] $LinesAfter = 0, [string] $LogFile = "", $TimeFormat = "yyyy-MM-dd HH:mm:ss") {
  # version 0.2
  # - added logging to file
  # version 0.1
  # - first draft
  #
  # Notes:
  # - TimeFormat https://msdn.microsoft.com/en-us/library/8kb3ddd4.aspx

  $DefaultColor = $Color[0]
  if ($LinesBefore -ne 0) {  for ($i = 0; $i -lt $LinesBefore; $i++) { Write-Host "`n" -NoNewline } } # Add empty line before
  if ($StartTab -ne 0) {  for ($i = 0; $i -lt $StartTab; $i++) { Write-Host "`t" -NoNewLine } }  # Add TABS before text
  if ($Color.Count -ge $Text.Count) {
    for ($i = 0; $i -lt $Text.Length; $i++) { Write-Host $Text[$i] -ForegroundColor $Color[$i] -NoNewLine }
  }
  else {
    for ($i = 0; $i -lt $Color.Length ; $i++) { Write-Host $Text[$i] -ForegroundColor $Color[$i] -NoNewLine }
    for ($i = $Color.Length; $i -lt $Text.Length; $i++) { Write-Host $Text[$i] -ForegroundColor $DefaultColor -NoNewLine }
  }
  Write-Host
  if ($LinesAfter -ne 0) {  for ($i = 0; $i -lt $LinesAfter; $i++) { Write-Host "`n" } }  # Add empty line after
  if ($LogFile -ne "") {
    $TextToFile = ""
    for ($i = 0; $i -lt $Text.Length; $i++) {
      $TextToFile += $Text[$i]
    }
    Write-Output "[$([datetime]::Now.ToString($TimeFormat))]$TextToFile" | Out-File $LogFile -Encoding unicode -Append
  }
}
########################################################################################################################
function Get-ScriptDirectory {
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  Split-Path $Invocation.MyCommand.Path
}
########################################################################################################################
function Connect-Azure() {
  Write-Color -Text "Logging in and setting subscription..." -Color Green
  if ([string]::IsNullOrEmpty($(Get-AzContext).Account)) {
    if ($env:AZURE_TENANT) {
      Connect-AzAccount -TenantId $env:AZURE_TENANT
    }
    else {
      Connect-AzAccount
    }
  }
  Set-AzContext -SubscriptionId ${Subscription} | Out-null
}
########################################################################################################################
function New-ResourceGroup([string]$ResourceGroupName, [string]$Location) {
  # Reyazyred Argument $1 = RESOURCE_GROUP
  # Reyazyred Argument $2 = LOCATION

  Get-AzResourceGroup -Name $ResourceGroupName -ev notPresent -ea 0 | Out-null

  if ($notPresent) {
    Write-Host "Creating Resource Group $ResourceGroupName..." -ForegroundColor Yellow
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location
  }
  else {
    Write-Color -Text "Resource Group ", "$ResourceGroupName ", "already exists." -Color Green, Red, Green
  }
}
########################################################################################################################
function Add-Secret ([string]$ResourceGroupName, [string]$SecretName, [securestring]$SecretValue) {
  # Reyazyred Argument $1 = RESOURCE_GROUP
  # Reyazyred Argument $2 = SECRET_NAME
  # Reyazyred Argument $3 = RESOURCE_VALUE

  $KeyVault = Get-AzKeyVault -ResourceGroupName $ResourceGroupName
  if (!$KeyVault) {
    Write-Error -Message "Key Vault in $ResourceGroupName not found. Please fix and continue"
    return
  }

  Write-Color -Text "Saving Secret ", "$SecretName", "..." -Color Green, Red, Green
  Set-AzureKeyVaultSecret -VaultName $KeyVault.VaultName -Name $SecretName -SecretValue $SecretValue
}
########################################################################################################################
function Get-StorageAccount([string]$ResourceGroupName) {
  # Reyazyred Argument $1 = RESOURCE_GROUP

  if ( !$ResourceGroupName) { throw "ResourceGroupName Reyazyred" }

  return (get-AzStorageAccount -ResourceGroupName $ResourceGroupName).StorageAccountName
}
########################################################################################################################
function Get-LoadBalancer([string]$ResourceGroupName) {
  # Reyazyred Argument $1 = RESOURCE_GROUP

  if ( !$ResourceGroupName) { throw "ResourceGroupName Reyazyred" }

  return (Get-AzLoadBalancer -ResourceGroupName $ResourceGroupName).Name
}
########################################################################################################################
function Get-VirtualNetwork([string]$ResourceGroupName) {
  # Reyazyred Argument $1 = RESOURCE_GROUP

  if ( !$ResourceGroupName) { throw "ResourceGroupName Reyazyred" }

  return (Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName).Name
}
########################################################################################################################
function Get-SubNet([string]$ResourceGroupName, [string]$VNetName, [int]$Index) {
  if ( !$ResourceGroupName) { throw "ResourceGroupName Reyazyred" }
  if ( !$VNetName) { throw "VNetName Reyazyred" }

  return (Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VNetName).Subnets[$Index].Name
}
########################################################################################################################
function Get-AutomationAccount([string]$ResourceGroupName) {
  # Reyazyred Argument $1 = RESOURCE_GROUP

  if ( !$ResourceGroupName) { throw "ResourceGroupName Reyazyred" }

  return (Get-AzAutomationAccount -ResourceGroupName $ResourceGroupName).AutomationAccountName
}
########################################################################################################################
function Get-StorageAccountKey([string]$ResourceGroupName, [string]$StorageAccountName) {
  # Reyazyred Argument $1 = RESOURCE_GROUP
  # Reyazyred Argument $2 = STORAGE_ACCOUNT

  if ( !$ResourceGroupName) { throw "ResourceGroupName Reyazyred" }
  if ( !$StorageAccountName) { throw "StorageAccountName Reyazyred" }

  return (get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -AccountName $StorageAccountName).Value[0]
}
########################################################################################################################
function Get-KeyVault([string]$ResourceGroupName) {
  # Reyazyred Argument $1 = RESOURCE_GROUP

  if ( !$ResourceGroupName) { throw "ResourceGroupName Reyazyred" }

  return (Get-AzKeyVault -ResourceGroupName $ResourceGroupName).VaultName
}
########################################################################################################################
function New-Container ($ResourceGroupName, $ContainerName, $Access = "Off") {
  # Reyazyred Argument $1 = RESOURCE_GROUP
  # Reyazyred Argument $2 = CONTAINER_NAME

  # Get Storage Account
  $StorageAccount = get-AzStorageAccount -ResourceGroupName $ResourceGroupName
  if (!$StorageAccount) {
    Write-Error -Message "Storage Account in $ResourceGroupName not found. Please fix and continue"
    return
  }

  $Keys = get-AzStorageAccountKey -Name $StorageAccount.StorageAccountName -ResourceGroupName $ResourceGroupName
  $StorageContext = New-AzureStorageContext -StorageAccountName $StorageAccount.StorageAccountName -StorageAccountKey $Keys[0].Value

  $Container = Get-AzureStorageContainer -Name $ContainerName -Context $StorageContext -ErrorAction SilentlyContinue
  if (!$Container) {
    Write-Warning -Message "Storage Container $ContainerName not found. Creating the Container $ContainerName"
    New-AzureStorageContainer -Name $ContainerName -Context $StorageContext -Permission $Access
  }
}
########################################################################################################################
function Export-File ($ResourceGroupName, $ContainerName, $FileName, $BlobName) {
  # Get Storage Account
  $StorageAccount = get-AzStorageAccount -ResourceGroupName $ResourceGroupName
  if (!$StorageAccount) {
    Write-Error -Message "Storage Account in $ResourceGroupName not found. Please fix and continue"
    return
  }

  $Keys = get-AzStorageAccountKey -Name $StorageAccount.StorageAccountName `
    -ResourceGroupName $ResourceGroupName

  $StorageContext = New-AzureStorageContext -StorageAccountName $StorageAccount.StorageAccountName `
    -StorageAccountKey $Keys[0].Value

  ### Upload a file to the Microsoft Azure Storage Blob Container
  Write-Output "Uploading $BlobName..."
  $UploadFile = @{
    Context   = $StorageContext;
    Container = $ContainerName;
    File      = $FileName;
    Blob      = $BlobName;
  }

  Set-AzureStorageBlobContent @UploadFile -Force;
}
########################################################################################################################
function Get-SASToken ($ResourceGroupName, $StorageAccountName, $ContainerName) {
  # Get Storage Account
  $StorageAccount = get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
  if (!$StorageAccount) {
    Write-Error -Message "Storage Account in $ResourceGroupName not found. Please fix and continue"
    return
  }

  $Keys = get-AzStorageAccountKey -Name $StorageAccount.StorageAccountName `
    -ResourceGroupName $ResourceGroupName

  $StorageContext = New-AzureStorageContext -StorageAccountName $StorageAccount.StorageAccountName `
    -StorageAccountKey $Keys[0].Value

  return New-AzureStorageContainerSASToken -Name $ContainerName -Context $StorageContext -Permission rd -ExpiryTime (Get-Date).AddMinutes(20)
}
########################################################################################################################
function Import-DscConfiguration ($script, $config, $ResourceGroup, $Force) {
  $AutomationAccount = (Get-AzAutomationAccount -ResourceGroupName $ResourceGroup).AutomationAccountName

  $dscConfig = Join-Path $DscPath ($script + ".ps1")
  $dscDataConfig = Join-Path $DscPath $config

  $dscConfigFile = (Get-Item $dscConfig).FullName
  $dscConfigFileName = [io.path]::GetFileNameWithoutExtension($dscConfigFile)

  $dscDataConfigFile = (Get-Item $dscDataConfig).FullName
  $dscDataConfigFileName = [io.path]::GetFileNameWithoutExtension($dscDataConfigFile)

  $dsc = Get-AzAutomationDscConfiguration `
    -Name $dscConfigFileName `
    -ResourceGroupName $ResourceGroup `
    -AutomationAccountName $AutomationAccount `
    -erroraction 'silentlycontinue'

  if ($dsc -and !$Force) {
    Write-Output  "Configuration $dscConfig Already Exists"
  }
  else {
    Write-Output "Importing & compiling DSC configuration $dscConfigFileName"

    Import-AzAutomationDscConfiguration `
      -AutomationAccountName $AutomationAccount `
      -ResourceGroupName $ResourceGroup `
      -Published `
      -SourcePath $dscConfigFile `
      -Force

    $configContent = (Get-Content $dscDataConfigFile | Out-String)
    Invoke-Expression $configContent

    $compiledJob = Start-AzAutomationDscCompilationJob `
      -ResourceGroupName $ResourceGroup `
      -AutomationAccountName $AutomationAccount `
      -ConfigurationName $dscConfigFileName `
      -ConfigurationData $ConfigData

    while ($null -eq $compiledJob.EndTime -and $null -eq $compiledJob.Exception) {
      $compiledJob = $compiledJob | Get-AzAutomationDscCompilationJob
      Start-Sleep -Seconds 3
      Write-Output "Compiling Configuration ..."
    }

    Write-Output "Compilation Complete!"
    $compiledJob | Get-AzAutomationDscCompilationJobOutput
  }
}
########################################################################################################################
function Import-Credential ($CredentialName, $UserName, $UserPassword, $AutomationAccount, $ResourceGroup) {
  $cred = Get-AzAutomationCredential `
    -Name $CredentialName `
    -ResourceGroupName $ResourceGroup `
    -AutomationAccountName $AutomationAccount `
    -ErrorAction SilentlyContinue

  if (!$cred) {
    Set-StrictMode -off
    Write-Output "Importing $CredentialName credential for user $UserName into the Automation Account $account"

    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName, $UserPassword

    New-AzAutomationCredential `
      -Name $CredentialName `
      -ResourceGroupName $ResourceGroup `
      -AutomationAccountName $AutomationAccount `
      -Value $cred
  }
}
########################################################################################################################
function Import-Variable ($name, $value, $ResourceGroup, $AutomationAccount) {
  $variable = Get-AzAutomationVariable `
    -Name $name `
    -ResourceGroupName $ResourceGroup `
    -AutomationAccountName $AutomationAccount `
    -ErrorAction SilentlyContinue

  if (!$variable) {
    Set-StrictMode -off
    Write-Output "Importing $VariableName credential into the Automation Account $account"

    New-AzAutomationVariable `
      -Name $name `
      -Value $value `
      -Encrypted $false `
      -ResourceGroupName $ResourceGroup `
      -AutomationAccountName $AutomationAccount
  }
}
########################################################################################################################
function Add-NodesViaFilter ($filter, $group, $dscAccount, $dscGroup, $dscConfig) {
  Write-Color -Text "`r`n---------------------------------------------------- "-Color Yellow
  Write-Color -Text "Register VM with name like ", "$filter ", "found in ", "$group ", "and apply config ", "$dscConfig", "..." -Color Green, Red, Green, Red, Green, Cyan, Green
  Write-Color -Text "---------------------------------------------------- "-Color Yellow

  Get-AzVM -ResourceGroupName $group | Where-Object { $_.Name -like $filter } | `
    ForEach-Object {
    $vmName = $_.Name
    $vmLocation = $_.Location
    $vmGroup = $_.ResourceGroupName

    $dscNode = Get-AzAutomationDscNode `
      -Name $vmName `
      -ResourceGroupName $dscGroup `
      -AutomationAccountName $dscAccount `
      -ErrorAction SilentlyContinue

    if ( !$dscNode ) {
      Write-Color -Text "Registering $vmName" -Color Yellow
      Start-Job -ScriptBlock { param($vmName, $vmGroup, $vmLocation, $dscAccount, $dscGroup, $dscConfig) `
          Register-AzAutomationDscNode `
          -AzContext $context `
          -AzureVMName $vmName `
          -AzureVMResourceGroup $vmGroup `
          -AzureVMLocation $vmLocation `
          -AutomationAccountName $dscAccount `
          -ResourceGroupName $dscGroup `
          -NodeConfigurationName $dscConfig `
          -RebootNodeIfNeeded $true } -ArgumentList $vmName, $vmGroup, $vmLocation, $dscAccount, $dscGroup, $dscConfig
    }
    else {
      Write-Color -Text "Skipping $vmName, as it is already registered" -Color Yellow
    }
  }
}
########################################################################################################################
function Get-ADGroup([string]$GroupName) {
  # Reyazyred Argument $1 = GROUPNAME

  if ( !$GroupName) { throw "GroupName Reyazyred" }

  $Group = Get-AzureADGroup -Filter "DisplayName eq '$GroupName'"
  if (!$Group) {
    Write-Color -Text "Creating AD Group $GroupName" -Color Yellow
    $Group = New-AzureADGroup -DisplayName $GroupName -MailEnabled $false -SecurityEnabled $true -MailNickName $GroupName
  }
  else {
    Write-Color -Text "AD Group ", "$GroupName ", "already exists." -Color Green, Red, Green
  }
  return $Group
}
########################################################################################################################
function Get-ADuser([string]$Email) {
  # Reyazyred Argument $1 = Email

  Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client
if (!$Email) { throw "Email Reyazyred" }

  $user = Get-AzureADUser -Filter "userPrincipalName eq '$Email'"
  if (!$User) {
    Write-Color -Text "Creating AD User $Email" -Color Yellow
    $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
    $NickName = ($Email -split '@')[0]
    New-AzureADUser -DisplayName "New User" -PasswordProfile $PasswordProfile -UserPrincipalName $Email -AccountEnabled $true -MailNickName $NickName
  }
  else {
    Write-Color -Text "AD User ", "$Email", " already exists." -Color Green, Red, Green
  }

  return $User
}
########################################################################################################################
function Set-ADGroup($Email, $Group) {
  if (!$Email) { throw "User Reyazyred" }
  if (!$Group) { throw "User Reyazyred" }

  $User = GetADUser $Email
  $Group = GetADGroup $Group
  $Groups = New-Object Microsoft.Open.AzureAD.Model.GroupIdsForMembershipCheck
  $Groups.GroupIds = $Group.ObjectId

  $IsMember = Select-AzureADGroupIdsUserIsMemberOf  -ObjectId $User.ObjectId -GroupIdsForMembershipCheck $Groups

  if (!$IsMember) {
    Write-Color -Text "Assigning $Email into ", $Group.DisplayName -Color Yellow, Yellow
    Add-AzureADGroupMember -ObjectId $Group.ObjectId -RefObjectId $User.ObjectId
  }
  else {
    Write-Color -Text "AD User ", "$Email", " already assigned to ", $Group.DisplayName -Color Green, Red, Green, Red
  }
}
########################################################################################################################
function Get-DbConnectionString($DatabaseServerName, $DatabaseName, $UserName, $Password) {
  return "Server=tcp:{0}.database.windows.net,1433;Database={1};User ID={2}@{0};Password={3};Trusted_Connection=False;Encrypt=True;Connection Timeout=30;" -f
  $DatabaseServerName, $DatabaseName, $UserName, $Password
}
########################################################################################################################
function Get-PlainText() {
  [CmdletBinding()]
  param
  (
    [parameter(Mandatory = $true)]
    [System.Security.SecureString]$SecureString
  )
  BEGIN { }
  PROCESS {
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString);

    try {
      return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr);
    }
    finally {
      [Runtime.InteropServices.Marshal]::FreeBSTR($bstr);
    }
  }
  END { }
}
########################################################################################################################
function Get-VmssInstances([string]$ResourceGroupName) {
  # Reyazyred Argument $1 = RESOURCE_GROUP

  if ( !$ResourceGroupName) { throw "ResourceGroupName Reyazyred" }

  $ServerNames = @()
  $VMScaleSets = Get-AzVmss -ResourceGroupName $ResourceGroupName
  ForEach ($VMScaleSet in $VMScaleSets) {
    $VmssVMList = Get-AzVmssVM -ResourceGroupName $ResourceGroupName -VMScaleSetName $VMScaleSet.Name
    ForEach ($Vmss in $VmssVMList) {
      $Name = (Get-AzVmssVM -ResourceGroupName $ResourceGroupName -VMScaleSetName $VMScaleSet.Name -InstanceId $Vmss.InstanceId).OsProfile.ComputerName

      Write-Color -Text "Adding ", $Name, " to Instance List" -Color Yellow, Red, Yellow
      $ServerNames += (Get-AzVmssVM -ResourceGroupName $ResourceGroupName -VMScaleSetName $VMScaleSet.Name -InstanceId $Vmss.InstanceId).OsProfile.ComputerName
    }
  }
  return $ServerNames
}
########################################################################################################################
function Set-SqlClientFirewallRule($SqlServerName, $RuleName, $IP) {
  Get-AzureSqlDatabaseServerFirewallRule -ServerName $SqlServerName -RuleName $RuleName -ev notPresent -ea 0 | Out-null

  if ($notPresent) {
    Write-Host "Creating Sql Firewall Rule $RuleName..." -ForegroundColor Yellow
    New-AzureSqlDatabaseServerFirewallRule -ServerName $DbServer -RuleName $RuleName -StartIpAddress $IP -EndIpAddress $IP
  }
  else {
    Write-Color -Text "SQL Firewall Rule ", "$RuleName ", "already exists." -Color Green, Red, Green
  }
}

<#
    .SYNOPSIS
    Assign RG Policy
#>
function Set-Policy
{
  param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$subscriptionId = "",
    [Parameter(Mandatory=$True,Position=1)]
    [string]$PolicyName = "",
    [Parameter(Mandatory=$True,Position=1)]
    [string]$PolicyDescription = "",
    [Parameter(Mandatory=$True,Position=1)]
    [string]$PolicyFile = "",
    [Parameter(Mandatory=$True,Position=1)]
    [string]$PolicyResourceGroup = "",
    [Parameter(Mandatory=$True,Position=1)]
    [string]$PolicyDisplayName = "",
    [Parameter(Mandatory=$True,Position=1)]
    [string]$PolicyParameterFile = "",
    [Parameter(Mandatory=$True,Position=1)]
    [string]$PolicyScope = "",
    [Parameter(Mandatory=$True,Position=1)]
    [string]$State = ""
  )

     switch ($PolicyScope) {
      "Subscription" {
        $Scope = "/subscriptions/$subscriptionId"
      $PolicyAssignmentName = "$PolicyName-subscription"
        break
      }
      "ResourceGroup" {
        $resourceGroup  = Get-AzResourceGroup -Name $PolicyResourceGroup -ErrorAction Stop -ErrorVariable getAz.ResourceGroupFailed
      if (!$getAz.ResourceGroupFailed)
      {
        $Scope = $resourceGroup.ResourceId
        $PolicyAssignmentName = "$PolicyName-$PolicyResourceGroup"
        break
      }
      else
      {
        return "error"
        exit
      }
      }
      default { throw New-Object ArgumentException('scope') }
    }

  # First check if the policy definition already exists, this determines the cmdlet to change the policyrules
  Write-Host -ForeGroundColor Cyan "Checking if Policy Defintion already exists: $PolicyName"
  $policyDefinition = Get-AzPolicyDefinition | Where-Object {$_.Name -eq $PolicyName}

  # Now prepare the Custom Policy Definition from Template and Parameter File.
  if (!$policyDefinition)
  {
    Write-Host -ForeGroundColor Cyan "Creating new Policy Definition: $PolicyName"
    $policyDefinition = New-AzPolicyDefinition -ErrorAction Stop -ErrorVariable policyDefinitionFailed -Name $PolicyName -DisplayName $PolicyDisplayName -Description $PolicyDescription -Policy $PolicyFile -Parameter $PolicyParameterFile
  }
  else
  {
    Write-Host -ForeGroundColor Cyan "Modifying existing Policy Definition"
    $policyDefinition = Set-AzPolicyDefinition -ErrorAction Stop -ErrorVariable policyDefinitionFailed -Name $PolicyName -DisplayName $PolicyDisplayName -Description $PolicyDescription -Policy $PolicyFile -Parameter $PolicyParameterFile
  }

  # Assign Policy
  if (!$policyDefinitionFailed -and $State -eq "enabled")
  {
    $PolicyAssignmentName = "$PolicyName-$PolicyResourceGroup"
    Write-Host -ForeGroundColor Cyan "Assigning the Policy Definition: $PolicyAssignmentName"
    New-AzPolicyAssignment -Name $PolicyAssignmentName -Scope $Scope  -PolicyDefinition $policyDefinition -ErrorAction Stop -ErrorVariable policyAssignmentFailed
    if  (!$policyDefinitionFailed)
    {
      write-Host -ForeGroundColor Green "Policy Definition completed; Assigning the Policy Definition $PolicyAssignmentName completed"
      Write-Host ""
      Return $subscriptionId
    }
  }
  elseif (!$policyDefinitionFailed)
  {
    Write-Host -ForeGroundColor Green "Policy Definition completed; Assignment was skipped as state was diasabled."
    Write-Host ""
  }
  else
  {
    Write-Host -ForeGroundColor Red "Assignment was skipped as the creation of the Policy Definition has failed."
    Write-Host ""
  }
}

Function Register-AzResourceProvider1
{
  param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$subscriptionId = ""
  )
    # Register ResourceProvider NameSpace "PolicyInsights". Registering this resource provider makes sure that your subscription works with it
    Write-Host -ForeGroundColor Yellow "Registering Az.ResourceProvider for Azure Subscription Id $($subscriptionId)"
    Register-AzResourceProvider -ErrorAction Stop -ProviderNamespace Microsoft.PolicyInsights
}

Function Get-AzPolicySetDefinitionDetails
{
  <#
      .SYNOPSIS
      Assign Get Policy Definitions
  #>
  [CmdletBinding()]
  Param()
  Begin{
    Try{
      $AzPolSetDef = Get-AzPolicySetDefinition
    }
    Catch
    {
        Write-Host -ForegroundColor RED   "Unable to retrieve Azure Policy Definitions"
        Throw
    }
  }

  Process{
    ForEach ($PolSet in $AzPolSetDef)
    {
        Write-Verbose "Processing $($polset.displayName)"

        # Get all all PolicyDefintiions included in the PolicySet
        $includedpoldef = ($PolSet.Properties.policyDefinitions).policyDefinitionId

        $Result = @()
        ForEach ($Azpoldef in $includedpoldef)
        {
            $def = Get-AzPolicyDefinition -Id $Azpoldef

            $object = [ordered] @{
            PolicySetDefName = $PolSet.Name
            PolicySetDefID = $Polset.PolicySetDefinitionId
            PolicySetDefDisplayName = $Polset.Properties.displayName
            PolicySetDefResourceID = $polset.ResourceId
            PolicyDefID = $def.PolicyDefinitionId
            PolicyDefResourceID = $def.ResourceId
            PolicyName = $def.Name
            PolicyID = $def.PolicyDefinitionId
            PolicyDescription = $def.Properties.description
            PolicyDisplayName = $def.Properties.displayName
            PolicyCategory = $def.Properties.metadata.category
            PolicyMode = $def.Properties.mode
            PolicyParam = $def.Properties.parameters
            PolicyRuleIf = $def.Properties.policyRule.if
            PolicyRuleThen = $def.Properties.policyRule.then
            PolicyType = $def.Properties.policyType
        }
        $Result += (New-Object -TypeName PSObject -Property $object)
       }
    }
  }

  End{
    $Result
  }
}

Function New-AADUser
{
  <#
      .SYNOPSIS
        Connect to Azure Active Directory and creates a user

      .DESCRIPTION

      .Parameter UserPrincipalName
        Specifies the user ID for this user

      .Parameter Password
        Specifies the new password for the user

      .Parameter DisplayName
        Specifies the display name of the user

      .Parameter Enabled
        Specifies whether the user is able to log on using their user ID

      .Parameter FirstName
        Specifies the first name of the user

      .Parameter LastName
        Specifies the last name of the user

      .Parameter PostalCode
        Specifies the postal code of the user

      .Parameter City
        Specifies the city of the user

      .Parameter Street
        Specifies the street address of the user

      .Parameter PhoneNumber
        Specifies the phone number of the user

      .Parameter MobilePhone
        Specifies the mobile phone number of the user

      .Parameter Department
        Specifies the department of the user

      .Parameter ForceChangePasswordNextLogin
        Forces a user to change their password during their next log iny

      .Parameter ShowInAddressList
        Specifies show this user in the address list
  #>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName,
    [Parameter(Mandatory = $true)]
    [string]$Password,
    [Parameter(Mandatory = $true)]
    [string]$DisplayName,
    [Parameter(Mandatory = $true)]
    [bool]$Enabled,
    [string]$FirstName,
    [string]$LastName,
    [string]$PostalCode,
    [string]$City,
    [string]$Street,
    [string]$PhoneNumber,
    [string]$MobilePhone,
    [string]$Department,
    [bool]$ForceChangePasswordNextLogin,
    [bool]$ShowInAddressList,
    [ValidateSet('Member','Guest')]
    [string]$UserType='Member'
  )
  Begin{
    try{
      $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
      $PasswordProfile.Password =$Password
      $PasswordProfile.ForceChangePasswordNextLogin =$ForceChangePasswordNextLogin
      $nick = $UserPrincipalName.Substring(0, $UserPrincipalName.IndexOf('@'))
      $Script:User = New-AzureADUser -UserPrincipalName $UserPrincipalName -DisplayName $DisplayName -AccountEnabled $Enabled -MailNickName $nick -UserType $UserType `
                    -PasswordProfile $PasswordProfile -ShowInAddressList $ShowInAddressList | Select-Object *
      if($null -ne $Script:User){
        if($PSBoundParameters.ContainsKey('FirstName') -eq $true ){
            Set-AzureADUser -ObjectId $Script:User.ObjectId -GivenName $FirstName
        }
        if($PSBoundParameters.ContainsKey('LastName') -eq $true ){
            Set-AzureADUser -ObjectId $Script:User.ObjectId -Surname $LastName
        }
        if($PSBoundParameters.ContainsKey('PostalCode') -eq $true ){
            Set-AzureADUser -ObjectId $Script:User.ObjectId -PostalCode $PostalCode
        }
        if($PSBoundParameters.ContainsKey('City') -eq $true ){
            Set-AzureADUser -ObjectId $Script:User.ObjectId -City $City
        }
        if($PSBoundParameters.ContainsKey('Street') -eq $true ){
            Set-AzureADUser -ObjectId $Script:User.ObjectId -StreetAddress $Street
        }
        if($PSBoundParameters.ContainsKey('PhoneNumber') -eq $true ){
            Set-AzureADUser -ObjectId $Script:User.ObjectId -TelephoneNumber $PhoneNumber
        }
        if($PSBoundParameters.ContainsKey('MobilePhone') -eq $true ){
            Set-AzureADUser -ObjectId $Script:User.ObjectId -Mobile $MobilePhone
        }
        if($PSBoundParameters.ContainsKey('Department') -eq $true ){
            Set-AzureADUser -ObjectId $Script:User.ObjectId -Department $Department
        }
        $Script:User = Get-AzureADUser | Where-Object {$_.UserPrincipalName -eq $UserPrincipalName} | Select-Object *
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $Script:User
        }
        else{
            Write-Output $Script:User
        }
      }
      else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "User not created"
        }
        Throw "User not created"
      }
    }
    finally{
    }
  }
}

Function Remove-AADUser
{
  <#
      .SYNOPSIS
        Connect to Azure Active Directory and creates a user

      .DESCRIPTION

      .Parameter UserPrincipalName
        Specifies the user ID for this user

      .Parameter Password
        Specifies the new password for the user

      .Parameter DisplayName
        Specifies the display name of the user

      .Parameter Enabled
        Specifies whether the user is able to log on using their user ID

      .Parameter FirstName
        Specifies the first name of the user

      .Parameter LastName
        Specifies the last name of the user

      .Parameter PostalCode
        Specifies the postal code of the user

      .Parameter City
        Specifies the city of the user

      .Parameter Street
        Specifies the street address of the user

      .Parameter PhoneNumber
        Specifies the phone number of the user

      .Parameter MobilePhone
        Specifies the mobile phone number of the user

      .Parameter Department
        Specifies the department of the user

      .Parameter ForceChangePasswordNextLogin
        Forces a user to change their password during their next log iny

      .Parameter ShowInAddressList
        Specifies show this user in the address list
  #>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName
  )
  Begin{
    try{
      $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
      $PasswordProfile.Password =$Password
      $PasswordProfile.ForceChangePasswordNextLogin =$ForceChangePasswordNextLogin
      $nick = $UserPrincipalName.Substring(0, $UserPrincipalName.IndexOf('@'))
      $Script:User = Remove-AzureADUser -ObjectId $UserPrincipalName
    }
    Catch
    {
        Write-Host -ForegroundColor RED   "Unable to remove Azure User Account : $UserPrincipalName"
        Throw
    }
  }
}

Function New-SPNApp
{
  <#
      .SYNOPSIS
        Creates a SP with Certitifcate and an Application

      .DESCRIPTION

  #>
  param
  (
    [string] $spnName,
    [string] $subscriptionName,
    [string] $applicationName,
    [string] $location,
    [String] $certPath,
    [String] $certPlainPassword,
    [string] $spnRole = "contributor",
    [switch] $grantRoleOnSubscriptionLevel = $true,
    [string] $applicationNamePrefix = "Dpi30."
  )

  #Initialize
  Add-Type -AssemblyName Microsoft.Azure.PowerShell.Clients.Graph.Rbac
  $displayName = [String]::Format("$applicationNamePrefix{0}", $applicationName)
  $homePage = "http://" + $displayName
  $identifierUri = $homePage

  # Initialize subscription
  $isAzureModulePresent = Get-Module -Name Az.Resources -ListAvailable
  if ([String]::IsNullOrEmpty($isAzureModulePresent) -eq $true)
  {
    Write-Output "Script reyazyres Az modules to be present. Obtain Az from https://github.com/Azure/azure-powershell/releases. Please refer https://github.com/Microsoft/vsts-tasks/blob/master/Tasks/DeployAzureResourceGroup/README.md for recommended Az versions." -Verbose
    return
  }

  #Import Modules
  Import-Module -Name Az.Resources

  $azureSubscription = get-AzSubscription -SubscriptionName $subscriptionName
  $tenantId = $azureSubscription.TenantId
  $id = $azureSubscription.SubscriptionId

  # Setup certificate
  $certPassword = ConvertTo-SecureString $certPlainPassword -AsPlainText -Force
  $certObject = new-object Security.Cryptography.X509Certificates.X509Certificate2
  $bytes = [convert]::FromBase64String($certPassword.SecretValueText)
  $certObject.Import($bytes, $null, [Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable -bor [Security.Cryptography.X509Certificates.X509KeyStorageFlags]::PersistKeySet)

  #$PFXCert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @($certPath, $certPassword)
  $PFXCert = $certObject.Export([Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12, $certPassword)
  $pfxFilePath = "$certPath\$displayName.pfx"
  $keyValue = [System.Convert]::ToBase64String($PFXCert.GetRawCertData())
  $keyCredential = New-Object -TypeName Microsoft.Azure.Graph.RBAC.Version1_6.ActiveDirectory.PSADKeyCredential
  $keyCredential.StartDate =  $PFXCert.NotBefore
  $keyCredential.EndDate = $PFXCert.NotAfter
  $keyCredential.KeyId = [guid]::NewGuid()
  $keyCredential.CertValue = $keyValue

  #Check if the application already exists
  $app = Get-AzADApplication -IdentifierUri $homePage

  if (![String]::IsNullOrEmpty($app) -eq $true)
  {
    $appId = $app.ApplicationId
    Write-Output "An Azure AAD Appication with the provided values already exists, skipping the creation of the application..."
  }
  else
  {
    # Create a new AD Application, secured by a certificate
    Write-Output "Creating a new Application in AAD (App URI - $identifierUri)" -Verbose
    $azureAdApplication = New-AzADApplication -DisplayName $displayName -HomePage $homePage -IdentifierUris $identifierUri -KeyCredentials $keyCredential -Verbose
    $appId = $azureAdApplication.ApplicationId
    Write-Output "Azure AAD Application creation completed successfully (Application Id: $appId)" -Verbose
  }

  # Check if the principal already exists
  $spn = Get-AzADServicePrincipal -ServicePrincipalName $appId

  if (![String]::IsNullOrEmpty($spn) -eq $true)
  {
    Write-Output "An Azure AAD Application Principal for the application already exists, skipping the creation of the principal..."
  }
  else
  {
    # Create new SPN
    Write-Output "Creating a new SPN" -Verbose
    $spn = New-AzADServicePrincipal -ApplicationId $appId -DisplayName $spnName
    $spnName = $spn.ServicePrincipalNames
    Write-Output "SPN creation completed successfully (SPN Name: $spnName)" -Verbose

    Write-Output "Waiting for SPN creation to reflect in Directory before Role assignment"
    Start-Sleep 20
  }

  if ($grantRoleOnSubscriptionLevel)
  {
    # Assign role to SPN to the whole subscription
    Write-Output "Assigning role $spnRole to SPN App $appId for subscription $subscriptionName" -Verbose
    New-AzRoleAssignment -RoleDefinitionName $spnRole -ServicePrincipalName $appId
    Write-Output "SPN role assignment completed successfully" -Verbose
  }

  # Print the values
  Write-Output "`nCopy and Paste below values for Service Connection" -Verbose
  Write-Output "***************************************************************************"
  Write-Output "Subscription Id: $id"
  Write-Output "Subscription Name: $subscriptionName"
  Write-Output "Service Principal Client (Application) Id: $appId"
  Write-Output "Certificate password: $certPlainPassword"
  Write-Output "Certificate: $keyValue"
  Write-Output "Tenant Id: $tenantId"
  Write-Output "Service Principal Display Name: $displayName"
  Write-Output "Service Principal Names:"
  foreach ($spnname in $spn.ServicePrincipalNames)
  {
      Write-Output "   *  $spnname"
  }
  Write-Output "***************************************************************************"
}

function Get-RoleScopes {
  <#
      .Synopsis
      Output a role's scopes to a text file.

      .Description
      This function will output the scopes (subscriptions) to a text file

      .Parameter Role
      Reyazyred - name of the role you want to get the actions from

      .Parameter scopesfile
      Optional - text file to output role actions too.  Def = Role_scopes.txt

  #>
  Param ( [Parameter(Mandatory=$True)] [string] $role, [string] $scopesfile, [string] $subid )

  If ($scopesfile -eq "") { $scopesfile = 'Role_scopes.txt'; }
  If ($subid -ne ""){
    $subdef = get-AzSubscription -SubscriptionId $subid;
    Select-AzContext -Name $subdef.Name
  }

  # Get the current role definitoin
  $roledef = Get-AzRoleDefinition -Name $role

  # Open the $scopesfile
  try { Set-Content -Path $scopesfile -Value $null }
  catch { write-output "File $scopesfile is in use. Please close it first then run this again. Exiting."; Return 0}

  # write the scopes to the $scopesfile
  foreach ($scope in $roledef.AssignableScopes) {Add-Content -Path $scopesfile -Value $scope }

  Write-output """$role""'s scopes have been written to $scopesfile"
  Return $roledef
}
function Get-RoleActions {
  <#
      .Synopsis
      Output a role's actions to a text file.

      .Description
      This function will output the permissions (actions) to a text file which you may then
      edit and use the New-Role or Update-Role function to create or modify a role.

      .Parameter Role
      Reyazyred - name of the role you want to get the actions from.

      .Parameter actionsfile
      Optional - text file to output role actions too.  Def = Role_actions.txt

  #>
  Param ( [Parameter(Mandatory=$True)] [string] $role, [string] $actionsfile, [string] $subid )

  If ($actionsfile -eq "") { $actionsfile = 'Role_actions.txt'; }
  If ($subid -ne ""){
    $subdef = get-AzSubscription -SubscriptionId $subid;
    Select-AzContext -Name $subdef.Name
  }

  # Get the current role definitoin
  $roledef = Get-AzRoleDefinition -Name $role

  # Open the $actionsfile
  try { Set-Content -Path $actionsfile -Value $null }
  catch { write-output "File $actionsfile is in use. Please close it first then run this again. Exiting."; Return 0}

  # write the actions to the $actionsfile
  foreach ($action in $roledef.Actions) {Add-Content -Path $actionsfile -Value $action }

  Write-output """$role""'s actions have been written to $actionsfile"
  Return $roledef
}

function New-Role {
  <#
      .Synopsis
      Create a new role based on Azure actions entered in a text file.
      Use Get-RoleActions to dump out an existing roles actions to a text file for editting.

      .Description
      Create a new role based on Azure actions entered in a text file.
      Use Get-RoleActions to dump out an existing roles actions to a text file for editting.

      .Parameter Role
      Name for the Role will also be the description.

      .Parameter actionsfile
      Text file with list of permissions "actions".  Use Get-RoleActions to dump out an existing roles actions to a text file for editting.

      .Parameter scopegroup
      "all"  = "prod","test","dev","misc","test1"
      "prod" = all HOL production subscriptions
      "test" = all 5 HOL test subscriptions
      "dev"  = all HOL development subscriptions
      "misc" = weird miscelleneous subscriptions
      "test1"= useful for testing before populating to all test
      "test4"= useful for testing before populating to all test
  #>
    Param ( [Parameter(Mandatory=$True)] [string] $role,
            [Parameter(Mandatory=$True)] [string] $actionsfile,
                                         [string] $scopegroup )

  # Get the current role definitoin
  Add-Type -AssemblyName Microsoft.Azure.PowerShell.Cmdlets.Resources
  if ($scopegroup -eq "" ){ $scopegroup = 'test4' } # Microsoft Managed Labs Valorem (test) - 4

  $roledef = New-Object -type Microsoft.Azure.Commands.Resources.Models.Authorization.PSRoleDefinition;
  $roledef.Id = $null
  $roledef.IsCustom = $true
  $roledef.Name = $role
  $roledef.Description = $role

  # Load up the AssignableScopes = list of "/subscriptions/<subid>" from the scope
  If ($scopegroup.ToLower() -notin "all","prd","tst","dev","misc","test1","test4") { Write-Output "Invalid scope Exiting. Use one of the following [all,prd,tst,dev,misc,test1,test4]"; Exit 1}

  # update scope from $scope
  $scope = @();
  switch ($scopegroup) {
    all   { $scope = Set-ScopeAll   }
    prod  { $scope = Set-ScopeProd  }
    test1 { $scope = Set-ScopeTest1 }
    test4 { $scope = Set-ScopeTest4 }
    test  { $scope = Set-ScopeTest  }
    dev   { $scope = Set-ScopeDev   }
    misc  { $scope = Set-ScopeMisc  }
    Default { $scope = Set-ScopeTest };
  }
  $roledef.AssignableScopes = $scope;

  # load up the actions from the text file
  foreach($line in [System.IO.File]::ReadLines($actionsfile)) {
    $roledef.Actions += $line;
  }

  $roledef = New-AzRoleDefinition -Role $roledef

  Write-output "$role [Id= $($roledef.Id) ] = $created for scope $scope"
  Return $roledef
}
function Export-SubscriptionBlueprints {
  <#
      .Synopsis
      Output a Blueprint to files.

      .Description
      This function will output the Azure Blueprints in a subscription to a folder and files.

      .Parameter $subscriptionId
      Reyazyred - the Azure subscription to export the Blueprints from

      .Parameter $exportPath
      Reyazyred - The path to export the blueprints to.

  #>
  Param (
    [Parameter(Mandatory=$True)]
    [string] $subscriptionId,
    [Parameter(Mandatory=$True)]
    [string] $exportPath
  )

  $BPs = Get-AzBlueprint -SubscriptionId $subscriptionId
  foreach ($BP in $BPs) {
    Export-AzBlueprintWithArtifact `
            -Blueprint $BP `
            -OutputPath $exportPath `
            -Force `
            -Verbose
  }
}

function Export-ManagementGroupBlueprints {
  <#
      .Synopsis
      Output a Blueprint to files.

      .Description
      This function will output the Azure Blueprints in a subscription to a folder and files.

      .Parameter $subscriptionId
      Reyazyred - the Azure subscription to export the Blueprints from

      .Parameter $exportPath
      Reyazyred - The path to export the blueprints to.

  #>
  Param (
    [Parameter(Mandatory=$True)]
    [string] $managementGroupId,
    [Parameter(Mandatory=$True)]
    [string] $exportPath
  )

  $BPs = Get-AzBlueprint -ManagementGroupId  $managementGroupId
  foreach ($BP in $BPs) {
    Export-AzBlueprintWithArtifact `
            -Blueprint $BP `
            -OutputPath $exportPath `
            -Force `
            -Verbose
  }
}
  <#
    .Synopsis
    Create a Blueprint name for assignments

    .Parameter $blueprintName
    Reyazyred - Name of the blueprint

    .Parameter $blueprintVersion
    Reyazyred - Version of the blueprint

#>
function New-BlueprintName(
      [Parameter(Mandatory=$True)][string]$blueprintName,
      [Parameter(Mandatory=$True)][string]$blueprintVersion)
      {
    $joined = -join($blueprintName, '-',$blueprintVersion)
    return $joined.Replace(".","")
}

<#
    .SYNOPSIS
    Takes ARM template output and turns them into Azure DevOps Pipeline variables

    .DESCRIPTION
    Takes the ARM template output (usually from the Azure Deployment task in VSTS) and creates VSTS variables of the same name with the values so they can be used in subsequent tasks.

    .PARAMETER ARMOutput
    The JSON output from the ARM template to convert into variables.
    If using the Azure Deployment task in an Azure Pipeline, you can set the output to a variable by specifying `Advanced > Deployment outputs`.
    This variable must be wrapped in single quotes when passing to this parameter in an Azure DevOps task.

    .PARAMETER Rename
    [Optional] Allows you to create a VSTS variable with a different name to the output name.
    Takes a dictionary where the key is the name of the ARM template output and the value is the desired name of the VSTS variable.

    .EXAMPLE
    ConvertTo-VSTSVariables.ps1 -ARMOutput '$(ARMOutputs)'
    where ARMOutputs is the name from Advanced > Deployment outputs from the Azure Deployment task.  Note that $(ARMOutputs) is wrapped in single quotes.

#>
function Convert-ToPipelineVariable
{
  [CmdletBinding()]
  param (
      [Parameter(Mandatory=$true)]
      [string]$ARMOutput,
      [Parameter(Mandatory=$false)]
      [hashtable]$Rename
  )

  # Output from ARM template is a JSON document
  try {
      $JsonVars = $ARMOutput | ConvertFrom-Json
  }
  catch {
      Write-Debug "Unable to convert ARMOutput to JSON:`n$ARMOutput"
      throw "Unable to convert ARMOutput to JSON.  Add Debug switch to view ARMOutput."
  }

  # the outputs with be of type noteproperty, get a list of all of them
  foreach ($OutputName in ($JsonVars | Get-Member -MemberType NoteProperty).name) {
      # get the type and value for each output
      $OutputTypeValue = $JsonVars | Select-Object -ExpandProperty $OutputName
      $OutputType = $OutputTypeValue.type
      $OutputValue = $OutputTypeValue.value

      # Check if variable name needs renaming
      if ($OutputName -in $Rename.keys) {
          $OldName = $OutputName
          $OutputName = $Rename[$OutputName]
          Write-Output "Creating VSTS variable $OutputName from $OldName"
      }
      else {
          Write-Output "Creating VSTS variable $OutputName"
      }

      # Set VSTS variable
      if ($OutputType.toLower() -eq 'securestring') {
          Write-Output "##vso[task.setvariable variable=$OutputName;issecret=true]$OutputValue"
      }
      else {
          Write-Output "##vso[task.setvariable variable=$OutputName]$OutputValue"
      }
  }
}

<#
    .SYNOPSIS

    .DESCRIPTION

    .PARAM

    .EXAMPLE

    .NOTES
        LASTEDIT: August 17, 2018

#>

function Import-Runbook ($ResourceGroup,$AutomationAccountName,$RunbookName,$RunbookType,$ScriptPath) {
  try
  {
    $rbexists = Get-AzAutomationRunbook -AutomationAccountName $AutomationAccountName -ResourceGroupName $ResourceGroup -Name $RunbookName

    if(!$rbexists) {
      Import-AzAutomationRunbook -Name $RunbookName -Path $ScriptPath -ResourceGroupName $ResourceGroup -AutomationAccountName $AutomationAccountName -Type $RunbookType
      Publish-AzAutomationRunbook -AutomationAccountName $AutomationAccountName -Name $RunbookName -ResourceGroupName $ResourceGroup
    }
  }
  catch
  {
    Write-Error "An error occurred during Runbook Deployment."
    throw
  }
}

#
# Azure Resource Manager documentation definitions
#

# A function to break out parameters from an ARM template
function Get-TemplateResources {
    param (
        [Parameter(Mandatory = $True)]
        [String]$Path
    )

    process {
        $template = Get-Content $Path | ConvertFrom-Json;
        foreach ($property in $template.resources.PSObject.Properties) {
            [PSCustomObject]@{
              Name = $property.Name
              Type = $property.Type
              Description = $property.Value.metadata.description
              ApiVersion = $property.apiVersion
            }
        }
    }
}

# A function to break out parameters from an ARM template
function GetTemplateParameter {
    param (
        [Parameter(Mandatory = $True)]
        [String]$Path
    )

    process {
        $template = Get-Content $Path | ConvertFrom-Json;
        foreach ($property in $template.parameters.PSObject.Properties) {
            [PSCustomObject]@{
              Name = $property.Name
              Type = $property.Type
              Description = $property.Value.metadata.description
              DefaultValue = $property.DefaultValue
            }
        }
    }
}
# A function to get the parameter values from an ARM template
function Get-TemplateParameterValues {
    param (
        [Parameter(Mandatory = $True)]
        [String]$Path
    )

    process {
        $template = Get-Content $Path | ConvertFrom-Json;
        foreach ($property in $template.parameters.PSObject.Properties) {
            [PSCustomObject]@{
                Name = $property.Name
                Value = $property.Value.metadata.value
            }
        }
    }
}

# A function to import metadata
function Get-TemplateMetadata {
    param (
        [Parameter(Mandatory = $True)]
        [String]$Path
    )

    process {
        $metadata = Get-Content $Path | ConvertFrom-Json;
        return $metadata;
    }
}

# Export the functions above.
Export-ModuleMember -Function 'Add-*'
Export-ModuleMember -Function 'Close-*'
Export-ModuleMember -Function 'ConvertTo-*'
Export-ModuleMember -Function 'ConvertFrom-'
Export-ModuleMember -Function 'Export-*'
Export-ModuleMember -Function 'Deploy-*'
Export-ModuleMember -Function 'Get-*'
Export-ModuleMember -Function 'Import-*'
Export-ModuleMember -Function 'Load-*'
Export-ModuleMember -Function 'New-*'
Export-ModuleMember -Function 'Open-*'
Export-ModuleMember -Function 'Read-*'
Export-ModuleMember -Function 'Set-*'
Export-ModuleMember -Function 'Save-*'
Export-ModuleMember -Function '*'
