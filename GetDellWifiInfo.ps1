# Comprehensive System and Network Information Script with Output to File on User's Desktop
# Run as Administrator

# Define output file path on the current user's desktop
$outputFile = "$env:USERPROFILE\Desktop\Network_Debug_Info.txt"

# Create or overwrite the output file
"`n==== System and Network Information Report ====" | Out-File -FilePath $outputFile -Force
"Report Generated on: $(Get-Date)" | Out-File -FilePath $outputFile -Append

# System Information
$SystemInfo = Get-CimInstance -ClassName Win32_OperatingSystem
$OSName = $SystemInfo.Caption
$OSVersion = $SystemInfo.Version
$OSBuild = $SystemInfo.BuildNumber
$ServicePack = $SystemInfo.ServicePackMajorVersion
$OSInstallDate = $SystemInfo.InstallDate
$LastBootUpTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime

# Write System Information to Output File
"`n==== System Information ====" | Out-File -FilePath $outputFile -Append
"OS Name: $OSName" | Out-File -FilePath $outputFile -Append
"OS Version: $OSVersion" | Out-File -FilePath $outputFile -Append
"OS Build: $OSBuild" | Out-File -FilePath $outputFile -Append
"Service Pack: $ServicePack" | Out-File -FilePath $outputFile -Append
"OS Install Date: $OSInstallDate" | Out-File -FilePath $outputFile -Append
"Last Boot Up Time: $LastBootUpTime" | Out-File -FilePath $outputFile -Append

# Windows Updates
$Updates = Get-HotFix | Select-Object -Property Description, HotFixID, InstalledOn
"`n==== Installed Windows Updates ====" | Out-File -FilePath $outputFile -Append
$Updates | Format-Table -AutoSize | Out-File -FilePath $outputFile -Append

# IP Configuration and DNS Information
$IPConfig = Get-NetIPAddress | Where-Object { $_.AddressFamily -eq "IPv4" }
$DNSInfo = Get-DnsClientServerAddress | Select-Object -Property InterfaceAlias, ServerAddresses
"`n==== IP Configuration ====" | Out-File -FilePath $outputFile -Append
$IPConfig | Format-Table -AutoSize | Out-File -FilePath $outputFile -Append
"`n==== DNS Information ====" | Out-File -FilePath $outputFile -Append
$DNSInfo | Format-Table -AutoSize | Out-File -FilePath $outputFile -Append

# Wireless Adapter Details
$WiFiAdapters = Get-NetAdapter -Physical | Where-Object { $_.Name -like "*Wi-Fi*" -or $_.Name -like "*Wireless*" }
$WirelessInfo = @()
foreach ($adapter in $WiFiAdapters) {
    $NetStats = Get-NetAdapterStatistics -Name $adapter.Name
    $WiFiNetwork = Get-NetConnectionProfile | Where-Object { $_.InterfaceAlias -eq $adapter.Name }
    $DriverInfo = Get-WmiObject Win32_PnPSignedDriver | Where-Object { $_.DeviceID -eq $adapter.PnPDeviceID }
    $WirelessInfo += [PSCustomObject]@{
        AdapterName = $adapter.Name
        MACAddress = $adapter.MacAddress
        Status = $adapter.Status
        LinkSpeed = $adapter.LinkSpeed
        SignalQuality = $NetStats.ReceiveQuality
        NetworkName = $WiFiNetwork.Name
        DriverProvider = $DriverInfo.ProviderName
        DriverVersion = $DriverInfo.DriverVersion
        DriverDate = $DriverInfo.DriverDate
    }
}
"`n==== Wireless Adapter Details ====" | Out-File -FilePath $outputFile -Append
$WirelessInfo | Format-Table -AutoSize | Out-File -FilePath $outputFile -Append

# Active TCP Connections
$TCPConnections = Get-NetTCPConnection | Where-Object { $_.State -eq "Established" } | 
    Select-Object -Property LocalAddress, LocalPort, RemoteAddress, RemotePort, State
"`n==== Active TCP Connections ====" | Out-File -FilePath $outputFile -Append
$TCPConnections | Format-Table -AutoSize | Out-File -FilePath $outputFile -Append

# Network Adapter Driver Information
$DriverInfo = Get-WmiObject Win32_PnPSignedDriver | Where-Object { $_.DeviceClass -eq "Net" }
$AdapterDriverInfo = @()
foreach ($adapter in $WiFiAdapters) {
    $Driver = $DriverInfo | Where-Object { $_.DeviceID -eq $adapter.PnPDeviceID }
    $AdapterDriverInfo += [PSCustomObject]@{
        AdapterName = $adapter.Name
        DriverProvider = $Driver.ProviderName
        DriverVersion = $Driver.DriverVersion
        DriverDate = $Driver.DriverDate
    }
}
"`n==== Network Adapter Driver Information ====" | Out-File -FilePath $outputFile -Append
$AdapterDriverInfo | Format-Table -AutoSize | Out-File -FilePath $outputFile -Append

# Recent Network Events (Last 168 hours)
$NetworkEvents = Get-WinEvent -LogName System | Where-Object { $_.TimeCreated -gt (Get-Date).AddHours(-168) -and $_.Id -in 4000..4999 } |
    Select-Object -Property TimeCreated, Id, Message
"`n==== Recent Network Events (Last 24 hours) ====" | Out-File -FilePath $outputFile -Append
$NetworkEvents | Format-Table -AutoSize | Out-File -FilePath $outputFile -Append

# Completion message
Write-Output "Data collection complete. Results saved to: $outputFile"
