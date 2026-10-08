# kiro-stop: stop the kirocc proxy started by kiro-start.
$RunDir  = Join-Path $HOME '.local\bin\.run'
$PidFile = Join-Path $RunDir 'kirocc.pid'

if (-not (Test-Path $PidFile)) { Write-Host 'kirocc is not running'; return }
$p = Get-Process -Id (Get-Content $PidFile) -ErrorAction SilentlyContinue
if ($p -and $p.ProcessName -eq 'kirocc') { Stop-Process -Id $p.Id; Write-Host "kirocc stopped (pid $($p.Id))" }
else { Write-Host 'kirocc was not running' }
# Keep api-key: Claude Desktop stores it, and kiro-start reuses it.
Remove-Item $PidFile -ErrorAction SilentlyContinue
