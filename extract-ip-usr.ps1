##
# use with
# .\extract-ip-usr.ps1 -path "\path\to\file" -inputFile "inputfile-without-extension" "outputfile-without-extension"
#
###########################################
## get Logs in CVS
## get logs from Directory Services with event ID 2889

## without start time
# Get-EventLog -LogName "Directory Service" | Where-Object {$_.EventID -eq 2889} | Export-Csv output.csv

## with start time
# $Begin = Get-Date -Date '5/2/2020 06:00:00'

# Get-EventLog -LogName "Directory Service" -After $Begin | Where-Object {$_.EventID -eq 2889} | Export-Csv output.csv
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true, Position=1)]
    [string]$path,

    [Parameter(Mandatory=$true, Position=1)]
    [string]$inputFile,
    
    [Parameter(Mandatory=$true, Position=2)]
    [string]$outputFile
 
)

$ip_usr = @()
$csv = "$path\$inputFile.csv"
## $s="The following client performed a SASL (Negotiate/Kerberos/NTLM/Digest) LDAP bind without requesting Client IP address: 10.10.0.10:33276 Identity the client attempted to authenticate as: DOMAIN\usr Binding Type: 1"
$elements = Import-Csv -Path $csv

foreach ($element in $elements) {
    $info = "" | select EventID, MachineName, Message, TimeGenerated, TimeWritten, UserName, IPaddress, Identity, BindingType 
    $info.EventID = $element.EventID
    $info.MachineName = $element.MachineName
    $info.Message = $element.Message
    $info.TimeGenerated = $element.TimeGenerated
    $info.TimeWritten = $element.TimeWritten
    $info.UserName = $element.UserName

    $msg = $element.Message 
    # $ipi = $msg.IndexOf("Client IP address:")
    # $ipi
    # $usri= $msg.IndexOf("Identity the client attempted to authenticate as:")
    # $bti = $msg.IndexOf("Binding Type:")
        
    # ip
    $found_ip = $msg -match '(\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b)'
    if ($found_ip) {
        $info.IPaddress = $matches[1]
    }
    # usr
    $found_usr = $msg -match '(\w*\\(.*))'
    if ($found_usr) {
        $info.Identity = $matches[1]
    }
    # binding

    $found_bt = $msg -match '(.$)'
    if ($found_bt) {
        $info.BindingType = $matches[1]
    }

    $ip_usr += $info
}

$path = "$path\$outputFile.csv"

$ip_usr | export-csv $path -NoTypeInformation
