

function port_scan {
    param (
        [string]$ip
    )

    $ports = 1..2

    $pool = [runspacefactory]::CreateRunspacePool(1, [System.Environment]::ProcessorCount)
    $pool.Open()
    $jobs = @()

    foreach ($port in $ports) {
        $instance = [powershell]::Create()
        $instance.RunspacePool = $pool
        $instance.AddScript({
            param(
                [string]$address, 
                [int]$port
            )

            $client = New-Object System.Net.Sockets.TcpClient

            try {
                $client.Connect($address, $port)
                return "Port $port open"
            } catch {}
            finally {
                $client.Close()
            }
        }).AddArgument($ip).AddArgument($ports)

        $jobs += [pscustomobject]@{
            Port = $port
            Handle = $instance.BeginInvoke()
            PowerShell = $instance
        }
    }

    $open = foreach ($job in $jobs) {
        $result = $job.PowerShell.EndInvoke($job.Handle)

        if ($result) {
            Write-Host $result
        }
    }

    $pool.Close()
    $open
}

port_scan -ip "192.168.1.13"
