##############################################
# Canary script meant to detect Cryptolocker #
##############################################

#this is the build script. It preps the machine then creates and executes the monitor script.

#This part takes user-provided O365 credentials and converts it to a secure string. Stored on C:\ because I am lazy.
$credential=get-credential
$credential.password | convertfrom-securestring | set-content C:\EncryptedPassword.txt

#Next we create an empty array to hold our share paths.
$array=@()

#Leverage WMI to enumerate shares, then pipe to a foreach/testpath to determine which are active.
gwmi win32_share | select -expand path | foreach {if (test-path $_) {$array=$array+$_}}

#Now we create our "canary" files.
foreach ($path in $array){set-content $path\_A.txt "Canary file for Cryptolocker detection - DO NOT MODIFY"}

#Next we create our monitor script
$script={

#This part is hardcoded- sorry, couldn't think of a better way
$user="gsmith@lmjconsulting.com"

#pulls the password we entered earlier
$password=get-content C:\EncryptedPassword.txt | convertto-securestring

#combines the password and username
$cred=new-object system.management.automation.pscredential ($user,$password)

#Array to hold our share paths
$array=@()

#Enumerating shares and populating our array
gwmi win32_share | select -expand path | foreach {if (test-path $_) {$array=$array+$_}}

#While ($True) means it will always run
While ($True) {

#This statement is testing to see if the canary file exists. If not, it's been encrypted and an email is sent. If it does exist, the script checks the last write date.
#If the last write date is greater than the given date, an email is fired off.
#### NOTE: You must set a date, and also input settings for email. Sorry again but I couldn't think of a better way ####
foreach ($path in $Array) {if (test-path $path\_A.txt) {$item=get-itemproperty $path\_a.txt ; if ($item.lastwritetime -gt "4/15/2016") {

send-mailmessage -from "gsmith@lmjconsulting.com" -to "gsmith@lmjconsulting.com" -subject "Suspicious write activity on $path" -body "Canary at $path has been written to" -credential ($cred) -usessl -smtpserver smtp.office365.com -port "587"

}
}
else {

send-mailmessage -from "gsmith@lmjconsulting.com" -to "gsmith@lmjconsulting.com" -subject "Suspicious write activity on $path" -body "Canary at $path no longer exists" -credential ($cred) -usessl -smtpserver smtp.office365.com -port "587"


}
}
#Once either (or neither) of the above conditions are met, the script sleeps for 60 seconds
sleep 60
}
}

#Creates the monitor script
set-content -path "C:\CanaryScript.ps1" -value "$script"

#creates launch script (.PS1 won't run on startup, but batch will)
set-content -path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\LaunchScript.bat" -value 'powershell.exe -windowstyle hidden -executionpolicy bypass -c "C:\CanaryScript.ps1"'

#calls the monitor script so that it runs immediately (in the future it will always run on startup) 

& powershell.exe -windowstyle hidden -executionpolicy bypass -c "C:\CanaryScript.ps1"

