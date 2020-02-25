function Get-AzSecurityStatus
{
	<#
	https://msdn.microsoft.com/en-us/library/mt704041.aspx
	#>
	[CmdletBinding()]
	param
	(
	)

	DynamicParam
	{
		$DynamicParameters = @(
			@{
				Name = 'Subscription'
				Type = [object]
				Position = 0
				Mandatory = $true
			},
			@{
				Name = 'ResourceType'
				Type = [string]
				Position = 2
				Manndatory = $false
				ValidateSet = (Get-AzResource |Select-Object -Property ResourceType -Unique |Select-Object -ExpandProperty ResourceType)
			}
		)
		$DynamicParameters |ForEach-Object {New-Object -TypeName psobject -Property $_} |New-DynamicParameter;
	}

	begin
	{
		$Subscription = $PSBoundParameters['Subscription'];
		$ResourceType = $PSBoundParameters['ResourceType'];
	}

	process
	{
		try
		{
			$ErrorActionPreference = 'Stop';
			$Error.Clear();

			$ResourceId = "/subscriptions/$($Subscription.SubscriptionId)/providers/microsoft.Security/securityStatuses";
			$ApiVersion = '2015-06-01-preview';

			if ($ResourceType)
			{
				Get-AzResource -ResourceId $ResourceId -ApiVersion $ApiVersion |Where-Object -Property ResourceType -EQ $ResourceType;
			}
			else
			{
				Get-AzResource -ResourceId $ResourceId -ApiVersion $ApiVersion;
			}
		}
		catch
		{
			throw $_;
		}
	}

	end
	{
	}
}

function Get-AzSecurityAlert
{
	<#
	https://msdn.microsoft.com/en-us/library/mt704050.aspx
	#>
	[CmdletBinding()]
	param
	(
	)

	DynamicParam
	{
		$DynamicParameters = @(
			@{
				Name = 'Subscription'
				Type = [object]
				Position = 0
				Mandatory = $true
			},
			@{
				Name = 'ResourceType'
				Type = [string]
				Position = 2
				Manndatory = $false
				ValidateSet = (Get-AzResource |Select-Object -Property ResourceType -Unique |Select-Object -ExpandProperty ResourceType)
			}
		)
		$DynamicParameters |ForEach-Object {New-Object -TypeName psobject -Property $_} |New-DynamicParameter;
	}

	begin
	{
		$Subscription = $PSBoundParameters['Subscription'];
		$ResourceType = $PSBoundParameters['ResourceType'];
	}

	process
	{
		try
		{
			$ErrorActionPreference = 'Stop';
			$Error.Clear();

			$ResourceId = "/subscriptions/$($Subscription.SubscriptionId)/providers/microsoft.Security/alerts";
			$ApiVersion = '2015-06-01-preview';

			if ($ResourceType)
			{
				Get-AzResource -ResourceId $ResourceId -ApiVersion $ApiVersion |Where-Object -Property ResourceType -EQ $ResourceType;
			}
			else
			{
				Get-AzResource -ResourceId $ResourceId -ApiVersion $ApiVersion;
			}
		}
		catch
		{
			throw $_;
		}
	}

	end
	{
	}
}

function Get-AzSecurityTask
{
	<#
	https://msdn.microsoft.com/en-us/library/mt704053.aspx
	#>
	[CmdletBinding()]
	param
	(
	)

	DynamicParam
	{
		$DynamicParameters = @(
			@{
				Name = 'Subscription'
				Type = [object]
				Position = 0
				Mandatory = $true
			}
		)
		$DynamicParameters |ForEach-Object {New-Object -TypeName psobject -Property $_} |New-DynamicParameter;
	}

	begin
	{
		$Subscription = $PSBoundParameters['Subscription'];
	}

	process
	{
		try
		{
			$ErrorActionPreference = 'Stop';
			$Error.Clear();

			$ResourceId = "/subscriptions/$($Subscription.SubscriptionId)/providers/microsoft.Security/tasks";
			$ApiVersion = '2015-06-01-preview';

			Get-AzResource -ResourceId $ResourceId -ApiVersion $ApiVersion;
		}
		catch
		{
			throw $_;
		}
	}

	end
	{
	}
}

function Get-AzSecurityPolicy
{
	<#
	https://msdn.microsoft.com/en-us/library/mt704061.aspx
	#>
	[CmdletBinding()]
	param
	(
	)

	DynamicParam
	{
		$DynamicParameters = @(
			@{
				Name = 'Subscription'
				Type = [object]
				Position = 0
				Mandatory = $true
			},
			@{
				Name = 'Name'
				Type = [string]
				Position = 1
				Mandatory = $false
			}
		)
		$DynamicParameters |ForEach-Object {New-Object -TypeName psobject -Property $_} |New-DynamicParameter;
	}

	begin
	{
		$Subscription = $PSBoundParameters['Subscription'];
		$PolicyName = $PSBoundParameters['Name'];
	}

	process
	{
		try
		{
			$ErrorActionPreference = 'Stop';
			$Error.Clear();

			$ResourceId = "/subscriptions/$($Subscription.SubscriptionId)/providers/microsoft.Security/policies";
			$ApiVersion = '2015-06-01-preview';

			if ($PolicyName)
			{
				$ResourceId = "$($ResourceId)/$($PolicyName)";
			}
			
			Get-AzResource -ResourceId $ResourceId -ApiVersion $ApiVersion;
		}
		catch
		{
			throw $_;
		}
	}

	end
	{
	}
}

function Get-AzSecurityDataCollection
{
	<#
	https://msdn.microsoft.com/en-us/library/mt704044.aspx
	#>
	[CmdletBinding()]
	param
	(
	)

	DynamicParam
	{
		$DynamicParameters = @(
			@{
				Name = 'Subscription'
				Type = [object]
				Position = 0
				Mandatory = $true
			},
			@{
				Name = 'ResourceGroupName'
				Type = [string]
				Position = 1
				Mandatory = $true
			},
			@{
				Name = 'VMName'
				Type = [string]
				Position = 2
				Mandatory = $true
			},
			@{
				Name = 'Type'
				Type = [string]
				Position = 3
				Mandatory = $true
				ValidateSet = 'Microsoft.Compute','Microsoft.ClassicCompute'
			},
			@{
				Name = 'ResultType'
				Type = [string]
				Position = 3
				Mandatory = $true
				ValidateSet = 'patch','baseline','antimalware'
			}
		)
		$DynamicParameters |ForEach-Object {New-Object -TypeName psobject -Property $_} |New-DynamicParameter;
	}

	begin
	{
		$Subscription = $PSBoundParameters['Subscription'];
		$ResourceGroupName = $PSBoundParameters['ResourceGroupName']
		$VMName = $PSBoundParameters['VMName'];
		$ResourceType = $PSBoundParameters['Type'];
		$ResultType = $PSBoundParameters['ResultType'];
	}

	process
	{
		try
		{
			$ErrorActionPreference = 'Stop';
			$Error.Clear();

			$ResourceId = "/subscriptions/$($Subscription.SubscriptionId)/resourceGroups/$($ResourceGroupName)/providers/$($ResourceType)/virtualMachines/$($VMName)/providers/Microsoft.Security/dataCollectionResults/$($ResultType)";
			$ApiVersion = '2015-06-01-preview';

			Get-AzResource -ResourceId $ResourceId -ApiVersion $ApiVersion;
		}
		catch
		{
			throw $_;
		}
	}

	end
	{
	}
}

