$manifestPath = Join-Path $PSScriptRoot "..\android\app\src\main\AndroidManifest.xml"
$manifestPath = [System.IO.Path]::GetFullPath($manifestPath)

if (-not (Test-Path $manifestPath)) {
    Write-Output "[WARN] AndroidManifest.xml not found at $manifestPath"
    exit 0
}

$content = Get-Content -Raw -Path $manifestPath
if ($content -match "android.permission.INTERNET") {
    Write-Output "[OK] INTERNET permission already present."
    exit 0
}

$updated = $content -replace "<manifest([^>]*)>", "<manifest`$1>`r`n    <uses-permission android:name=`"android.permission.INTERNET`" />"
Set-Content -Path $manifestPath -Value $updated -Encoding UTF8
Write-Output "[OK] Added INTERNET permission to AndroidManifest.xml"
