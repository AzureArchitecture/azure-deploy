<# 
.SYNOPSIS  
    The purpose of this runbook is to demonstrate how to restore a database to a new database using an Azure Automation workflow.
 
.DESCRIPTION 
    WARNING: This runbook deletes a database. The database which you will be restoring to will be deleted upon the next run of this runbook.
    
    This runbook is designed to restore a single database to a test database. It will first try to delete the old test database. Then it will create a new one with data from 24 hours ago.

    
.PARAMETER SourceServerName
    This is the name of the server where the source database is located
    
.PARAMETER SourceDatabaseName
    This is the name of the database being restored from
    
.PARAMETER ActiveDirectoryUser
    This is the name of the Active Directory User used to authenticate with. 
    Example: MyActiveDirectoryUser@LiveIDEmail.onmicrosoft.com
 
 .PARAMETER SubscriptionName
    This is the name of the subscription where the database is on.
    
 .PARAMETER HoursBack
    This is how many hours back you want the copy of the database to be restored too.
    
.NOTES 
    AUTHOR: Eli Fisher
    LASTEDIT: March 11, 2015
#> 
 
workflow azure-sql-db-backup-daily
{ 
    param([Parameter(Mandatory=$True)] 
      [ValidateNotNullOrEmpty()] 
      [String]$SourceServerName,
      [Parameter(Mandatory=$True)]  
      [ValidateNotNullOrEmpty()] 
      [String]$SourceDatabaseName,
      [Parameter(Mandatory=$True)]  
      [ValidateNotNullOrEmpty()] 
      [String]$ActiveDirectoryUser,
      [Parameter(Mandatory=$True)]  
      [ValidateNotNullOrEmpty()] 
      [String]$SubscriptionName,
      [Parameter(Mandatory=$True)]  
      [ValidateNotNullOrEmpty()] 
      [int]$HoursBack
      )
      
    #Configure PowerShell credentials and connection context
    $Cred = Get-AutomationPSCredential -Name $ActiveDirectoryUser #Replace this with the account used for Azure Automation authentication with Azure Active Directory
    Add-AzureAccount -Credential $Cred
    Select-AzureSubscription -SubscriptionName $SubscriptionName #Replace this with your subscription name
    
    #Set the point in time to restore too and the target database
    
    $PointInTime = (Get-Date).AddHours(-$HoursBack) #This gets the point in time for the database restore
    $TargetDatabaseName = 'Copy_' + $SourceDatabaseName  #Replace this with the name of the database you want to restore to
    
    Write-Output "Deleting the old $TargetDatabaseName"
    #Delete the old database copy
    Remove-AzureSqlDatabase -ServerName $SourceServerName -DatabaseName $TargetDatabaseName -Force #Delete the day old copy database.
    
    Write-Output "Creating new $TargetDatabaseName with data at time $PointInTime"
    #Start the database restore to refresh the data
    Start-AzureSqlDatabaseRestore -SourceServerName $SourceServerName -SourceDatabaseName $SourceDatabaseName -TargetDatabaseName $TargetDatabaseName -PointInTime $PointInTime

}
