[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true, Position=1)]
    [string]$inputFile,
    
    [Parameter(Mandatory=$true, Position=2)]
    [string]$outputFile
 
)

$excel = New-Object -ComObject excel.application
$excel.visible = $false
# book
$report = $excel.Workbooks.Add()
$actualPath = Get-Location
$path = Join-Path -Path $actualPath -ChildPath (".\" + $outputFile + ".xlsx")

$logs_wksht = $report.Worksheets.Item(1)
$logs_wksht.Name = "2889 Logs"

# header
$logs_wksht.Cells.Item(1, 1) = 'EventID'
$logs_wksht.Cells.Item(1, 2) = 'MachineName'
$logs_wksht.Cells.Item(1, 3) = 'Message'
$logs_wksht.Cells.Item(1, 4) = 'TimeGenerated'
$logs_wksht.Cells.Item(1, 5) = 'TimeWritten'
$logs_wksht.Cells.Item(1, 6) = 'UserName'
$logs_wksht.Cells.Item(1, 7) = 'IPaddress'
$logs_wksht.Cells.Item(1, 8) = 'Identity'
$logs_wksht.Cells.Item(1, 9) = 'BindingType'


$result_csv = ".\" + $inputFile + ".csv"

$elements = Import-Csv -Path $result_csv

# body
$i = 2
foreach ($element in $elements) {
    $logs_wksht.Cells.Item($i, 1) = $element.EventID  
    $logs_wksht.Cells.Item($i, 2) = $element.MachineName 
    $logs_wksht.Cells.Item($i, 3) = $element.Message
    $logs_wksht.Cells.Item($i, 4) = $element.TimeGenerated
    $logs_wksht.Cells.Item($i, 5) = $element.TimeWritten
    $logs_wksht.Cells.Item($i, 6) = $element.UserName
    $logs_wksht.Cells.Item($i, 7) = $element.IPaddress
    $logs_wksht.Cells.Item($i, 8) = $element.Identity
    $logs_wksht.Cells.Item($i, 9) = $element.BindingType

    $i++ 
}


$report.saveas($path) 
$excel.Quit()

Remove-Variable -Name logs_wksht

# Remove-Item -Path $result_csv
[gc]::collect() 
[gc]::WaitForPendingFinalizers()