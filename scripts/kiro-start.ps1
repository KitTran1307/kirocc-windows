# kiro-start: start the kirocc proxy (Claude Code -> Kiro) in the background.
# Windows port of the kirocc setup guide. State lives in ~\.local\bin\.run\.
$ErrorActionPreference = 'Stop'

$RunDir  = Join-Path $HOME '.local\bin\.run'
$PidFile = Join-Path $RunDir 'kirocc.pid'
$Port    = if ($env:KIROCC_PORT) { $env:KIROCC_PORT } else { '3456' }
$Bin     = if ($env:KIROCC_BIN) { $env:KIROCC_BIN } else { Join-Path $HOME 'kirocc\kirocc.exe' }
$Region  = if ($env:KIRO_API_REGION) { $env:KIRO_API_REGION } else { 'us-east-1' }
$LogFile = Join-Path $RunDir 'kirocc.log'

New-Item -ItemType Directory -Force -Path $RunDir | Out-Null

if (-not (Test-Path $Bin)) { throw "kirocc binary not found at $Bin (build it or set KIROCC_BIN)" }

if (Test-Path $PidFile) {
    $old = Get-Process -Id (Get-Content $PidFile) -ErrorAction SilentlyContinue
    if ($old -and $old.ProcessName -eq 'kirocc') { Write-Host "kirocc already running (pid $($old.Id), port $(Get-Content (Join-Path $RunDir 'port')))"; return }
}

# Random token, created once and then reused, so Claude Desktop (which stores the
# key in its own settings) keeps working across proxy restarts. Delete the
# api-key file to rotate it (then update Claude Desktop's Gateway API key).
$KeyFile = Join-Path $RunDir 'api-key'
if ((Test-Path $KeyFile) -and (Get-Content $KeyFile -Raw).Trim()) {
    $Token = (Get-Content $KeyFile -Raw).Trim()
} else {
    $bytes = New-Object byte[] 32
    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
    $Token = -join ($bytes | ForEach-Object { '{0:x2}' -f $_ })
    Set-Content -Path $KeyFile -Value $Token -NoNewline
}
Set-Content -Path (Join-Path $RunDir 'port') -Value $Port -NoNewline

$procArgs = @('-host', '127.0.0.1', '-port', $Port,
              '-kiro-api-region', $Region, '-log-file', $LogFile)

# Secrets go through the child's environment, not its command line, so other
# processes cannot read them from the process list.
$env:KIROCC_API_KEY = $Token

# Optional web search: put an Exa API key in ~\.local\bin\.run\exa-key
$ExaKeyFile = Join-Path $RunDir 'exa-key'
if (Test-Path $ExaKeyFile) {
    $procArgs += @('-web-search-provider', 'exa')
    $env:KIROCC_WEB_SEARCH_API_KEY = (Get-Content $ExaKeyFile -Raw).Trim()
}

try {
    $p = Start-Process -FilePath $Bin -ArgumentList $procArgs -WindowStyle Hidden -PassThru
} finally {
    Remove-Item Env:KIROCC_API_KEY, Env:KIROCC_WEB_SEARCH_API_KEY -ErrorAction SilentlyContinue
}
Set-Content -Path $PidFile -Value $p.Id -NoNewline

foreach ($i in 1..20) {
    Start-Sleep -Milliseconds 500
    if ($p.HasExited) { throw "kirocc exited during startup - see $LogFile (usually: run 'kiro-cli login' or set KIRO_API_KEY)" }
    try {
        Invoke-RestMethod "http://127.0.0.1:$Port/health" -TimeoutSec 2 | Out-Null
        Write-Host "kirocc running on http://127.0.0.1:$Port (pid $($p.Id)). Next: kiro-claude"
        return
    } catch { }
}
throw "kirocc did not answer /health within 10s - see $LogFile"
