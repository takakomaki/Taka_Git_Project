# Event Log方式の“受け皿”Issueを常設するスクリプト
# - 3つのIssue（Decision / Insight / Shift）を重複なしで作成/更新
# - 必要ラベルが無ければ作成
# - 可能なら Milestone「System Review & Evolution」に紐づけ
# - 可能なら Project「Taka Future Orchestration」に追加（best-effort）
#
# 使い方:
#   cd C:\doc\Taka_Git_Project
#   $env:GITHUB_TOKEN="ghp_...（repo scope）"
#   pwsh -NoProfile -File .\taka_future_system\github\create_memory_eventlog_issues.ps1

$ErrorActionPreference = 'Stop'

$repo = "takakomaki/Taka_Git_Project"
$baseUrl = "https://api.github.com/repos/$repo"

if (-not $env:GITHUB_TOKEN) {
    Write-Host "GITHUB_TOKEN環境変数が設定されていません。" -ForegroundColor Yellow
    Write-Host "例: `$env:GITHUB_TOKEN = 'ghp_...'" -ForegroundColor Yellow
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $env:GITHUB_TOKEN"
    "Accept"        = "application/vnd.github+json"
    "User-Agent"    = "Cursor"
}

function Get-AllLabels {
    Invoke-RestMethod -Uri "$baseUrl/labels?per_page=100" -Headers $headers -Method Get
}

function Ensure-Label {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Color, # with or without '#'
        [Parameter(Mandatory)][string]$Description
    )

    $labels = Get-AllLabels
    $found = $labels | Where-Object { $_.name -eq $Name } | Select-Object -First 1
    if ($found) { return $found }

    $body = @{
        name        = $Name
        color       = $Color.TrimStart('#')
        description = $Description
    } | ConvertTo-Json -Depth 6

    Invoke-RestMethod -Uri "$baseUrl/labels" -Headers $headers -Method Post -Body $body -ContentType "application/json; charset=utf-8"
}

function Get-MilestoneNumberOrNull {
    param([Parameter(Mandatory)][string]$Title)

    $ms = Invoke-RestMethod -Uri "$baseUrl/milestones?state=all&per_page=100" -Headers $headers -Method Get
    $found = $ms | Where-Object { $_.title -eq $Title } | Select-Object -First 1
    if ($found) { return [int]$found.number }
    return $null
}

