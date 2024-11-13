# Expanded Network Information Script
# Run as Administrator

# System Information
$SystemInfo = Get-CimInstance -ClassName Win32_OperatingSystem
$OSName = $SystemInfo.Caption
$OSVersion = $SystemInfo.Version
$OSBuild = $SystemInfo.BuildNumber

# IP Configuration and Network Adapter Details
$IPConfig = Get-NetIPAddress | Where-Object { $_.AddressFamily -eq "IPv4" }
$DNSInfo = Get-DnsClientServerAddress | Select-Object -Property InterfaceAlias, ServerAddresses

# Wireless Adapter Signal Quality and Network Name
$WiFiAdapters = Get-NetAdapter -Physical | Where-Object { $_.Name -like "*Wi-Fi*" -or $_.Name -like "*Wireless*" }
$WiFiDetails = @()
foreach ($adapter in $WiFiAdapters) {
    $NetStats = Get-NetAdapterStatistics -Name $adapter.Name
    $WiFiNetwork = Get-NetConnectionProfile | Where-Object { $_.InterfaceAlias -eq $adapter.Name }
    $WiFiDetails += [PSCustomObject]@{
        AdapterName = $adapter.Name
        MACAddress = $adapter.MacAddress
        Status = $adapter.Status
        LinkSpeed = $adapter.LinkSpeed
        SignalQuality = $NetStats.ReceiveQuality
        NetworkName = $WiFiNetwork.Name
    }
}

# Active TCP Connections
$TCPConnections = Get-NetTCPConnection | Where-Object { $_.State -eq "Established" } | 
    Select-Object -Property LocalAddress, LocalPort, RemoteAddress, RemotePort, State

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

# Recent Network Events (Last 24 hours)
$NetworkEvents = Get-WinEvent -LogName System | Where-Object { $_.TimeCreated -gt (Get-Date).AddHours(-24) -and $_.Id -in 4000..4999 } |
    Select-Object -Property TimeCreated, Id, Message

# Output Results
Write-Output "==== System Information ===="
Write-Output "OS Name: $OSName"
Write-Output "OS Version: $OSVersion"
Write-Output "OS Build: $OSBuild"
Write-Output "`n==== IP Configuration ===="
$IPConfig | Format-Table -AutoSize

Write-Output "`n==== DNS Information ===="
$DNSInfo | Format-Table -AutoSize

Write-Output "`n==== Wireless Adapter Details ===="
$WiFiDetails | Format-Table -AutoSize

Write-Output "`n==== Active TCP Connections ===="
$TCPConnections | Format-Table -AutoSize

Write-Output "`n==== Network Adapter Driver Information ===="
$AdapterDriverInfo | Format-Table -AutoSize

Write-Output "`n==== Recent Network Events (Last 24 hours) ===="
$NetworkEvents | Format-Table -AutoSize
