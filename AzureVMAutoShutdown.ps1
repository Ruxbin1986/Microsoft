workflow Stop-VM {
	inlineScript {
		$startTime = get-date
		$cred = Get-AutomationPSCredential -Name "AutoCred"
		$throwAway = Login-AzureRMAccount -Credential $cred
		$results = Get-AzureRmVM | Stop-AzureRmVM -force | Out-String
		if($results -eq $null)
    		{
        		Write-Output "There are no VMs to stop"
    		}
    		else
    		{
			$subject = "Script Run Time " + ([DateTime]::Now - $startTime).ToString()
			$cred = Get-AutomationPSCredential -Name "EmailCredential"
			Send-MailMessage -To "v-tebree@microsoft.com" -Subject $subject -Body $results -Port 587 -SmtpServer smtp.live.com -Credential $cred -UseSsl -From $cred.Username
 		}
		}
	}
