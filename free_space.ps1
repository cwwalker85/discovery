$servers = @("")
$threshold = 20
foreach ($server in $servers) {
    try {
        
        Get-WmiObject Win32_LogicalDisk -ComputerName $server -Filter "DriveType=3" |
        
        ForEach-Object {
            $freePercent = [math]::Round(($_.FreeSpace / $_.Size) * 100, 2)
            if ($freePercent -lt $threshold) {
                Write-Output "$server - Drive $($_.DeviceID) is low on space: $freePercent% free"
            }
        }
    
    } catch {
        Write-Output "$server is unreachable."
        continue
    }
    
}
