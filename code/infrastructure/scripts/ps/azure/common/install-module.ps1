Function Install-ModuleIfNotInstalled(
    [string] [Parameter(Mandatory = $true)] $moduleName,
    [string] $minimalVersion,
    [switch] $InstallLatest
) {
    $module = Get-Module -Name $moduleName -ListAvailable |`
        Where-Object { $null -eq $minimalVersion -or $minimalVersion -ge $_.Version } |`
        Select-Object -Last 1
    if ($null -ne $module) {
      Write-Verbose ('Module {0} (v{1}) is available.' -f $moduleName, $module.Version)
    }
    else {
      Import-Module -Name 'PowershellGet'
      if($InstallLatest)
      {
        #find the current version in the gallery
        Try {
          $onlineVersion = Find-Module -Name $moduleName.name -Repository PSGallery -ErrorAction Stop
          $RequiredVersion = $onlineVersion
        }
        Catch {
          Write-Warning "Module $($module.name) was not found in the PSGallery"
        }
      }
      
      
      $installedModule = Get-InstalledModule -Name $moduleName -ErrorAction SilentlyContinue
      if ($null -ne $installedModule) {
        Write-Verbose ('Module [{0}] (v {1}) is installed.' -f $moduleName, $installedModule.Version)
      }
      if ($null -eq $installedModule -or ($null -ne $minimalVersion -and $installedModule.Version -lt $minimalVersion)) {
        Write-Verbose ('Module {0} min.vers {1}: not installed; check if nuget v2.8.5.201 or later is installed.' -f $moduleName, $minimalVersion)
        #First check if package provider NuGet is installed. Incase an older version is installed the required version is installed explicitly
        if ((Get-PackageProvider -Name NuGet -Force).Version -lt '2.8.5.201') {
          Write-Warning ('Module {0} min.vers {1}: Install nuget!' -f $moduleName, $minimalVersion)
          Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force
        }        
        $optionalArgs = New-Object -TypeName Hashtable
        if ($null -ne $minimalVersion) {
                $optionalArgs['RequiredVersion'] = $minimalVersion
            }  
            elseif ($InstallLatest)
            {
              $onlineVersion = Find-Module -Name $moduleName.name -Repository PSGallery -ErrorAction Stop
              $optionalArgs['RequiredVersion'] = $onlineVersion
            }
            Write-Warning ('Install module {0} (version [{1}]) within scope of the current user.' -f $moduleName, $minimalVersion)
            Install-Module -Name $moduleName @optionalArgs -Scope CurrentUser -Force -Verbose
        } 
    }
}

Install-ModuleIfNotInstalled 'PSLogging' -InstallLatest

#Get-Module -Name 'Az' -ListAvailable -All 