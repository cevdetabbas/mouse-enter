$expected = Join-Path $PSScriptRoot 'runtime\AutoHotkey64.exe'
Get-CimInstance Win32_Process -Filter "Name='AutoHotkey64.exe'" | Where-Object { $_.ExecutablePath -eq $expected } | ForEach-Object { Stop-Process -Id $_.ProcessId }
