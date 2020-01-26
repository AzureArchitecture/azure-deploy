# Storage Account Container

Creates a container in a storage account.
See https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-container-create.


## Paramaters

**containerName**: (required) string

Name of container in the storage account.
Will default to container1 if not supplied.

**ResourceGroupName**: (required) string
The name of the resource group that the storage account will be deployed to. 

**StorageAccountName**: (required) string

Name of storage account.
Must not globally unique consisting of lowercase letters and numbers only.
Will be created in the same resource group as the script is run and in the default location for resource group.
Will default to <project>-data-001 if not supplied.

**publicAccess**: (optional) string

You can enable anonymous, public read access to a container and its blobs in Azure Blob storage. 
Must be one of the following:
- None
- Container
- Blob

Will default to None if not supplied.
see https://docs.microsoft.com/en-us/azure/storage/blobs/storage-manage-access-to-resources.

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

   