function Search-IssueByExactTitle {
    param([Parameter(Mandatory)][string]$Title)

    $q = "repo:$repo is:issue in:title `"$Title`""
    $u = "https://api.github.com/search/issues?q=$([uri]::EscapeDataString($q))&per_page=5"
    Invoke-RestMethod -Headers $headers -Uri $u -Method Get
}

function Create-Issue {
    param(
        [Parameter(Mandatory)][string]$Title,
        [Parameter(Mandatory)][string]$Body,
        [int]$MilestoneNumber,
        [string[]]$Labels
    )

    $payload = @{
        title     = $Title
        body      = $Body
        labels    = $Labels
    }
    if ($MilestoneNumber) { $payload.milestone = $MilestoneNumber }

    $json = $payload | ConvertTo-Json -Depth 10
    Invoke-RestMethod -Uri "$baseUrl/issues" -Headers $headers -Method Post -Body $json -ContentType "application/json; charset=utf-8"
}

function Update-Issue {
    param(
        [Parameter(Mandatory)][int]$IssueNumber,
        [Parameter(Mandatory)][string]$Body,
        [int]$MilestoneNumber,
        [string[]]$Labels
    )

    $payload = @{
        body   = $Body
        labels = $Labels
    }
    if ($MilestoneNumber) { $payload.milestone = $MilestoneNumber }

    $json = $payload | ConvertTo-Json -Depth 10
    Invoke-RestMethod -Uri "$baseUrl/issues/$IssueNumber" -Headers $headers -Method Patch -Body $json -ContentType "application/json; charset=utf-8"
}

function Try-AddToProjectV2 {
    param(
        [Parameter(Mandatory)][string]$IssueNodeId,
        [Parameter(Mandatory)][string]$OwnerLogin,
        [Parameter(Mandatory)][string]$ProjectTitle
    )

    $gqlHeaders = @{
        "Authorization" = "Bearer $env:GITHUB_TOKEN"
        "Accept"        = "application/vnd.github+json"
        "User-Agent"    = "Cursor"
    }

    $query = @'
query($login:String!, $first:Int!) {
  user(login:$login) {
    projectsV2(first:$first) {
      nodes { id title }
    }
  }
}
'@

    try {
        $qBody = @{ query=$query; variables=@{ login=$OwnerLogin; first=50 } } | ConvertTo-Json -Depth 10
        $resp = Invoke-RestMethod -Headers $gqlHeaders -Uri "https://api.github.com/graphql" -Method Post -Body $qBody -ContentType "application/json; charset=utf-8"
        $proj = $resp.data.user.projectsV2.nodes | Where-Object { $_.title -eq $ProjectTitle } | Select-Object -First 1
        if (-not $proj) { return @{ ok=$false; reason='project_not_found' } }

        $mut = @'
mutation($projectId:ID!, $contentId:ID!) {
  addProjectV2ItemById(input:{projectId:$projectId, contentId:$contentId}) {
    item { id }
  }
}
'@
        $mBody = @{ query=$mut; variables=@{ projectId=$proj.id; contentId=$IssueNodeId } } | ConvertTo-Json -Depth 10
        $mResp = Invoke-RestMethod -Headers $gqlHeaders -Uri "https://api.github.com/graphql" -Method Post -Body $mBody -ContentType "application/json; charset=utf-8"
        if ($mResp.errors) { return @{ ok=$false; reason='graphql_error' } }
        return @{ ok=$true }
    } catch {
        return @{ ok=$false; reason='exception' }
    }
}

Write-Host "`n=== Event Log Issues セットアップ開始 ===" -ForegroundColor Cyan

# Labels（無ければ作成）
Write-Host "`n--- Ensuring labels ---" -ForegroundColor Cyan
$null = Ensure-Label -Name "memory"     -Color "#5E06AA" -Description "AI Orchestra memory index"
$null = Ensure-Label -Name "event-log"  -Color "#00A39A" -Description "Event log index issues"
$null = Ensure-Label -Name "decision"   -Color "#F5D193" -Description "Decision event"
$null = Ensure-Label -Name "insight"    -Color "#7AB8A5" -Description "Insight event"
$null = Ensure-Label -Name "shift"      -Color "#2A4A6E" -Description "Shift event"

# Milestone（可能なら）
Write-Host "`n--- Resolving milestone ---" -ForegroundColor Cyan
$milestoneTitle = "System Review & Evolution"
$msNumber = $null
try {
    $msNumber = Get-MilestoneNumberOrNull -Title $milestoneTitle
} catch {
    $msNumber = $null
}
if ($msNumber) {
    Write-Host "Milestone found: $milestoneTitle (#$msNumber)" -ForegroundColor Green
} else {
    Write-Host "Milestone not found (skip milestone set): $milestoneTitle" -ForegroundColor Yellow
}

$issues = @(
    @{
        title  = "[Memory] Decision Log"
        labels = @("memory","event-log","decision")
        body   = @"
## 🎯 Role
「決めたこと（Decision）」が生まれたら、ここに着地させる“入口（索引）”。

## ✅ How to use
- 会話や検討の中で「決断」が起きたら、Eventを1件作成
- Eventファイル（本体）に記録し、このIssueにはリンクだけを残す
- 会話全文は保存しない（エッセンスのみ）

## 📄 Event File Format
- Path: taka_future_system/memory/events/
- Filename: YYYY-MM-DD_decision_<short_slug>.md

## 🔗 Links (Index)
- (Add links to event files / PRs here)
"@
    },
    @{
        title  = "[Memory] Insight Log"
        labels = @("memory","event-log","insight")
        body   = @"
## 🎯 Role
刺さった洞察（Insight）を拾い、未来の判断に活かすための“入口（索引）”。

## ✅ How to use
- Claude / Gemini / Grok / GPT / Cursor から得た洞察をEvent化
- Eventファイル（本体）に要点だけ記録し、ここにはリンクを追加
- 重複する洞察は統合し、ノイズは捨てる

## 📄 Event File Format
- Path: taka_future_system/memory/events/
- Filename: YYYY-MM-DD_insight_<source>_<short_slug>.md

## 🔗 Links (Index)
- (Add links to event files / PRs here)
"@
    },
    @{
        title  = "[Memory] Shift Log"
        labels = @("memory","event-log","shift")
        body   = @"
## 🎯 Role
前提・方針・フェーズが変わった瞬間（Shift）を捕まえる“入口（索引）”。

## ✅ How to use
- 「前提が変わった」「進め方を変える」「焦点が変わる」などが起きたらEvent化
- Shiftは CONTEXT_PACK.md 更新候補にもなる
- ここにはリンクだけを残し、本文はEventファイル側に集約

## 📄 Event File Format
- Path: taka_future_system/memory/events/
- Filename: YYYY-MM-DD_shift_<short_slug>.md

## 🔗 Links (Index)
- (Add links to event files / PRs here)
"@
    }
)

Write-Host "`n--- Creating/updating issues (dedupe by title) ---" -ForegroundColor Cyan
$created = @()
$updated = @()
$projectAdded = 0
$projectFailed = 0

foreach ($spec in $issues) {
    $s = Search-IssueByExactTitle -Title $spec.title
    if ($s.total_count -gt 0) {
        $existing = $s.items[0]
        $num = [int]$existing.number
        $res = Update-Issue -IssueNumber $num -Body $spec.body -MilestoneNumber $msNumber -Labels $spec.labels
        $updated += $res.html_url

        $try = Try-AddToProjectV2 -IssueNodeId $res.node_id -OwnerLogin "takakomaki" -ProjectTitle "Taka Future Orchestration"
        if ($try.ok) { $projectAdded++ } else { $projectFailed++ }
        continue
    }

    $res = Create-Issue -Title $spec.title -Body $spec.body -MilestoneNumber $msNumber -Labels $spec.labels
    $created += $res.html_url

    $try = Try-AddToProjectV2 -IssueNodeId $res.node_id -OwnerLogin "takakomaki" -ProjectTitle "Taka Future Orchestration"
    if ($try.ok) { $projectAdded++ } else { $projectFailed++ }
}

Write-Host "`n=== RESULT ===" -ForegroundColor Cyan
Write-Host ("Created: " + $created.Count) -ForegroundColor Green
Write-Host ("Updated(existing): " + $updated.Count) -ForegroundColor Green
Write-Host ("Project added: " + $projectAdded) -ForegroundColor Yellow
Write-Host ("Project add failed: " + $projectFailed) -ForegroundColor Yellow

Write-Host "`nIssue URLs:" -ForegroundColor Cyan
($created + $updated) | ForEach-Object { Write-Host ("- " + $_) -ForegroundColor White }

Write-Host "`n=== Event Log Issues セットアップ完了 ===" -ForegroundColor Cyan


