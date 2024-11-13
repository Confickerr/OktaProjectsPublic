# Comprehensive System and Network Information Script
# Run as Administrator

# System Information
$SystemInfo = Get-CimInstance -ClassName Win32_OperatingSystem
$OSName = $SystemInfo.Caption
$OSVersion = $SystemInfo.Version
$OSBuild = $SystemInfo.BuildNumber
$ServicePack = $SystemInfo.ServicePackMajorVersion
$OSInstallDate = $SystemInfo.InstallDate
$LastBootUpTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime

# Windows Updates
$Updates = Get-HotFix | Select-Object -Property Description, HotFixID, InstalledOn

# IP Configuration and Network Adapter Details
$IPConfig = Get-NetIPAddress | Where-Object { $_.AddressFamily -eq "IPv4" }
$DNSInfo = Get-DnsClientServerAddress | Select-Object -Property InterfaceAlias, ServerAddresses

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

# Active TCP Connections
$TCPConnections = Get-NetTCPConnection | Where-Object { $_.State -eq "Established" } | 
    Select-Object -Property LocalAddress, LocalPort, RemoteAddress, RemotePort, State

# Recent Network Events (Last 24 hours)
$NetworkEvents = Get-WinEvent -LogName System | Where-Object { $_.TimeCreated -gt (Get-Date).AddHours(-24) -and $_.Id -in 4000..4999 } |
    Select-Object -Property TimeCreated, Id, Message

# Output Results
Write-Output "==== System Information ===="
Write-Output "OS Name: $OSName"
Write-Output "OS Version: $OSVersion"
Write-Output "OS Build: $OSBuild"
Write-Output "Service Pack: $ServicePack"
Write-Output "OS Install Date: $OSInstallDate"
Write-Output "Last Boot Up Time: $LastBootUpTime"

Write-Output "`n==== Installed Windows Updates ===="
$Updates | Format-Table -AutoSize

Write-Output "`n==== IP Configuration ===="
$IPConfig | Format-Table -AutoSize

Write-Output "`n==== DNS Information ===="
$DNSInfo | Format-Table -AutoSize

Write-Output "`n==== Wireless Adapter Details ===="
$WirelessInfo | Format-Table -AutoSize

Write-Output "`n==== Active TCP Connections ===="
$TCPConnections | Format-Table -AutoSize

Write-Output "`n==== Recent Network Events (Last 24 hours) ===="
$NetworkEvents | Format-Table -AutoSize
