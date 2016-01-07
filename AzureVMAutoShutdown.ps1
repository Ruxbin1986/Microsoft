workflow Stop-VM {
	inlineScript {
		$startTime = get-date
		$cred = Get-AutomationPSCredential -Name "AutoCred"
		$throwAway = Login-AzureRMAccount -Credential $cred
		$subscriptionname = "Ruxbin"
		#$suboutput = Select-AzureRMSubscription -SubscriptionName $subscriptionname
		#$subscriptionoutput = Get-AzureRmSubscription | fl SubscriptionName | Out-String
		$results = Get-AzureRmVM | Stop-AzureRmVM -force | Out-String
		if($results -eq $null)
    		{
        		Write-Output "There are no VMs to stop in $subscriptionoutput"
    		}
    		else
    		{
    			$elapsedtime = (((Get-Date) - $startTime).Seconds).ToString()
			$subject = "Azure Automation - VMs deallocated from " + $subscriptionoutput + " in " + $elapsedtime + " Seconds"
			$cred = Get-AutomationPSCredential -Name "EmailCredential"
			Send-MailMessage -To "v-tebree@microsoft.com" -Subject $subject -Body $results -Port 587 -SmtpServer smtp.live.com -Credential $cred -UseSsl -From $cred.Username
 		}
		}
	}
