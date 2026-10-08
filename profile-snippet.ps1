# Claude Code via Kiro (kirocc proxy)
# Append to your PowerShell profile ($PROFILE), after copying scripts\*.ps1 to ~\.local\bin\.
function kiro-start  { & "$HOME\.local\bin\kiro-start.ps1" }
function kiro-stop   { & "$HOME\.local\bin\kiro-stop.ps1" }
# Dot-sourced so the env vars land in the current shell.
function kiro-claude { . "$HOME\.local\bin\kiro-claude.ps1" }
