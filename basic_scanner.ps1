function Aliveports {
    param (
        [string]$ip  
    )
    $ports = 1..1024
    # $results = [System.Collections.Concurrent.ConcurrentBag[string]]::new()

    Write-Host ""
    Write-Host "STARTING PORT SCAN"
    Write-Host "------------------"

    $ports | ForEach-Object -Parallel {
        $tcp = New-Object System.Net.Sockets.TcpClient
        try {
            $tcp.Connect($Using:ip, $_)
            Write-Host "$Using:ip\:$_ - is open" -ForegroundColor Green
        }
        catch {}
        finally {
            $tcp.Close()
        }
    }
}

$funcDefinition = ${function:Aliveports}.ToString()

function Alivehosts {
    Write-Host "STARTING HOST SCAN"
    Write-Host "------------------"

    $subnet = "192.168.1"
    $ips = 1..254 | ForEach-Object { "$subnet.$_" }

    #$ips | ForEach-Object -Parallel {
    $ips | ForEach-Object {

        # ${function:Aliveports} = $using:funcDefinition
        
        if (Test-Connection -Quiet -Count 1 -TimeoutSeconds 1 -ComputerName $_) {
            try { 
                $hostname = ([System.Net.Dns]::GetHostEntry($_)).HostName 
            } 
            catch { 
                $hostname = "Unknown" 
            }
            
            Write-Host "$_ - $hostname is alive" -ForegroundColor Green 

            Aliveports -ip $_
        } 
    } # -ThrottleLimit 50
}

Alivehosts
