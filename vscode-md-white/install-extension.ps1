#!/usr/bin/env pwsh
# Install the "Markdown White Preview" extension into ALL local VS Code profiles.
#
# Why per-profile: VS Code installs extensions into a global folder, but each
# profile decides which are *enabled*. `code --install-extension` only targets
# the default profile, so a custom profile (e.g. "ookami") won't see it unless
# installed with `--profile <name>`. This script loops every profile.
#
# Settings Sync does NOT carry this extension to other machines (it's not on the
# Marketplace), so run this once per machine after cloning dotfiles.
#
# Usage:
#   ./install-extension.ps1            # build vsix if missing, install to all profiles
#   ./install-extension.ps1 -Rebuild  # force rebuild the vsix first (after CSS edits)

[CmdletBinding()]
param([switch]$Rebuild)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Vsix = Join-Path $ScriptDir "md-white-preview-1.0.0.vsix"

if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    Write-Error "'code' CLI not found on PATH. In VS Code: Command Palette -> 'Shell Command: Install code command in PATH'."
    exit 1
}

if ($Rebuild -or -not (Test-Path $Vsix)) {
    if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
        Write-Error "vsix missing and npx not available to build it. Install Node.js, or copy an existing vsix here."
        exit 1
    }
    Write-Host "building vsix..."
    Push-Location $ScriptDir
    try { npx --yes @vscode/vsce package --allow-missing-repository --out (Split-Path $Vsix -Leaf) }
    finally { Pop-Location }
}

# Resolve VS Code User dir per OS, read profile names from globalStorage.
$userDir =
    if ($IsWindows -or $env:OS -eq "Windows_NT") { Join-Path $env:APPDATA "Code\User" }
    elseif ($IsMacOS)                            { Join-Path $HOME "Library/Application Support/Code/User" }
    else                                         { Join-Path $HOME ".config/Code/User" }

$profiles = @()  # empty string sentinel handled below; start with default
$gs = Join-Path $userDir "globalStorage/storage.json"
if (Test-Path $gs) {
    $names = (Get-Content $gs -Raw | ConvertFrom-Json).userDataProfiles.name
    if ($names) { $profiles += @($names) }
}

# Default profile first (no --profile flag), then every named profile.
Write-Host "installing into default profile"
code --install-extension $Vsix --force

foreach ($p in $profiles) {
    if (-not $p) { continue }
    Write-Host "installing into profile: $p"
    code --profile $p --install-extension $Vsix --force
}

Write-Host "done. Reload VS Code (Command Palette -> Reload Window)."
