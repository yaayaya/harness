Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$utf8 = New-Object System.Text.UTF8Encoding($false)
$scriptPath = (Resolve-Path (Join-Path $PSScriptRoot "..\skills\harness-packager\scripts\harness_packager.ps1")).Path
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("harness-packager-test-" + [Guid]::NewGuid().ToString("N"))

function Write-TestFile {
    param([Parameter(Mandatory = $true)][string]$Path, [Parameter(Mandatory = $true)][string]$Content)
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Path) | Out-Null
    [System.IO.File]::WriteAllText($Path, $Content, $utf8)
}

function Assert-True {
    param([Parameter(Mandatory = $true)][bool]$Condition, [Parameter(Mandatory = $true)][string]$Message)
    if (-not $Condition) { throw "Assertion failed: $Message" }
}

function Invoke-Packager {
    param([Parameter(Mandatory = $true)][string[]]$Arguments)
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousPreference
    }
    return [pscustomobject]@{ ExitCode = $exitCode; Output = @($output) }
}

New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
try {
    $source = Join-Path $tempRoot "source"
    $target = Join-Path $tempRoot "target"
    $rollbackTarget = Join-Path $tempRoot "rollback-target"
    $packages = Join-Path $tempRoot "packages"

    Write-TestFile (Join-Path $source "AGENTS.md") @"
# 來源規則

## Harness：測試團隊

使用測試團隊完成工作。
"@
    Write-TestFile (Join-Path $source ".codex\config.toml") @"
[agents]
max_threads = 4
max_depth = 1

[features]
hooks = true
"@
    Write-TestFile (Join-Path $source ".codex\agents\tester.toml") @"
name = "tester"
description = "測試代理人"
developer_instructions = """執行測試。"""
"@
    Write-TestFile (Join-Path $source ".codex\agents\legacy.toml") @"
name = "legacy"
description = "即將移除的代理人"
developer_instructions = """只供更新測試。"""
"@
    Write-TestFile (Join-Path $source ".agents\skills\test-orchestrator\SKILL.md") @"
---
name: test-orchestrator
description: 協調測試團隊。
---

# Test Orchestrator
"@
    Write-TestFile (Join-Path $source "scripts\validate-harness.mjs") "console.log('ok');"
    Write-TestFile (Join-Path $source "tests\harness-scenarios.json") "[]"

    $defaultPack = Invoke-Packager @("-Action", "Pack", "-Repo", $source)
    Assert-True ($defaultPack.ExitCode -eq 0) "零設定 Pack 應成功：$($defaultPack.Output -join [Environment]::NewLine)"
    Assert-True (Test-Path -LiteralPath (Join-Path $source "dist\test.harness\harness.json") -PathType Leaf) "零設定 Pack 應由 orchestrator 推導名稱與預設輸出位置"

    $pack = Invoke-Packager @("-Action", "Pack", "-Repo", $source, "-Output", $packages, "-Name", "test-team")
    Assert-True ($pack.ExitCode -eq 0) "Pack 應成功：$($pack.Output -join [Environment]::NewLine)"
    $packagePath = Join-Path $packages "test-team.harness"
    Assert-True (Test-Path -LiteralPath (Join-Path $packagePath "harness.json") -PathType Leaf) "應產生 harness.json"
    $packagedConfig = [System.IO.File]::ReadAllText((Join-Path $packagePath "payload\.codex\config.toml"))
    Assert-True ($packagedConfig.Contains("[agents]")) "套件應包含 agents config"
    Assert-True (-not $packagedConfig.Contains("[features]")) "套件不應帶入非 Harness config"

    $verify = Invoke-Packager @("-Action", "Verify", "-Package", $packagePath)
    Assert-True ($verify.ExitCode -eq 0) "Verify 應成功：$($verify.Output -join [Environment]::NewLine)"

    Write-TestFile (Join-Path $target "AGENTS.md") "# 目標規則`r`n`r`n保留此內容。`r`n"
    Write-TestFile (Join-Path $target ".codex\config.toml") @"
[features]
hooks = true

[agents]
max_threads = 2
"@
    Write-TestFile (Join-Path $target ".codex\agents\unrelated.toml") "name = 'unrelated'"

    $install = Invoke-Packager @("-Action", "Install", "-Repo", $target, "-Package", $packagePath)
    Assert-True ($install.ExitCode -eq 0) "首次 Install 應成功：$($install.Output -join [Environment]::NewLine)"
    Assert-True (($install.Output -join "`n") -match "INSTALLED") "首次安裝應回報 INSTALLED"
    $targetAgents = [System.IO.File]::ReadAllText((Join-Path $target "AGENTS.md"))
    Assert-True ($targetAgents.Contains("保留此內容")) "應保留目標 AGENTS 內容"
    Assert-True ($targetAgents.Contains("<!-- harness-package:test-team:start -->")) "應加入 managed block"
    $targetConfig = [System.IO.File]::ReadAllText((Join-Path $target ".codex\config.toml"))
    Assert-True ($targetConfig.Contains("[features]")) "應保留目標 config 其他區段"
    Assert-True ($targetConfig.Contains("max_threads = 4")) "應更新 agents 設定"
    Assert-True ($targetConfig.Contains("max_depth = 1")) "應加入 agents 設定"
    Assert-True (Test-Path -LiteralPath (Join-Path $target ".codex\agents\unrelated.toml")) "應保留非受管 agent"
    Assert-True (Test-Path -LiteralPath (Join-Path $target ".harness\installed\test-team.json")) "應建立 receipt"

    Remove-Item -LiteralPath (Join-Path $source ".codex\agents\legacy.toml") -Force
    Write-TestFile (Join-Path $source ".codex\agents\tester.toml") @"
name = "tester"
description = "更新後的測試代理人"
developer_instructions = """執行更新後測試。"""
"@
    $repack = Invoke-Packager @("-Action", "Pack", "-Repo", $source, "-Output", $packages, "-Name", "test-team")
    Assert-True ($repack.ExitCode -eq 0) "重新 Pack 應成功"
    $update = Invoke-Packager @("-Action", "Install", "-Repo", $target, "-Package", $packagePath)
    Assert-True ($update.ExitCode -eq 0) "更新 Install 應成功：$($update.Output -join [Environment]::NewLine)"
    Assert-True (($update.Output -join "`n") -match "UPDATED") "第二次安裝應回報 UPDATED"
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $target ".codex\agents\legacy.toml"))) "應移除新版不再宣告的舊受管檔案"
    Assert-True (([System.IO.File]::ReadAllText((Join-Path $target ".codex\agents\tester.toml"))).Contains("更新後")) "應套用新版 agent"
    Assert-True (Test-Path -LiteralPath (Join-Path $target ".codex\agents\unrelated.toml")) "更新後仍應保留非受管 agent"

    Write-TestFile (Join-Path $rollbackTarget "AGENTS.md") "# 不可變更的規則`r`n"
    Write-TestFile (Join-Path $rollbackTarget ".codex\config.toml") @"
