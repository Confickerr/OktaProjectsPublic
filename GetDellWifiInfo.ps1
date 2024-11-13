# Collect Dell laptop information for WiFi debugging
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

# Wireless Adapter Information
$WiFiAdapters = Get-NetAdapter -Physical | Where-Object { $_.Name -like "*Wi-Fi*" -or $_.Name -like "*Wireless*" }
$WirelessInfo = @()
foreach ($adapter in $WiFiAdapters) {
    $DriverInfo = Get-WmiObject Win32_PnPSignedDriver | Where-Object { $_.DeviceID -eq $adapter.PnPDeviceID }
    $WirelessInfo += [PSCustomObject]@{
        AdapterName = $adapter.Name
        MACAddress = $adapter.MacAddress
        Status = $adapter.Status
        LinkSpeed = $adapter.LinkSpeed
        DriverProvider = $DriverInfo.ProviderName
        DriverVersion = $DriverInfo.DriverVersion
        DriverDate = $DriverInfo.DriverDate
    }
}

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

Write-Output "`n==== Wireless Adapter Information ===="
$WirelessInfo | Format-Table -AutoSize
