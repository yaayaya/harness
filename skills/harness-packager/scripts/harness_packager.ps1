[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Pack", "Install", "Verify")]
    [string]$Action,

    [string]$Repo = (Get-Location).Path,
    [string]$Package,
    [string]$Output,
    [string]$Name
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$script:Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[Console]::OutputEncoding = $script:Utf8NoBom

function Resolve-FullPath {
    param([Parameter(Mandatory = $true)][string]$Path, [string]$Base = (Get-Location).Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $Base $Path))
}

function Test-PathInside {
    param([Parameter(Mandatory = $true)][string]$Root, [Parameter(Mandatory = $true)][string]$Candidate)

    $rootFull = [System.IO.Path]::GetFullPath($Root).TrimEnd("\", "/")
    $candidateFull = [System.IO.Path]::GetFullPath($Candidate)
    if ($candidateFull.Equals($rootFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $true
    }
    $prefix = $rootFull + [System.IO.Path]::DirectorySeparatorChar
    return $candidateFull.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)
}

function Get-RelativePath {
    param([Parameter(Mandatory = $true)][string]$Root, [Parameter(Mandatory = $true)][string]$Path)

    $rootFull = [System.IO.Path]::GetFullPath($Root).TrimEnd("\", "/") + [System.IO.Path]::DirectorySeparatorChar
    $pathFull = [System.IO.Path]::GetFullPath($Path)
    $rootUri = New-Object System.Uri($rootFull)
    $pathUri = New-Object System.Uri($pathFull)
    return [System.Uri]::UnescapeDataString($rootUri.MakeRelativeUri($pathUri).ToString()).Replace("/", [System.IO.Path]::DirectorySeparatorChar)
}

function Write-Utf8File {
    param([Parameter(Mandatory = $true)][string]$Path, [AllowEmptyString()][string]$Content)

    $parent = Split-Path -Parent $Path
    if ($parent) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    [System.IO.File]::WriteAllText($Path, $Content, $script:Utf8NoBom)
}

function Get-Sha256Text {
    param([Parameter(Mandatory = $true)][string]$Text)

    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = $script:Utf8NoBom.GetBytes($Text)
        return ([System.BitConverter]::ToString($sha.ComputeHash($bytes))).Replace("-", "").ToLowerInvariant()
    }
    finally {
        $sha.Dispose()
    }
}

function ConvertTo-PackageName {
    param([Parameter(Mandatory = $true)][string]$Value)

    $normalized = $Value.Trim().ToLowerInvariant()
    $normalized = [System.Text.RegularExpressions.Regex]::Replace($normalized, "[^\p{L}\p{Nd}]+", "-")
    $normalized = $normalized.Trim("-")
    if ([string]::IsNullOrWhiteSpace($normalized)) {
        throw "無法從名稱產生套件識別碼：$Value"
    }
    return $normalized
}

function Test-ReparsePoint {
    param([Parameter(Mandatory = $true)][System.IO.FileSystemInfo]$Item)

    return (($Item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0)
}

function Assert-NoReparsePoints {
    param([Parameter(Mandatory = $true)][string]$Path)

    $item = Get-Item -LiteralPath $Path -Force
    if (Test-ReparsePoint $item) {
        throw "不允許 symlink、junction 或 reparse point：$Path"
    }
    if ($item.PSIsContainer) {
        foreach ($child in Get-ChildItem -LiteralPath $Path -Recurse -Force) {
            if (Test-ReparsePoint $child) {
                throw "不允許 symlink、junction 或 reparse point：$($child.FullName)"
            }
        }
    }
}

function Assert-NoReparseInPath {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string]$Candidate
    )

    if (-not (Test-PathInside $Root $Candidate)) {
        throw "路徑超出允許根目錄：$Candidate"
    }
    $rootFull = [System.IO.Path]::GetFullPath($Root)
    $candidateFull = [System.IO.Path]::GetFullPath($Candidate)
    $rootItem = Get-Item -LiteralPath $rootFull -Force
    if (Test-ReparsePoint $rootItem) {
        throw "允許根目錄本身不可為 symlink、junction 或 reparse point：$rootFull"
    }
    $relative = Get-RelativePath $rootFull $candidateFull
    $current = $rootFull
    foreach ($segment in $relative.Split([System.IO.Path]::DirectorySeparatorChar)) {
        if ([string]::IsNullOrWhiteSpace($segment) -or $segment -eq ".") { continue }
        $current = Join-Path $current $segment
        if (Test-Path -LiteralPath $current) {
            $item = Get-Item -LiteralPath $current -Force
            if (Test-ReparsePoint $item) {
                throw "目標路徑不允許 symlink、junction 或 reparse point：$current"
            }
        }
    }
}

