# Get two parameters begin time and end time, if no parameter is written, the logs are obtained from the previous day at 6 AM
# eg1
# $begin = Get-Date -Date '5/2/2020 06:00:00'
# $end = Get-Date -Date '5/2/2020 06:00:00'
# funciona con cualquier formato de fecha
# verified with two different date formats

# eg2 
# .\logs.ps1 outputFile (begin) (end)
# .\logs.ps1 output all
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true, Position=1)]
    [string]$outputFile,
 
    [Parameter(Position=2)]
    [string]$begin,
 
    [Parameter(Position=3)]
    [string]$end
 
)

$CultureDateTimeFormat = (Get-Culture).DateTimeFormat
$DateFormat = $CultureDateTimeFormat.ShortDatePattern
$TimeFormat = $CultureDateTimeFormat.LongTimePattern
$DateTimeFormat = "$DateFormat $TimeFormat"

if ($begin -eq "" -and $end -eq "") {
    $begin = Get-Date -Date ([DateTime]::Today.AddDays(-1).AddHours(6)) -Format $DateTimeFormat
    $end = Get-Date -Format $DateTimeFormat
}

# busca evento 2889
if ($begin -eq "all" -and $end -eq "") {
    Get-EventLog -LogName "Directory Service" | Where-Object {$_.EventID -eq 2889} | Export-Csv output.csv
}
else {
    Get-EventLog -LogName "Directory Service" -After $begin -Before $end | Where-Object {$_.EventID -eq 2889} | Export-Csv output.csv
}


$ip_usr = @()
# $csv = ".\output.csv"
$csv = "output.csv"
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

# $result_csv = ".\" + $outputFile + ".csv"
$result_csv = $outputFile + ".csv"
Remove-Item -Path $csv
$ip_usr | export-csv $result_csv -NoTypeInformation