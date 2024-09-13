# Проверка наличия прав администратора.
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    # Повышение прав, если необходимо.
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $($MyInvocation.MyCommand.Path)"
    Exit
}

# Работа с IIS.
$serviceName = "W3SVC"
$webAppPools = @("DefaultAppPool", "AppPool2")    # Замените на имена ваших пулов приложений.
$websites = @("Default Web Site", "Website2")     # Замените на имена ваших веб-сайтов.

# Проверка статуса службы IIS.
$status = Get-Service -Name $serviceName

if ($status.Status -ne 'Running') {
    Restart-Service -Name $serviceName -Force
    Write-Output "IIS restarted."
} else {
    Write-Output "IIS already started."
}

# Перезапуск пулов приложений.
foreach ($appPoolName in $webAppPools) {
    $appPool = Get-WebAppPoolState -Name $appPoolName

    if ($appPool.Value -ne 'Started') {
        Start-WebAppPool -Name $appPoolName
        Write-Output "Application Pool '$appPoolName' started."
    } else {
        Write-Output "Application Pool '$appPoolName' already started."
    }
}

# Перезапуск веб-сайтов.
foreach ($websiteName in $websites) {
    $website = Get-Website -Name $websiteName

    if ($website.State -ne 'Started') {
        Start-Website -Name $websiteName
        Write-Output "Website '$websiteName' started."
    } else {
        Write-Output "Website '$websiteName' already started."
    }
}