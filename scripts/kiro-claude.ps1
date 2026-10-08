# kiro-claude: toggle Claude Code env vars in the CURRENT shell (dot-sourced by the
# kiro-claude function in the PowerShell profile). Run again to switch back.
$RunDir = Join-Path $HOME '.local\bin\.run'

if ($env:ANTHROPIC_BASE_URL) {
    Remove-Item Env:ANTHROPIC_BASE_URL, Env:ANTHROPIC_AUTH_TOKEN, Env:CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY -ErrorAction SilentlyContinue
    Write-Host 'Claude Code -> Anthropic (Kiro proxy OFF)'
    return
}

$KeyFile = Join-Path $RunDir 'api-key'
if (-not (Test-Path $KeyFile)) { Write-Host 'Start the proxy first: kiro-start'; return }

$env:ANTHROPIC_BASE_URL = "http://127.0.0.1:$((Get-Content (Join-Path $RunDir 'port') -Raw).Trim())"
$env:ANTHROPIC_AUTH_TOKEN = (Get-Content $KeyFile -Raw).Trim()
$env:CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY = '1'
Write-Host "Claude Code -> Kiro via $env:ANTHROPIC_BASE_URL. Run 'claude', then /model to pick a model."
