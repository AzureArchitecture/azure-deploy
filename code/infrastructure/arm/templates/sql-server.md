# SQL Server 

Deploys a SQL Server 

## Paramaters

**sqlServerName**: (required) string

Name of SQL Server.
Will be created in the same resource group as the script is run and in the default location for resource group.
The fully qualified domain name of the SQL server is available as an output of the template - sqlServerFqdn

**sqlServerAdminUserName**: (optional) string

SQL SA administrator username.
Only used if the database does not exist and needs creating.
Only used when the server is created.
Does not change settings if the server already exists (will not change the admin username on an existing server).
The username is available as an output of the template - saAdministratorLogin

**sqlServerAdminPassword**: (required) securestring

SQL SA administrator password.
Only used when the server is created.
Does not change settings if the server already exists (will not change the admin password on an existing server).

**StorageAccountName**: (required) string

Name of a storage account to store logs to.

**sqlServerActiveDirectoryAdminLogin**: (required) string

Name of AAD user or group to grant administrator rights to.

**sqlServerActiveDirectoryAdminObjectId**: (required) string

Object ID of AAD user or group above.

**threatDetectionEmailAddress**: (optional) array

Array of email addresses to send the threat detected emails to.
If not provided will not email anyone.


**Tags**
- **Display Name**-A description of the azure resource or service.
- **Application name**-Name of the application, service, or workload the resource is associated with.
- **Approver name**-Person responsible for approving costs related to this resource.
- **Budget required/approved**-Money allocated for this application, service, or workload.
- **Business unit**-Top-level division of your company that owns the subscription or workload the resource belongs to. In smaller organizations, this tag might represent a single corporate or shared top-level organizational element.
- **Cost center**-Accounting cost center associated with this resource.
- **Disaster recovery**-Business criticality of the application, workload, or service.
- **End date of the project**-Date when the application, workload, or service is scheduled for retirement.
- **Environment**-Deployment environment of the application, workload, or service.
- **Owner name**-Owner of the application, workload, or service.
- **Requester name**-User who requested the creation of this application.
- **Service class**-Service level agreement level of the application, workload, or service.
- **Start date of the project**-Date when the application, workload, or service was first deployed.