[agents]
max_threads = 1
max_threads = 2
"@
    Write-TestFile (Join-Path $rollbackTarget ".codex\agents\tester.toml") "original"
    $rollback = Invoke-Packager @("-Action", "Install", "-Repo", $rollbackTarget, "-Package", $packagePath)
    Assert-True ($rollback.ExitCode -ne 0) "重複 TOML key 應使安裝失敗"
    Assert-True (([System.IO.File]::ReadAllText((Join-Path $rollbackTarget ".codex\agents\tester.toml"))) -eq "original") "失敗時應還原已覆寫 agent"
    Assert-True (([System.IO.File]::ReadAllText((Join-Path $rollbackTarget "AGENTS.md"))) -eq "# 不可變更的規則`r`n") "失敗時應還原 AGENTS"
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $rollbackTarget ".harness\installed\test-team.json"))) "失敗時不應留下 receipt"

    $manifestPath = Join-Path $packagePath "harness.json"
    $manifest = [System.IO.File]::ReadAllText($manifestPath) | ConvertFrom-Json
    $manifest.name = "../unsafe"
    [System.IO.File]::WriteAllText($manifestPath, ($manifest | ConvertTo-Json -Depth 8), $utf8)
    $unsafeName = Invoke-Packager @("-Action", "Verify", "-Package", $packagePath)
    Assert-True ($unsafeName.ExitCode -ne 0) "不安全套件名稱應被拒絕"
    $manifest.name = "test-team"
    [System.IO.File]::WriteAllText($manifestPath, ($manifest | ConvertTo-Json -Depth 8), $utf8)

    Add-Content -LiteralPath (Join-Path $packagePath "payload\.agents\skills\test-orchestrator\SKILL.md") -Value "corrupted"
    $corrupt = Invoke-Packager @("-Action", "Verify", "-Package", $packagePath)
    Assert-True ($corrupt.ExitCode -ne 0) "損壞 payload 應被拒絕"

    Write-Output "Harness Packager tests passed: zero-config and custom pack, verify, install, update, rollback, unsafe-name and corruption rejection"
}
finally {
    $tempFull = [System.IO.Path]::GetFullPath($tempRoot)
    $systemTemp = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
    if ($tempFull.StartsWith($systemTemp, [System.StringComparison]::OrdinalIgnoreCase) -and (Split-Path -Leaf $tempFull) -like "harness-packager-test-*") {
        Remove-Item -LiteralPath $tempFull -Recurse -Force -ErrorAction SilentlyContinue
    }
}
