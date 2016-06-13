Function Create-ADUser{
##name should be in the following format: John Doe
##UPN will be first letter of first name + last name, EG. JDoe
[cmdletbinding()]
    param(
    [parameter(mandatory=$true)]
    [string]$name,
    [parameter (mandatory=$true)]
    [string]$copyfrom
   
)
$password=read-host "please enter a password" -assecurestring
$firstname=$name.split(" ")[0]
$lastname=$name.split(" ")[1]
$UPN=($Firstname.substring(0,1))+$lastname

new-aduser -samaccountname $UPN -name $name -givenname $firstname -surname $lastname -accountpassword $password -userprincipalname $UPN

$groups=(get-aduser -identity $copyfrom -properties memberof).memberof

foreach ($group in $groups) {Add-ADGroupMember $group $name}
}