function Assert-NotSensitiveFile {
    param([Parameter(Mandatory = $true)][string]$Path)

    $leaf = [System.IO.Path]::GetFileName($Path).ToLowerInvariant()
    $extension = [System.IO.Path]::GetExtension($leaf).ToLowerInvariant()
    $exact = @(
        ".env", ".npmrc", ".pypirc", "id_rsa", "id_ed25519",
        "credentials.json", "credential.json", "secrets.json", "secret.json"
    )
    if ($exact -contains $leaf -or $leaf.StartsWith(".env.") -or @(".pem", ".key", ".p12", ".pfx") -contains $extension) {
        throw "疑似秘密或憑證檔，不允許打包：$Path"
    }
}

function Test-SafeRelativePath {
    param([Parameter(Mandatory = $true)][string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path) -or [System.IO.Path]::IsPathRooted($Path) -or $Path.Contains(":")) {
        return $false
    }
    $normalized = $Path.Replace("\", "/")
    $segments = @($normalized.Split("/"))
    if ($segments.Count -eq 0) {
        return $false
    }
    foreach ($segment in $segments) {
        if ([string]::IsNullOrWhiteSpace($segment) -or $segment -eq "." -or $segment -eq "..") {
            return $false
        }
    }
    return $true
}

function Get-ExpectedMode {
    param([Parameter(Mandatory = $true)][string]$RelativePath)

    $path = $RelativePath.Replace("\", "/")
    if ($path -eq "AGENTS.md") { return "managed-markdown" }
    if ($path -eq ".codex/config.toml") { return "merge-toml" }
    if ($path -match "^\.codex/agents/.+" -or $path -match "^\.agents/skills/.+") { return "replace" }
    if ($path -match "^scripts/validate[-_]harness[^/]*$") { return "replace" }
    if ($path -match "^tests/(?:.+/)?harness[-_][^/]+$") { return "replace" }
    return $null
}

function Get-AgentsTomlSection {
    param([Parameter(Mandatory = $true)][string]$Path)

    $lines = [System.IO.File]::ReadAllLines($Path)
    $capturing = $false
    $captured = New-Object System.Collections.Generic.List[string]
    foreach ($line in $lines) {
        $heading = [System.Text.RegularExpressions.Regex]::Match($line, "^\s*\[([^\[\]]+)\]\s*(?:#.*)?$")
        if ($heading.Success) {
            if ($capturing) { break }
            if ($heading.Groups[1].Value.Trim() -eq "agents") {
                $capturing = $true
                $captured.Add("[agents]")
            }
            continue
        }
        if ($capturing) {
            $captured.Add($line)
        }
    }
    if (-not $capturing) { return $null }
    while ($captured.Count -gt 1 -and [string]::IsNullOrWhiteSpace($captured[$captured.Count - 1])) {
        $captured.RemoveAt($captured.Count - 1)
    }
    return (($captured -join [Environment]::NewLine) + [Environment]::NewLine)
}

function Get-DisplayName {
    param([Parameter(Mandatory = $true)][string]$RepoPath)

    $agentsPath = Join-Path $RepoPath "AGENTS.md"
    if (Test-Path -LiteralPath $agentsPath -PathType Leaf) {
        $text = [System.IO.File]::ReadAllText($agentsPath)
        $match = [System.Text.RegularExpressions.Regex]::Match($text, "(?m)^##\s+Harness[：:]\s*(.+?)\s*$")
        if ($match.Success) {
            return $match.Groups[1].Value.Trim()
        }
    }
    return (Split-Path -Leaf $RepoPath)
}

function Get-DefaultPackageName {
    param([Parameter(Mandatory = $true)][string]$RepoPath)

    $skillsRoot = Join-Path $RepoPath ".agents\skills"
    if (Test-Path -LiteralPath $skillsRoot -PathType Container) {
        $orchestrators = @(Get-ChildItem -LiteralPath $skillsRoot -Directory | Where-Object { $_.Name -like "*-orchestrator" })
        if ($orchestrators.Count -eq 1) {
            return ConvertTo-PackageName ($orchestrators[0].Name -replace "-orchestrator$", "")
        }
    }
    return ConvertTo-PackageName (Split-Path -Leaf $RepoPath)
}

function Copy-PayloadFile {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$RelativePath,
        [Parameter(Mandatory = $true)][string]$PayloadRoot
    )

    Assert-NotSensitiveFile $Source
    $target = Join-Path $PayloadRoot $RelativePath
    if (-not (Test-PathInside $PayloadRoot $target)) {
        throw "payload 路徑超出套件根目錄：$RelativePath"
    }
    $parent = Split-Path -Parent $target
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
    Copy-Item -LiteralPath $Source -Destination $target -Force
}

function Add-DirectoryFiles {
    param(
        [Parameter(Mandatory = $true)][string]$SourceRoot,
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$PayloadRoot
    )

    if (-not (Test-Path -LiteralPath $SourceRoot -PathType Container)) { return 0 }
    Assert-NoReparsePoints $SourceRoot
    $count = 0
    foreach ($file in Get-ChildItem -LiteralPath $SourceRoot -Recurse -Force -File | Sort-Object FullName) {
        $relative = Get-RelativePath $RepoRoot $file.FullName
        Copy-PayloadFile -Source $file.FullName -RelativePath $relative -PayloadRoot $PayloadRoot
        $count += 1
    }
    return $count
}

function Get-GitMetadata {
    param([Parameter(Mandatory = $true)][string]$RepoPath)

    $branch = $null
    $commit = $null
    $dirty = $null
    try {
        $branch = (& git -C $RepoPath branch --show-current 2>$null | Select-Object -First 1)
        $commit = (& git -C $RepoPath rev-parse HEAD 2>$null | Select-Object -First 1)
        $dirty = @(& git -C $RepoPath status --porcelain 2>$null).Count -gt 0
    }
    catch {
        $branch = $null
        $commit = $null
        $dirty = $null
    }
    return [ordered]@{
        repository = Split-Path -Leaf $RepoPath
        branch = $branch
        commit = $commit
        dirty = $dirty
    }
}

function Write-Manifest {
    param(
        [Parameter(Mandatory = $true)][string]$PackageRoot,
        [Parameter(Mandatory = $true)][string]$PackageName,
        [Parameter(Mandatory = $true)][string]$DisplayName,
        [Parameter(Mandatory = $true)][string]$RepoPath
    )

    $payloadRoot = Join-Path $PackageRoot "payload"
    $entries = New-Object System.Collections.Generic.List[object]
    foreach ($file in Get-ChildItem -LiteralPath $payloadRoot -Recurse -Force -File | Sort-Object FullName) {
        $relative = (Get-RelativePath $payloadRoot $file.FullName).Replace("\", "/")
        $mode = Get-ExpectedMode $relative
        if (-not $mode) {
            throw "payload 含有不允許的 Harness 路徑：$relative"
        }
        $entries.Add([ordered]@{
            path = $relative
            mode = $mode
            sha256 = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
        })
    }
    $fingerprint = (($entries | ForEach-Object { "$($_.path):$($_.sha256)" }) -join "`n")
    $manifest = [ordered]@{
        formatVersion = 1
        name = $PackageName
        displayName = $DisplayName
        createdAt = [DateTime]::UtcNow.ToString("o")
        contentHash = Get-Sha256Text $fingerprint
        source = Get-GitMetadata $RepoPath
        files = @($entries | ForEach-Object { $_ })
    }
    Write-Utf8File -Path (Join-Path $PackageRoot "harness.json") -Content ($manifest | ConvertTo-Json -Depth 8)
    return $manifest
}

function Test-HarnessPackage {
    param([Parameter(Mandatory = $true)][string]$PackagePath)

    $packageFull = Resolve-FullPath $PackagePath
    if (-not (Test-Path -LiteralPath $packageFull -PathType Container)) {
        throw "找不到 Harness 套件資料夾：$packageFull"
    }
    Assert-NoReparsePoints $packageFull
    $manifestPath = Join-Path $packageFull "harness.json"
    $payloadRoot = Join-Path $packageFull "payload"
    if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf) -or -not (Test-Path -LiteralPath $payloadRoot -PathType Container)) {
        throw "套件必須包含 harness.json 與 payload/：$packageFull"
    }
    try {
        $manifest = [System.IO.File]::ReadAllText($manifestPath) | ConvertFrom-Json
    }
    catch {
        throw "harness.json 不是有效 JSON：$($_.Exception.Message)"
    }
    if ($manifest.formatVersion -ne 1 -or [string]::IsNullOrWhiteSpace([string]$manifest.name)) {
        throw "不支援的 harness.json 格式或缺少套件名稱"
    }
    $safeName = ConvertTo-PackageName ([string]$manifest.name)
    if ($safeName -ne [string]$manifest.name) {
        throw "harness.json 含有不安全的套件名稱：$($manifest.name)"
    }

    $declared = @{}
    foreach ($entry in @($manifest.files)) {
        $relative = [string]$entry.path
        if (-not (Test-SafeRelativePath $relative)) {
            throw "套件含有不安全路徑：$relative"
        }
        $relative = $relative.Replace("\", "/")
        if ($declared.ContainsKey($relative)) {
            throw "套件重複宣告路徑：$relative"
        }
        $expectedMode = Get-ExpectedMode $relative
        if (-not $expectedMode -or [string]$entry.mode -ne $expectedMode) {
            throw "套件路徑或安裝模式不允許：$relative"
        }
        $filePath = Join-Path $payloadRoot $relative.Replace("/", [System.IO.Path]::DirectorySeparatorChar)
        if (-not (Test-PathInside $payloadRoot $filePath) -or -not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
            throw "manifest 宣告的 payload 不存在：$relative"
        }
        Assert-NotSensitiveFile $filePath
        $actualHash = (Get-FileHash -LiteralPath $filePath -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($actualHash -ne ([string]$entry.sha256).ToLowerInvariant()) {
            throw "payload 雜湊不符：$relative"
        }
        $declared[$relative] = $true
    }
    foreach ($file in Get-ChildItem -LiteralPath $payloadRoot -Recurse -Force -File) {
        $relative = (Get-RelativePath $payloadRoot $file.FullName).Replace("\", "/")
        if (-not $declared.ContainsKey($relative)) {
            throw "payload 含有 manifest 未宣告的檔案：$relative"
        }
    }
    if (-not $declared.ContainsKey("AGENTS.md") -or
        @($declared.Keys | Where-Object { $_ -match "^\.codex/agents/.+" }).Count -lt 1 -or
        @($declared.Keys | Where-Object { $_ -match "^\.agents/skills/.+" }).Count -lt 1) {
        throw "套件至少需要 AGENTS.md、一個 agent 與一個 skill"
    }
    $fingerprint = ((@($manifest.files) | Sort-Object path | ForEach-Object { "$($_.path):$($_.sha256)" }) -join "`n")
    if ((Get-Sha256Text $fingerprint) -ne ([string]$manifest.contentHash).ToLowerInvariant()) {
        throw "套件 contentHash 不符"
    }
    return [pscustomobject]@{
        Root = $packageFull
        PayloadRoot = $payloadRoot
        Manifest = $manifest
    }
}

function Invoke-Pack {
    $repoFull = Resolve-FullPath $Repo
    if (-not (Test-Path -LiteralPath $repoFull -PathType Container)) {
        throw "來源 repo 不存在：$repoFull"
    }
    $agentsRoot = Join-Path $repoFull ".codex\agents"
    $skillsRoot = Join-Path $repoFull ".agents\skills"
    $agentsFile = Join-Path $repoFull "AGENTS.md"
    if (-not (Test-Path -LiteralPath $agentsFile -PathType Leaf)) {
        throw "來源 repo 缺少 AGENTS.md"
    }
    if (-not (Test-Path -LiteralPath $agentsRoot -PathType Container) -or @(Get-ChildItem -LiteralPath $agentsRoot -File).Count -eq 0) {
        throw "來源 repo 缺少 .codex/agents/*.toml"
    }
    if (-not (Test-Path -LiteralPath $skillsRoot -PathType Container) -or @(Get-ChildItem -LiteralPath $skillsRoot -Directory).Count -eq 0) {
        throw "來源 repo 缺少 .agents/skills/*"
    }

    $packageName = if ([string]::IsNullOrWhiteSpace($Name)) { Get-DefaultPackageName $repoFull } else { ConvertTo-PackageName $Name }
    $displayName = Get-DisplayName $repoFull
    $outputBase = if ([string]::IsNullOrWhiteSpace($Output)) { Join-Path $repoFull "dist" } else { Resolve-FullPath $Output $repoFull }
    $packageFull = if ($outputBase.EndsWith(".harness", [System.StringComparison]::OrdinalIgnoreCase)) {
        $outputBase
    }
    else {
        Join-Path $outputBase "$packageName.harness"
    }
    $packageFull = [System.IO.Path]::GetFullPath($packageFull)
    if (-not $packageFull.EndsWith(".harness", [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "輸出套件目錄必須以 .harness 結尾：$packageFull"
    }
    if (Test-Path -LiteralPath $packageFull -PathType Leaf) {
        throw "輸出路徑已存在且不是資料夾：$packageFull"
    }

    $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("harness-packager-" + [Guid]::NewGuid().ToString("N"))
    $stagePackage = Join-Path $tempRoot "$packageName.harness"
    $payloadRoot = Join-Path $stagePackage "payload"
    New-Item -ItemType Directory -Force -Path $payloadRoot | Out-Null
    try {
        Assert-NoReparsePoints $agentsFile
        Copy-PayloadFile -Source $agentsFile -RelativePath "AGENTS.md" -PayloadRoot $payloadRoot
        $agentCount = Add-DirectoryFiles -SourceRoot $agentsRoot -RepoRoot $repoFull -PayloadRoot $payloadRoot
        $skillCount = Add-DirectoryFiles -SourceRoot $skillsRoot -RepoRoot $repoFull -PayloadRoot $payloadRoot

        $configPath = Join-Path $repoFull ".codex\config.toml"
        if (Test-Path -LiteralPath $configPath -PathType Leaf) {
            Assert-NoReparsePoints $configPath
            $agentsSection = Get-AgentsTomlSection $configPath
            if ($agentsSection) {
                Write-Utf8File -Path (Join-Path $payloadRoot ".codex\config.toml") -Content $agentsSection
            }
        }

        $scriptsRoot = Join-Path $repoFull "scripts"
        if (Test-Path -LiteralPath $scriptsRoot -PathType Container) {
            foreach ($file in Get-ChildItem -LiteralPath $scriptsRoot -File | Where-Object { $_.Name -match "^validate[-_]harness" }) {
                Assert-NoReparsePoints $file.FullName
                Copy-PayloadFile -Source $file.FullName -RelativePath ("scripts\" + $file.Name) -PayloadRoot $payloadRoot
            }
        }
        $testsRoot = Join-Path $repoFull "tests"
        if (Test-Path -LiteralPath $testsRoot -PathType Container) {
            Assert-NoReparsePoints $testsRoot
            foreach ($file in Get-ChildItem -LiteralPath $testsRoot -Recurse -Force -File | Where-Object { $_.Name -match "^harness[-_]" }) {
                $relative = Get-RelativePath $repoFull $file.FullName
                Copy-PayloadFile -Source $file.FullName -RelativePath $relative -PayloadRoot $payloadRoot
            }
        }

        if ($agentCount -lt 1 -or $skillCount -lt 1) {
            throw "套件至少需要一個 agent 與一個 skill"
        }
        $manifest = Write-Manifest -PackageRoot $stagePackage -PackageName $packageName -DisplayName $displayName -RepoPath $repoFull
        Test-HarnessPackage $stagePackage | Out-Null

        $parent = Split-Path -Parent $packageFull
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
        Assert-NoReparseInPath -Root $parent -Candidate $packageFull
        $oldPath = $null
        if (Test-Path -LiteralPath $packageFull -PathType Container) {
            Assert-NoReparsePoints $packageFull
            $oldPath = Join-Path $parent ("." + [System.IO.Path]::GetFileName($packageFull) + ".old-" + [Guid]::NewGuid().ToString("N"))
            if (-not (Test-PathInside $parent $oldPath) -or -not $packageFull.EndsWith(".harness", [System.StringComparison]::OrdinalIgnoreCase)) {
                throw "拒絕移動未確認的輸出目錄：$packageFull"
            }
            Move-Item -LiteralPath $packageFull -Destination $oldPath
        }
        try {
            Move-Item -LiteralPath $stagePackage -Destination $packageFull
            if ($oldPath -and (Test-Path -LiteralPath $oldPath)) {
                if (-not (Test-PathInside $parent $oldPath)) { throw "拒絕刪除輸出目錄外的舊套件" }
                Remove-Item -LiteralPath $oldPath -Recurse -Force
            }
        }
        catch {
            if ($oldPath -and (Test-Path -LiteralPath $oldPath) -and -not (Test-Path -LiteralPath $packageFull)) {
                Move-Item -LiteralPath $oldPath -Destination $packageFull
            }
            throw
        }

        Write-Output "PACKED $packageFull"
        Write-Output "NAME $($manifest.name)"
        Write-Output "FILES $(@($manifest.files).Count)"
        Write-Output "CONTENT_HASH $($manifest.contentHash)"
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            $tempFull = [System.IO.Path]::GetFullPath($tempRoot)
            $systemTemp = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
            if ((Test-PathInside $systemTemp $tempFull) -and (Split-Path -Leaf $tempFull) -like "harness-packager-*") {
                Remove-Item -LiteralPath $tempFull -Recurse -Force
            }
        }
    }
}

function Parse-SimpleTomlPatch {
    param([Parameter(Mandatory = $true)][string]$Text)

    $result = [ordered]@{}
    $section = $null
    foreach ($line in ($Text -split "`r?`n")) {
        $heading = [System.Text.RegularExpressions.Regex]::Match($line, "^\s*\[([^\[\]]+)\]\s*(?:#.*)?$")
        if ($heading.Success) {
            $section = $heading.Groups[1].Value.Trim()
            if (-not $result.Contains($section)) { $result[$section] = [ordered]@{} }
            continue
        }
        if (-not $section -or $line.TrimStart().StartsWith("#") -or [string]::IsNullOrWhiteSpace($line)) { continue }
        $assignment = [System.Text.RegularExpressions.Regex]::Match($line, "^\s*([A-Za-z0-9_.-]+)\s*=\s*(.+?)\s*$")
        if (-not $assignment.Success) {
            throw "套件 config.toml 含有不支援的 TOML 行：$line"
        }
        $key = $assignment.Groups[1].Value
        $result[$section][$key] = "$key = $($assignment.Groups[2].Value)"
    }
    return $result
}

function Merge-TomlPatch {
    param([AllowEmptyString()][string]$TargetText, [Parameter(Mandatory = $true)][string]$PatchText)

    $patch = Parse-SimpleTomlPatch $PatchText
    $seen = @{}
    $output = New-Object System.Collections.Generic.List[string]
    $currentSection = $null

    function Add-MissingKeys {
        param([string]$SectionName)
        if (-not $SectionName -or -not $patch.Contains($SectionName)) { return }
        foreach ($key in $patch[$SectionName].Keys) {
            $token = "$SectionName`0$key"
            if (-not $seen.ContainsKey($token)) {
                $output.Add([string]$patch[$SectionName][$key])
                $seen[$token] = $true
            }
        }
    }

    foreach ($line in ($TargetText -split "`r?`n")) {
        $heading = [System.Text.RegularExpressions.Regex]::Match($line, "^\s*\[([^\[\]]+)\]\s*(?:#.*)?$")
        if ($heading.Success) {
            Add-MissingKeys $currentSection
            $currentSection = $heading.Groups[1].Value.Trim()
            $output.Add($line)
            continue
        }
        $assignment = [System.Text.RegularExpressions.Regex]::Match($line, "^\s*([A-Za-z0-9_.-]+)\s*=\s*(.+?)\s*$")
        if ($assignment.Success -and $currentSection -and $patch.Contains($currentSection)) {
            $key = $assignment.Groups[1].Value
            if ($patch[$currentSection].Contains($key)) {
                $token = "$currentSection`0$key"
                if ($seen.ContainsKey($token)) {
                    throw "目標 config.toml 有重複 key：[$currentSection] $key"
                }
                $output.Add([string]$patch[$currentSection][$key])
                $seen[$token] = $true
                continue
            }
        }
        $output.Add($line)
    }
    Add-MissingKeys $currentSection

    foreach ($sectionName in $patch.Keys) {
        $sectionSeen = $false
        foreach ($token in $seen.Keys) {
            if ($token.StartsWith("$sectionName`0", [System.StringComparison]::Ordinal)) {
                $sectionSeen = $true
                break
            }
        }
        if (-not $sectionSeen) {
            if ($output.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace($output[$output.Count - 1])) { $output.Add("") }
            $output.Add("[$sectionName]")
            foreach ($key in $patch[$sectionName].Keys) {
                $output.Add([string]$patch[$sectionName][$key])
                $seen["$sectionName`0$key"] = $true
            }
        }
    }
    while ($output.Count -gt 0 -and [string]::IsNullOrWhiteSpace($output[$output.Count - 1])) {
        $output.RemoveAt($output.Count - 1)
    }
    return (($output -join [Environment]::NewLine) + [Environment]::NewLine)
}

function Merge-ManagedMarkdown {
    param(
        [AllowEmptyString()][string]$TargetText,
        [Parameter(Mandatory = $true)][string]$PackageName,
        [Parameter(Mandatory = $true)][string]$PackageText
    )

    $start = "<!-- harness-package:${PackageName}:start -->"
    $end = "<!-- harness-package:${PackageName}:end -->"
    $block = $start + [Environment]::NewLine + $PackageText.Trim() + [Environment]::NewLine + $end
    $pattern = [System.Text.RegularExpressions.Regex]::Escape($start) + ".*?" + [System.Text.RegularExpressions.Regex]::Escape($end)
    if ([System.Text.RegularExpressions.Regex]::IsMatch($TargetText, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)) {
        return [System.Text.RegularExpressions.Regex]::Replace($TargetText, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($match) $block }, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    }
    if ([string]::IsNullOrWhiteSpace($TargetText)) {
        return $block + [Environment]::NewLine
    }
    return $TargetText.TrimEnd() + [Environment]::NewLine + [Environment]::NewLine + $block + [Environment]::NewLine
}

function Invoke-Install {
    if ([string]::IsNullOrWhiteSpace($Package)) { throw "Install 需要 -Package" }
    $repoFull = Resolve-FullPath $Repo
    if (-not (Test-Path -LiteralPath $repoFull -PathType Container)) {
        throw "目標 repo 不存在：$repoFull"
    }
    $verified = Test-HarnessPackage (Resolve-FullPath $Package $repoFull)
    $manifest = $verified.Manifest
    $packageName = [string]$manifest.name
    $stateRoot = Join-Path $repoFull ".harness"
    Assert-NoReparseInPath -Root $repoFull -Candidate $stateRoot
    $receiptPath = Join-Path $stateRoot ("installed\" + $packageName + ".json")
    $oldReceipt = $null
    if (Test-Path -LiteralPath $receiptPath -PathType Leaf) {
        $oldReceipt = [System.IO.File]::ReadAllText($receiptPath) | ConvertFrom-Json
    }
    $operation = if ($oldReceipt) { "UPDATED" } else { "INSTALLED" }
    $timestamp = [DateTime]::UtcNow.ToString("yyyyMMddTHHmmssfffZ")
    $backupRoot = Join-Path $stateRoot ("backups\" + $packageName + "\" + $timestamp)
    $backupPayload = Join-Path $backupRoot "payload"

    $affected = @{}
    foreach ($entry in @($manifest.files)) { $affected[[string]$entry.path] = [string]$entry.mode }
    if ($oldReceipt) {
        foreach ($entry in @($oldReceipt.files)) { $affected[[string]$entry.path] = [string]$entry.mode }
    }
    $backedUp = @{}
    foreach ($relative in $affected.Keys) {
        if (-not (Test-SafeRelativePath $relative) -or -not (Get-ExpectedMode $relative)) {
            throw "receipt 或 manifest 含有不安全路徑：$relative"
        }
        $target = Join-Path $repoFull $relative.Replace("/", [System.IO.Path]::DirectorySeparatorChar)
        if (-not (Test-PathInside $repoFull $target)) { throw "目標路徑超出 repo：$relative" }
        Assert-NoReparseInPath -Root $repoFull -Candidate $target
        if (Test-Path -LiteralPath $target -PathType Leaf) {
            $backup = Join-Path $backupPayload $relative.Replace("/", [System.IO.Path]::DirectorySeparatorChar)
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $backup) | Out-Null
            Copy-Item -LiteralPath $target -Destination $backup -Force
            $backedUp[$relative] = $true
        }
        else {
            $backedUp[$relative] = $false
        }
    }
    if (Test-Path -LiteralPath $receiptPath -PathType Leaf) {
        New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null
        Copy-Item -LiteralPath $receiptPath -Destination (Join-Path $backupRoot "receipt.json") -Force
    }

    try {
        $newPaths = @{}
        foreach ($entry in @($manifest.files)) { $newPaths[[string]$entry.path] = $true }
        if ($oldReceipt) {
            foreach ($entry in @($oldReceipt.files)) {
                $oldPath = [string]$entry.path
                if ([string]$entry.mode -eq "replace" -and -not $newPaths.ContainsKey($oldPath)) {
                    $target = Join-Path $repoFull $oldPath.Replace("/", [System.IO.Path]::DirectorySeparatorChar)
                    if (Test-Path -LiteralPath $target -PathType Leaf) { Remove-Item -LiteralPath $target -Force }
                }
            }
        }

        foreach ($entry in @($manifest.files)) {
            $relative = [string]$entry.path
            $source = Join-Path $verified.PayloadRoot $relative.Replace("/", [System.IO.Path]::DirectorySeparatorChar)
            $target = Join-Path $repoFull $relative.Replace("/", [System.IO.Path]::DirectorySeparatorChar)
            switch ([string]$entry.mode) {
                "replace" {
                    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
                    Copy-Item -LiteralPath $source -Destination $target -Force
                }
                "managed-markdown" {
                    $targetText = if (Test-Path -LiteralPath $target -PathType Leaf) { [System.IO.File]::ReadAllText($target) } else { "" }
                    $packageText = [System.IO.File]::ReadAllText($source)
                    Write-Utf8File -Path $target -Content (Merge-ManagedMarkdown -TargetText $targetText -PackageName $packageName -PackageText $packageText)
                }
                "merge-toml" {
                    $targetText = if (Test-Path -LiteralPath $target -PathType Leaf) { [System.IO.File]::ReadAllText($target) } else { "" }
                    $patchText = [System.IO.File]::ReadAllText($source)
                    Write-Utf8File -Path $target -Content (Merge-TomlPatch -TargetText $targetText -PatchText $patchText)
                }
                default { throw "不支援的安裝模式：$($entry.mode)" }
            }
        }

        $receipt = [ordered]@{
            formatVersion = 1
            name = $packageName
            displayName = [string]$manifest.displayName
            contentHash = [string]$manifest.contentHash
            installedAt = [DateTime]::UtcNow.ToString("o")
            sourcePackage = $verified.Root
            files = @($manifest.files)
        }
        Write-Utf8File -Path $receiptPath -Content ($receipt | ConvertTo-Json -Depth 8)
        Write-Output "$operation $repoFull"
        Write-Output "PACKAGE $packageName"
        Write-Output "FILES $(@($manifest.files).Count)"
        if (Test-Path -LiteralPath $backupRoot -PathType Container) { Write-Output "BACKUP $backupRoot" }
    }
    catch {
        foreach ($relative in $affected.Keys) {
            $target = Join-Path $repoFull $relative.Replace("/", [System.IO.Path]::DirectorySeparatorChar)
            $backup = Join-Path $backupPayload $relative.Replace("/", [System.IO.Path]::DirectorySeparatorChar)
            if ($backedUp[$relative] -and (Test-Path -LiteralPath $backup -PathType Leaf)) {
                New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
                Copy-Item -LiteralPath $backup -Destination $target -Force
            }
            elseif (Test-Path -LiteralPath $target -PathType Leaf) {
                Remove-Item -LiteralPath $target -Force
            }
        }
        $receiptBackup = Join-Path $backupRoot "receipt.json"
        if (Test-Path -LiteralPath $receiptBackup -PathType Leaf) {
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $receiptPath) | Out-Null
            Copy-Item -LiteralPath $receiptBackup -Destination $receiptPath -Force
        }
        elseif (Test-Path -LiteralPath $receiptPath -PathType Leaf) {
            Remove-Item -LiteralPath $receiptPath -Force
        }
        throw
    }
}

switch ($Action) {
    "Pack" { Invoke-Pack }
    "Install" { Invoke-Install }
    "Verify" {
        if ([string]::IsNullOrWhiteSpace($Package)) { throw "Verify 需要 -Package" }
        $verified = Test-HarnessPackage (Resolve-FullPath $Package)
        Write-Output "VERIFIED $($verified.Root)"
        Write-Output "NAME $($verified.Manifest.name)"
        Write-Output "FILES $(@($verified.Manifest.files).Count)"
        Write-Output "CONTENT_HASH $($verified.Manifest.contentHash)"
    }
}
