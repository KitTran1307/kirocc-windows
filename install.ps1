# install.ps1: copy the kiro-* scripts to ~\.local\bin and add the shell functions
# to the PowerShell profile (only once).
$ErrorActionPreference = 'Stop'

$BinDir = Join-Path $HOME '.local\bin'
New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
Copy-Item -Path (Join-Path $PSScriptRoot 'scripts\*.ps1') -Destination $BinDir -Force
Write-Host "Copied kiro-start / kiro-claude / kiro-stop to $BinDir"

$ProfilePath = $PROFILE.CurrentUserAllHosts
# Create the profile only if it is missing; never overwrite an existing one.
if (-not (Test-Path $ProfilePath)) {
    New-Item -ItemType Directory -Force -Path (Split-Path $ProfilePath) | Out-Null
    New-Item -ItemType File -Path $ProfilePath | Out-Null
}
$existing = Get-Content $ProfilePath -Raw -ErrorAction SilentlyContinue
if ($existing -and $existing.Contains('function kiro-start')) {
    Write-Host "Profile already has the kiro-* functions: $ProfilePath"
} else {
    Add-Content -Path $ProfilePath -Value ("`n" + (Get-Content (Join-Path $PSScriptRoot 'profile-snippet.ps1') -Raw))
    Write-Host "Added kiro-* functions to $ProfilePath. Open a new PowerShell window."
}
