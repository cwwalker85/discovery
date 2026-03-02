$services = @("spooler","W32Time")
foreach ($service in $services) {

    $svc = Get-Service -Name $service
    
    if ($svc.Status -ne "Running") {
        Start-Service -Name $service
        Write-Host "$service was stopped and has been restarted."
    } else {
        Write-Host "$service is running."
    }
}
