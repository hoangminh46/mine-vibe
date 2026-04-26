# Mine Codex Local Installer

param(
    [string]$ProjectPath = (Get-Location).Path,
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$RepoZip = "https://github.com/hoangminh46/mine-vibe/archive/refs/heads/main.zip"
$ScriptPath = $MyInvocation.MyCommand.Path
$SourceRoot = if ($ScriptPath) { Split-Path -Parent $ScriptPath } else { $null }
$TempRoot = $null

if ($env:MINE_FORCE -eq "1") {
    $Force = $true
}

function Resolve-SourceRoot {
    param(
        [string]$Candidate
    )

    if ($Candidate -and (Test-Path -LiteralPath (Join-Path $Candidate "workflows")) -and (Test-Path -LiteralPath (Join-Path $Candidate "templates"))) {
        return (Resolve-Path -LiteralPath $Candidate).Path
    }

    $script:TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("mine-vibe-" + [System.Guid]::NewGuid().ToString("N"))
    $zipPath = Join-Path $script:TempRoot "mine-vibe.zip"
    $extractPath = Join-Path $script:TempRoot "src"

    New-Item -ItemType Directory -Force -Path $script:TempRoot | Out-Null
    Write-Host "Downloading Mine source..."
    Invoke-WebRequest -Uri $RepoZip -OutFile $zipPath -UseBasicParsing
    Expand-Archive -LiteralPath $zipPath -DestinationPath $extractPath -Force

    $downloadedRoot = Get-ChildItem -LiteralPath $extractPath -Directory | Select-Object -First 1
    if (-not $downloadedRoot) {
        throw "Could not find downloaded Mine source."
    }

    return $downloadedRoot.FullName
}

$SourceRoot = Resolve-SourceRoot -Candidate $SourceRoot
$TargetRoot = (Resolve-Path -LiteralPath $ProjectPath).Path
$MineRoot = Join-Path $TargetRoot ".codex\mine"
$AgentsFile = Join-Path $TargetRoot "AGENTS.md"

function Copy-DirectoryClean {
    param(
        [string]$Source,
        [string]$Target
    )

    if (Test-Path -LiteralPath $Target) {
        if (-not $Force) {
            Write-Host "Keeping existing $Target. Use -Force to replace it." -ForegroundColor Yellow
            return
        }
        Remove-Item -LiteralPath $Target -Recurse -Force
    }

    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Target) | Out-Null
    Copy-Item -LiteralPath $Source -Destination $Target -Recurse -Force
}

Write-Host ""
Write-Host "Mine Codex local setup"
Write-Host "Project: $TargetRoot"
Write-Host ""

New-Item -ItemType Directory -Force -Path $MineRoot | Out-Null

foreach ($dir in @("workflows", "skills", "schemas", "templates")) {
    Copy-DirectoryClean -Source (Join-Path $SourceRoot $dir) -Target (Join-Path $MineRoot $dir)
}

foreach ($file in @("README.md", "VERSION")) {
    Copy-Item -LiteralPath (Join-Path $SourceRoot $file) -Destination (Join-Path $MineRoot $file) -Force
}

$AgentsBlock = @'

<!-- mine-local:start -->
# Mine Local Framework

Use the local Mine framework in `.codex/mine`.

## Workflow Commands

When the user asks for one of these workflows, read and follow the matching file:

- `/brainstorm` -> `.codex/mine/workflows/coding/brainstorm.md`
- `/requirements` -> `.codex/mine/workflows/coding/requirements.md`
- `/plan` -> `.codex/mine/workflows/coding/plan.md`
- `/visualize` -> `.codex/mine/workflows/coding/visualize.md`
- `/code` -> `.codex/mine/workflows/coding/code.md`
- `/test` -> `.codex/mine/workflows/coding/test.md`
- `/debug` -> `.codex/mine/workflows/coding/debug.md`
- `/audit` -> `.codex/mine/workflows/coding/audit.md`
- `/refactor` -> `.codex/mine/workflows/coding/refactor.md`
- `/mock-api` -> `.codex/mine/workflows/coding/mock-api.md`
- `/recap` -> `.codex/mine/workflows/system/recap.md`
- `/save-brain` -> `.codex/mine/workflows/system/save_brain.md`
- `/next` -> `.codex/mine/workflows/system/next.md`
- `/customize` -> `.codex/mine/workflows/system/customize.md`
- `/mine-update` -> `.codex/mine/workflows/system/mine-update.md`

## Memory Templates

Memory templates live in `.codex/mine/templates/`.
Only create project memory files when a workflow explicitly needs them.
<!-- mine-local:end -->
'@

if (Test-Path -LiteralPath $AgentsFile) {
    $AgentsContent = Get-Content -LiteralPath $AgentsFile -Raw
    if ($AgentsContent -notmatch "<!-- mine-local:start -->") {
        Add-Content -LiteralPath $AgentsFile -Value $AgentsBlock
        Write-Host "Updated AGENTS.md"
    } else {
        Write-Host "AGENTS.md already has Mine local instructions"
    }
} else {
    Set-Content -LiteralPath $AgentsFile -Value ($AgentsBlock.TrimStart()) -Encoding UTF8
    Write-Host "Created AGENTS.md"
}

Write-Host ""
Write-Host "Done. Local Mine files are ready in:"
Write-Host "  $MineRoot"

if ($TempRoot -and (Test-Path -LiteralPath $TempRoot)) {
    Remove-Item -LiteralPath $TempRoot -Recurse -Force
}
