#
# Function to create a path if it does not exist
#
function CreatePathIfNotExists($pathName) {
  if(!(Test-Path -Path $pathName)) {
      New-Item -ItemType directory -Path $pathName
  }
}

#
# Creating my code directories
#
$repoCoreDir = "C:\repos"
CreatePathIfNotExists -pathName "$repoCoreDir"
CreatePathIfNotExists -pathName "$repoCoreDir\github"
CreatePathIfNotExists -pathName "$repoCoreDir\azdo"
CreatePathIfNotExists -pathName "$repoCoreDir\github\AzureArchitecture"

cd "$repoCoreDir\github\AzureArchitecture"
git clone https://github.com/AzureArchitecture/azure-deploy.git
git clone https://github.com/AzureArchitecture/azure-data-services.git
