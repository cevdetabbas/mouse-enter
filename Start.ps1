$taskDir = $PSScriptRoot
Start-Process -FilePath "$taskDir\runtime\AutoHotkey64.exe" -ArgumentList ('"' + "$taskDir\MouseEnter.ahk" + '"') -WindowStyle Hidden
