
### Deployment

Try it out in Azure Cloud Shell!

[![CloudShellIcon]][CloudShell]

```ps
 .\dpi30-deploy-adap-platform.ps1 `
 -adUsers `
 -adGroups `
 -adServicePrincipals `
 -azPolicies `
 -azInitiatives `
 -azRoles `
 -azRoleAssignments `
 -azBlueprints `
 -azActionGroups `
 -azAlerts `
 -azParameterFiles `
 -alertResourceGroup "rg-shared-dev" `
 -location "centralus" `
 -env "dev" ` 
 -debugAction `
 -actionVerboseVariable = 'SilentlyContinue', `
 -actionErrorVariable = 'SilentlyContinue', `
 -actionDebugVariable = 'SilentlyContinue', `
 -informationPreferenceVariable = 'SilentlyContinue', `
 -deployAction = 'create' `
 -removeRG
```

### What this script does
- Create Azure Active Directory Users
- Create Azure Active Directory Security Groups
- Create Azure Active Directory Security Principals
- Create Azure Policies
- Create Azure Policy Initiatives
- Create Azure Roles
- Create Role Assignments
- Create Azure Blueprint
	- Deploys afc Baseline Controls for Azure (Azure Policy Initiatives)
	- Setup and  configuration of Azure Security Center
	- Enables Subscription diagnostic monitoring
	- Deploys Log Analytics
	- Creates Resource Group for Shared Services
	- Creates Resource Group for ADAP
	- Creates Resource Group for Security
	- Creates Resource Group for Management
	- Creates Resource Group for Network
	- Deploys Azure Key Vault
	- Deploys Virtual Network/NSG/Routes
- Create Azure Action Groups
- Create Azure Alerts  
- Create Azure ARM Template Parameter Files from Excel Spreadsheet
