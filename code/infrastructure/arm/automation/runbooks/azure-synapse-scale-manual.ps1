workflow azure-synapse-scale-manual {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$ConnectionName = "AzureRunAsConnection",
        [parameter(Mandatory=$true)]
        [string]$SQLActionAccountName,
        [parameter(Mandatory=$true)]
        [string]$ServerName,
        [parameter(Mandatory=$true)]
        [string]$DWName,
        [parameter(Mandatory=$true)]
        [ValidateSet(
            "DW100", 
            "DW200", 
            "DW300",
            "DW400",
            "DW500",
            "DW600",
            "DW1000",
            "DW1200",
            "DW1500",
            "DW2000",
            "DW3000",
            "DW6000"
        )]
        [string]$RequestedServiceObjectiveName,
        [int]$RetryCount = 5,
        [int]$RetryTime = 60  
    )

    $credSQL = Get-AutomationPSCredential -Name $SQLActionAccountName
    $AutomationConnection= Get-AutomationConnection -Name $ConnectionName
    $SQLUser = $credSQL.Username
    $SQLPass = $credSQL.GetNetworkCredential().Password
    $null = Add-AzureRmAccount -ServicePrincipal -TenantId $AutomationConnection.TenantId -ApplicationId $AutomationConnection.ApplicationId -CertificateThumbprint $AutomationConnection.CertificateThumbprint
    $DWDetail = (Get-AzureRmResource | Where-Object {$_.Kind -like "*datawarehouse*" -and $_.Name -like "*/$DWName"})
    if ($null -ne $DWDetail) {
        $DWDetail = $DWDetail.ResourceId.Split("/")
        $cRetry = 0
        #Ensure that the ADW is online. Wait to ensure that if it is transitioning, the proper action is taken
        do {
            if ($cRetry -ne 0) {Start-Sleep -Seconds $RetryTime}
            $DWStatus = (Get-AzureRmSqlDatabase -ResourceGroup $DWDetail[4] -ServerName $DWDetail[8] -DatabaseName $DWDetail[10]).Status
            Write-Verbose "Test $cRetry status is $DWStatus looking for Online"
            $cRetry++
        } while ($DWStatus -ne "Online" -and $cRetry -le $RetryCount )
        if ($DWStatus -eq "Online") {
            $DWSON = (Get-AzureRmSqlDatabase -ResourceGroup $DWDetail[4] -ServerName $ServerName.Split(".")[0] -DatabaseName $DWDetail[10]).CurrentServiceObjectiveName
            Write-Verbose "Requested SLO is $RequestedServiceObjectiveName current SLO is $DWSON"
            if ($DWSON -ne $RequestedServiceObjectiveName) {
                $CanScale = InLineScript {
                    $testquery = @"
                    with test as 
                    (
                        select
                        (select @@version) version_number
                        ,(select count(*) from sys.dm_pdw_exec_requests where status in ('Running', 'Pending', 'CancelSubmitted') and session_id != SESSION_ID()) active_query_count
                        ,(select count(*) from sys.dm_pdw_exec_sessions where is_transactional = 1) as session_transactional_count
                        ,(select count(*) from sys.dm_pdw_waits where type = 'Exclusive') as pdw_waits
                    )
                    select
                        case when
                                version_number like 'Microsoft Azure SQL Data Warehouse%'
                                and active_query_count = 0
                                and session_transactional_count = 0
                                and pdw_waits = 0
                                then 1
                        else 0
                        end as CanScale
                    from test
"@
                    $DBConnection = New-Object System.Data.SqlClient.SqlConnection("Server=$($Using:ServerName); Database=$($Using:DWName);User ID=$($Using:SQLUser);Password=$($Using:SQLPass);")
                    $DBConnection.Open()
                    $DBCommand = New-Object System.Data.SqlClient.SqlCommand($testquery, $DBConnection)
                    $DBAdapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter
                    $DBDataSet = New-Object -TypeName System.Data.DataSet
                    $DBAdapter.SelectCommand = $DBCommand
                    $DBAdapter.Fill($DBDataSet) | Out-Null
                    # Returning result to CanScale
                    if ($DBDataSet.Tables[0].Rows[0].CanScale) {$true} else {$false}
                    try{$DBConnection.Close()} catch {}
                }
                If ($CanScale) {
                    Write-Verbose "Calling Scale"
                    Set-AzureRmSqlDatabase -ResourceGroup $DWDetail[4] -ServerName $ServerName.Split(".")[0] -DatabaseName $DWDetail[10] -RequestedServiceObjectiveName $RequestedServiceObjectiveName -ErrorAction SilentlyContinue
                }
                else {Write-Error "Azure SQL Data Warehouse $DWName on server $ServerName has outestanding request and will not be scaled at this time."}
            }
        }
        $cRetry = 0
        #Now lets wait to ensure that the ADW has come online before completing
        do {
            if ($cRetry -ne 0) {Start-Sleep -Seconds $RetryTime}
            $DWStatus = (Get-AzureRmSqlDatabase -ResourceGroup $DWDetail[4] -ServerName $DWDetail[8] -DatabaseName $DWDetail[10]).Status
            Write-Verbose "Test $cRetry status is $DWStatus looking for Online"
            $cRetry++
        } while ($DWStatus -ne "Online" -and $cRetry -le $RetryCount )
        if ($DWStatus -eq "Online") {
            #Call RefreshReplicatedTables
            #RefreshReplicatedTable -SQLActionAccountName $SQLActionAccountName -ServerName $ServerName -DWName $DWName
        }
        else{
            Write-Error "Scale operation submitted. Operation did not complete timely."
        }
    }
    else {
        Write-Error "No Azure SQL Data Warehouse named $DWName exist on SQL Server $ServerName."
    }
}
