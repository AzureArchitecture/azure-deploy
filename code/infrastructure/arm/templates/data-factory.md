# Data Factory

Creates an Azure Data Factory.  Optionally an Azure DevOps or GitHub repo can be added for source controlling the definitions of linked services, pipelines, etc.  Alternatively Azure DataFactory Mode (ADM) can be used, this is the default if no Azure DevOps (VSTS) or GitHub parameters are supplied.  There are drawbacks to both integrated source control options so the recommended approach is ADM.

## Parameters

**DataFactoryName**: (required) string

Name of the data factory. Must be globally unique.

**DataFactoryLocation**: (optional) string

Location of the data factory. Currently, only East US, East US 2, and West Europe are supported.  Template defaults to West Europe.

**apiVersion** (required) string

The API to use for the ARM template deployment. 

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