# Variables 
# Path for HTML file output
$htmlfile = ".\LogonActivity.html"

# Table Creation
$LogonActivityTable = New-Object system.Data.DataTable “Logon/Logoff Activity”

# Create Columns
$date = New-Object system.Data.DataColumn "Date",([string])
$type = New-Object system.Data.DataColumn "Type",([string])
$status = New-Object system.Data.DataColumn "Status",([string])
$user = New-Object system.Data.DataColumn "User",([string])
$ipaddress = New-Object system.Data.DataColumn "IPAddress",([string])

# Add Columns to Table
$LogonActivityTable.columns.add($date)
$LogonActivityTable.columns.add($type)
$LogonActivityTable.columns.add($status)
$LogonActivityTable.columns.add($user)
$LogonActivityTable.columns.add($ipaddress)

# Reads the hostname, sets to the local hostname if left blank 
$hostname = read-host "Enter the IP or hostname of the computer you wish to scan (Leave blank for local)" 
if ($hostname.length -eq 0){$hostname = $env:computername} 
 
# Reads the start date, sets to 1/1/2000 if left blank 
$startTmp = read-host "Enter the start date to scan from (MM/DD/YYYY, default 1/1/2000)" 
if ($startTmp.length -eq 0){$startTmp = "1/1/2000"} 
$startDate = get-date $startTmp 
 
# Reads the end date, sets to the current date and time if left blank 
$endTmp = read-host "Enter the end date to scan to (MM/DD/YYYY, default current time)" 
if ($endTmp.length -eq 0){$endTmp = get-date} 
$endDate = get-date $endTmp 
 
# Reads a Yes or No response to print only the failed login attempts, defaults to No 
$scope = read-host "Print only failed logins (Y/N, default N)" 
if ($scope.length -eq 0){$scope = "N"} 

# Reads a the requested output type 
$output = read-host "Output Type ((T)able, (G)ridview, (H)TML, default List)"
 
# Writes a line with all the parameters selected for report 
write-host "Hostname: "$hostname "`tStart: "$startDate "`tEnd: "$endDate "`tOnly Failed Logins: "$scope "`n"
 
# Store each event from the Security Log with the specificed dates and computer in an array 
$log = Get-Eventlog -LogName Security -ComputerName $hostname -after $startDate -before $endDate 
 
# Loop through each security event, print only failed login attempts 
if ($scope -match "Y"){ 
    foreach ($i in $log){ 
        # Logon Failure Events 
        # Local 
        if (($i.EventID -eq 4625 ) -and ($i.ReplacementStrings[10] -eq 2)){ 
            # Create a Row
            $row = $LogonActivityTable.NewRow()

            # Enter Data into the Row
            $row.date =  $i.TimeGenerated
            $row.type =  "Logon - Local"
            $row.status =  "Failure"
            $row.user =  $i.ReplacementStrings[5]
            $row.ipaddress = ""

            # Add the Row to the Table
            $LogonActivityTable.Rows.Add($row)
        } 
        # Remote 
        if (($i.EventID -eq 4625 ) -and ($i.ReplacementStrings[10] -eq 10)){ 
            # Create a Row
            $row = $LogonActivityTable.NewRow()

            # Enter Data into the Row
            $row.date =  $i.TimeGenerated
            $row.type =  "Logon - Remote"
            $row.status =  "Failure"
            $row.user =  $i.ReplacementStrings[5]
            $row.ipaddress = $i.ReplacementStrings[19]

            # Add the Row to the Table
            $LogonActivityTable.Rows.Add($row)
        } 
    }         
} 
# Loop through each security event, print all login/logoffs with type, date/time, status, account name, and IP address if remote 
else{ 
    foreach ($i in $log){ 
        # Logon Successful Events 
        # Local (Logon Type 2) 
        if (($i.EventID -eq 4624 ) -and ($i.ReplacementStrings[8] -eq 2)){ 
            # Create a Row
            $row = $LogonActivityTable.NewRow()

            # Enter Data into the Row
            $row.date =  $i.TimeGenerated
            $row.type =  "Logon - Local"
            $row.status =  "Success"
            $row.user =  $i.ReplacementStrings[5]
            $row.ipaddress = ""

            # Add the Row to the Table
            $LogonActivityTable.Rows.Add($row)
        } 
        # Remote (Logon Type 10) 
        if (($i.EventID -eq 4624 ) -and ($i.ReplacementStrings[8] -eq 10)){ 
            # Create a Row
            $row = $LogonActivityTable.NewRow()

            # Enter Data into the Row
            $row.date =  $i.TimeGenerated
            $row.type =  "Logon - Remote"
            $row.status =  "Success"
            $row.user =  $i.ReplacementStrings[5]
            $row.ipaddress = $i.ReplacementStrings[18]

            # Add the Row to the Table
            $LogonActivityTable.Rows.Add($row)
        } 
         
        # Logon Failure Events 
        # Local 
        if (($i.EventID -eq 4625 ) -and ($i.ReplacementStrings[10] -eq 2)){ 
            # Create a Row
            $row = $LogonActivityTable.NewRow()

            # Enter Data into the Row
            $row.date =  $i.TimeGenerated
            $row.type =  "Logon - Local"
            $row.status =  "Failure"
            $row.user =  $i.ReplacementStrings[5]
            $row.ipaddress = ""

            # Add the Row to the Table
            $LogonActivityTable.Rows.Add($row)
        } 
        # Remote 
        if (($i.EventID -eq 4625 ) -and ($i.ReplacementStrings[10] -eq 10)){ 
            # Create a Row
            $row = $LogonActivityTable.NewRow()

            # Enter Data into the Row
            $row.date =  $i.TimeGenerated
            $row.type =  "Logon - Remote"
            $row.status =  "Failure"
            $row.user =  $i.ReplacementStrings[5]
            $row.ipaddress = $i.ReplacementStrings[19]

            # Add the Row to the Table
            $LogonActivityTable.Rows.Add($row)
        } 
         
        # Logoff Events 
        if ($i.EventID -eq 4647 ){ 
            # Create a Row
            $row = $LogonActivityTable.NewRow()

            # Enter Data into the Row
            $row.date =  $i.TimeGenerated
            $row.type =  "Logoff"
            $row.status =  "Success"
            $row.user =  $i.ReplacementStrings[1]
            $row.ipaddress = ""

            # Add the Row to the Table
            $LogonActivityTable.Rows.Add($row)
        }  
    } 
}

# Outputs
# Table
if ($output -match "T"){ 
    $LogonActivityTable | Format-Table
}

# HTML
elseif ($output -match "H"){ 
    # HTML Styles
    $style = "<style>"
    $style = $style + "BODY{background-color:#F2F2F2;}"
    $style = $style + "TABLE{border-width: 1px;border-style: solid;border-color: black;}"
    $style = $style + "TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:#BDBDBD}"
    $style = $style + "TD{border-width: 1px;padding: 5px;border-style: solid;border-color: black;background-color:#D8D8D8}"
    $style = $style + "</style>"

    $LogonActivityTable | Select-Object Date, Type, Status, User, IPAddress | ConvertTo-Html -head $style -body "<h2>Logon Activity:</h2>" | Out-File $htmlfile
    Invoke-Expression $htmlfile
}

# Grid View
elseif ($output -match "G"){ 
    $LogonActivityTable | Out-GridView -Title "Logon Activity"
}

# Default output, returns the table object in list form by default
else{
    $LogonActivityTable
}
