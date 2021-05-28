
 <#
.SYNOPSIS

This script was created to change the description of computers not-logged in for over a year
move them to their own "StaleComputers" OU and send you an email of all of the
computer names and last logon time.

DESCRIPTION

Script searches through rmuohp.local/RMU-Computers for computers with the LastLogonDate older than specified amount of time (1 year default)
Then changes all of their descriptions letting you know when it was changed by the script.
Then gives you the option to send an email containing a csv with the computer names and last logon dates. 

EXAMPLE

PS C:\StaleComputers.ps1

Starts script

.NOTES

This is WIP. Started May 2021 - Scott Wheeler

#>
$yesNo = Read-Host -Prompt "Do you want to send an email with a csv of the computers in question? Type 'No' to not send email or 'Yes' to send email"
    if ($yesNo -eq "No") {
        $inactive = 365
        $lldate = (Get-Date).AddDays(-($Inactive))
        $sourceOU = "OU=RMU-Computers, DC=rmuohp, DC=local"
        $destinationOU = "OU=StaleComputers, DC=rmuohp, DC=local"
        $computers = Get-ADComputer -Filter {LastLogonTimeStamp -lt $lldate} -SearchBase $sourceOU
        $desc="Disabled on $(Get-Date -Format MM/dd/yyy)-$($computer.Description) by Scott W" 

        $data = foreach ($computer in $computers) 
            {
            Set-ADComputer $computer -Description $desc -Enabled $false 
            Get-ADComputer $computer -Properties * | Select-Object Name, LastLogonDate 
            # Move-ADObject $computer -TargetPath $destinationOU
            } 
        $today = Get-Date -Format yyyy-MM-dd
        $data | Export-Csv .\StaleComputer_$today.csv -NoTypeInformation

    }
    elseif ($yesNo -eq "Yes") {
        $inactive = 365
        $lldate = (Get-Date).AddDays(-($Inactive))
        $sourceOU = "OU=RMU-Computers, DC=rmuohp, DC=local"
        $destinationOU = "OU=StaleComputers, DC=rmuohp, DC=local"
        $computers = Get-ADComputer -Filter {LastLogonTimeStamp -lt $lldate} -SearchBase $sourceOU
        $desc="Disabled on $(Get-Date -Format MM/dd/yyy)-$($computer.Description) by Scott W" 

        $data = foreach ($computer in $computers) 
            {
            Set-ADComputer $computer -Description $desc -Enabled $false 
            Get-ADComputer $computer -Properties * | Select-Object Name, LastLogonDate 
            # Move-ADObject $computer -TargetPath $destinationOU
            } 
        $today = Get-Date -Format yyyy-MM-dd
        $data | Export-Csv .\StaleComputer_$today.csv -NoTypeInformation


        <#
            EMAIL SECTION

            This section is only for sending emails based on the script above
            Input email subject, email body, who you're sending it to, and the file attachment location. 

            Example 
        #>

        $email = "scott.wheeler@rm.edu"
		# Make sure to put back password / Not hardcode it so script can be shared.
        $password = ""
        [SecureString]$securepassword = $password | ConvertTo-SecureString -AsPlainText -Force
        $myCreds = New-Object System.Management.Automation.PSCredential -ArgumentList $email, $securepassword
        $subject = Read-Host -Prompt "Input email Subject"
        $body = Read-Host -Prompt "Insert email body"
        $sendto = Read-Host -Prompt "Who do you want to send this email to?"
        $attachment = Read-Host -Prompt "Input file name"
        Send-MailMessage -SmtpServer smtp.gmail.com -Port 587 -UseSsl -From scott.wheeler@rm.edu -To $sendto -Cc scott.wheeler@rm.edu -Subject $subject -Body $body -Attachments $attachment -Credential $myCreds

    }
    else {
        "Sorry, the only options I accept are 'Yes' and 'No'"
    }
