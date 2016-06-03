﻿$Targets=@()
get-adcomputer -filter * | select -expandproperty name | foreach {if ((test-connection -computername $_ -quiet) -eq $true) {$targets=$targets+$_}}

foreach ($t in $targets) {$admins=gwmi win32_groupuser -computername $t | where {$_.groupcomponent -like "*Administrators*"} | select partcomponent ; $admins=$admins | select -expandproperty partcomponent | out-string ; $result=$admins | select-string '(domain.*)' -allmatches | % {$_.matches} | select value ; $result+$t | out-file  C:\test.txt -append}