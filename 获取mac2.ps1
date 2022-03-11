Import-Module -Name  SSHSessions 
function Update-Private{param($User,$Password)$password | Out-File -Force  $env:USERPROFILE\PWD.secSet-ItemProperty   $env:USERPROFILE\PWD.sec -name Attributes -Value "Hidden"$pwd = (Get-Content -Force $env:USERPROFILE\PWD.sec  | ConvertTo-SecureString -AsPlainText   -Force)$Credential = New-Object System.Management.Automation.PSCredential $user, $pwdRemove-Item -Force $env:USERPROFILE\PWD.secreturn $Credential }
## 交换机账号密码的获取
Function Format-MacTableCisco
{
param($UserName_and_Password,$SwIp,$SwName)
New-SshSession -ComputerName $SwIp -Credential $UserName_and_Password
$MAC_Table_String =  Invoke-SshCommand   -Quiet -ComputerName  $SwIp -ScriptBlock {show mac address-table  | in Fa}
$MAC_Table_String2= ($MAC_Table_String.result -split "`n").Trim() |  where {$_ -ne ""}
$t = @()
foreach ($i in $MAC_Table_String2){
$r = ""|Select-Object SW,MAC,Interface
$MAC = ($i.Substring(5,17)).trim()| where {$_ -ne ""}
$Interface = ($i.Substring(35)).trim()| where {$_ -ne ""}
$r.SW = $SwName
$r.MAC = $MAC
$r.Interface = $Interface
$t +=$r
}
Return $t
}
#格式化思科MAC 地址表

Function Format-MacTable
{
param($UserName_and_Password,$SwIp,$SwName)
New-SshSession -ComputerName $SwIp -Credential $UserName_and_Password
$MAC_Table_String = Invoke-SshCommand -Quiet -ComputerName $SwIp -ScriptBlock {dis mac-address | in GE }
$index = $MAC_Table_String.result.IndexOf('E') +5
$MAC_Table_String2= ($MAC_Table_String.result.Substring($index) -split 'Y') |  where {$_ -ne ""}
$t = @()
foreach ($i in $MAC_Table_String2 ){
$r = ""|Select-Object SW,MAC,Interface
$MAC = ($i.substring(0,17)).trim() | where {$_ -ne ""}
$Interface =  ($i.substring(39)).trim() | where {$_ -ne ""}
$r.SW = $SwName
$r.MAC = $MAC
$r.Interface = $Interface
$t +=$r
}
Return $t
}
# 华三交换机mac地址表格式化

$UserName_and_Password = Update-Private -User guest -Password guest
$H3CSwInfoSum = Import-Csv -Path .\swinfo.csv
$CiscoSwInfoSum = Import-Csv -Path .\ciscoswinfo.csv


Write-Warning “开始获取华三交换机MAC地址表”
foreach ($SwInfo in $H3CSwInfoSum){
Write-Warning “开始获取 $($SwInfo.SwName)的Mac地址表”
 Format-MacTable -UserName_and_Password  $UserName_and_Password -SwIp $SwInfo.IpAddress -SwName $SwInfo.SwName | Where-Object {$_.interface -ne "GE1/0/48"} | Export-Csv -Encoding UTF8 -NoTypeInformation -Append $env:USERPROFILE\desktop\mac.csv
 
}

Write-Warning “开始获取思科交换机MAC地址表”
foreach ( $CiscoSwInfo in $CiscoSwInfoSum){
Write-Warning “开始获取 $($CiscoSwInfo.SwName)的Mac地址表”
 $data =  Format-MacTableCisco -UserName_and_Password  $UserName_and_Password -SwIp $CiscoSwInfo.IpAddress -SwName $CiscoSwInfo.SwName | Export-Csv -Encoding UTF8 -NoTypeInformation -Append $env:USERPROFILE\desktop\mac.csv

}