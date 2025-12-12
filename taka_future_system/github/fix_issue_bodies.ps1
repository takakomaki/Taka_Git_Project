# Issue本文（Body）修正スクリプト
# 目的: 文字化け(??/�)したIssue本文を、正しいテンプレで上書きして復旧する
# 対象: 主に Milestone「Taka Future System v1.0」配下の生成Issue
# Version: 1.0

$repo = "takakomaki/Taka_Git_Project"
$baseUrl = "https://api.github.com/repos/$repo"

if (-not $env:GITHUB_TOKEN) {
    Write-Host "GITHUB_TOKEN環境変数が設定されていません。" -ForegroundColor Yellow
    Write-Host "例: `$env:GITHUB_TOKEN = 'ghp_...'" -ForegroundColor Yellow
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $env:GITHUB_TOKEN"
    "Accept"        = "application/vnd.github.v3+json"
}

function Get-DomainInfoFromTitle {
    param([string]$Title)

    if ($Title -match '^\[Curriculum\]')     { return @{ domain='curriculum';     master='curriculum_master_map.md';        expected='YAML / Mermaid / Markdown' } }
    if ($Title -match '^\[Value\]')          { return @{ domain='value-proposition'; master='value_proposition_matrix.md';     expected='JSON / Mermaid / Markdown' } }
    if ($Title -match '^\[Business\]')       { return @{ domain='business';       master='business_architecture_map.md';     expected='Mermaid / Python / Markdown' } }
    if ($Title -match '^\[AI-Orchestra\]')   { return @{ domain='ai-orchestra';   master='ai_orchestra_blueprint.md';        expected='JSON / Markdown' } }
    if ($Title -match '^\[Infrastructure\]') { return @{ domain='infrastructure'; master='infrastructure_setup.md';           expected='PowerShell / YAML / Markdown' } }
    if ($Title -match '^\[Brand\]')          { return @{ domain='brand';          master='taka_brand_bible.md';               expected='Markdown / Templates' } }
    if ($Title -match '^\[Integration\]')    { return @{ domain='integration';    master='taka_integrated_system_map.md';     expected='Mermaid / JSON / Markdown' } }

    return @{ domain='todo'; master='XXX.md'; expected='Markdown' }
}

function Is-BodyGarbled {
    param([string]$Body)
    if ([string]::IsNullOrEmpty($Body)) { return $false }

    # Replacement character (�)
    if ($Body.Contains([char]0xFFFD)) { return $true }

    # Runs of question marks as seen in corrupted Japanese output
    if ($Body -match '\?\?\?') { return $true }

    return $false
}

function Build-Body {
    param(
        [string]$Title,
        [string]$Domain,
        [string]$MasterFile,
        [string]$Expected
    )

    $short = $Title -replace '^\[[^\]]+\]\s*', ''

@"
## 🎯 Purpose
このIssueの目的：
- 「$short」を実装・検証し、マスターファイルに整合した成果物を生成する

## 📄 Related Master File
このIssueは以下のマスターファイルを参照します：
- taka_future_system/master_files/$MasterFile

## 🧩 Tasks
- [ ] Step1：要件整理（成果物の形式・粒度・評価基準）
- [ ] Step2：実装（データ/図/テンプレ/スクリプト等の生成）
- [ ] Step3：整合チェック（master_filesと突き合わせ）
- [ ] Review & Alignment with Master File

## 🌱 Expected Output
- 生成される成果物：$Expected
- 保存先：taka_future_system/implementations/ 配下

## 🔗 Links
- 関連Issue：
- 関連Epic：Taka Future Orchestration System

## 🏷 Labels
- domain: $Domain
- status: todo

## 📅 Milestone
- Taka Future System v1.0
"@
}

function Update-IssueBody {
    param(
        [int]$IssueNumber,
        [string]$NewBody
    )

    $issueUrl = "$baseUrl/issues/$IssueNumber"

    try {
        $payload = @{ body = $NewBody } | ConvertTo-Json -Depth 10
        $response = Invoke-RestMethod -Uri $issueUrl -Method Patch -Headers $headers -Body $payload -ContentType "application/json; charset=utf-8"
        return $response
    } catch {
        Write-Host "Error updating issue body #$IssueNumber : $_" -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Response: $responseBody" -ForegroundColor Red
        }
        return $null
    }
}

# 対象Issue（v1.0生成Issueの番号帯）
# ※#18 はduplicate化された可能性があるため、本スクリプトでは更新対象から除外。
$targets = 19..53

Write-Host "`n=== Issue本文（Body）修正を開始します ===" -ForegroundColor Cyan
Write-Host "対象Issue: #$($targets[0]) 〜 #$($targets[-1])（合計 $($targets.Count) 件）" -ForegroundColor Cyan
Write-Host "条件: 本文に '???' または '�' が含まれる場合のみ上書きします`n" -ForegroundColor Cyan

$updated = @()
$skipped = @()
$failed  = @()

foreach ($n in $targets) {
    $issueUrl = "$baseUrl/issues/$n"

    try {
        $issue = Invoke-RestMethod -Uri $issueUrl -Method Get -Headers $headers
    } catch {
        $failed += $n
        Write-Host "Fetch failed: #$n" -ForegroundColor Red
        continue
    }

    if ($issue.pull_request) {
        $skipped += $n
        continue
    }

    if (-not (Is-BodyGarbled -Body $issue.body)) {
        $skipped += $n
        continue
    }

    $info = Get-DomainInfoFromTitle -Title $issue.title
    $newBody = Build-Body -Title $issue.title -Domain $info.domain -MasterFile $info.master -Expected $info.expected

    Write-Host "Updating Body #$n : $($issue.title)" -ForegroundColor Yellow
    $res = Update-IssueBody -IssueNumber $n -NewBody $newBody

    if ($res) {
        $updated += $res
        Write-Host "  Success! Updated: $($res.html_url)" -ForegroundColor Green
        Start-Sleep -Milliseconds 700
    } else {
        $failed += $n
        Write-Host "  Failed: #$n" -ForegroundColor Red
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "本文修正完了: $($updated.Count) 件" -ForegroundColor Green
Write-Host "スキップ（既に正常 or 取得不可）: $($skipped.Count) 件" -ForegroundColor Yellow
Write-Host "失敗: $($failed.Count) 件" -ForegroundColor Red
Write-Host "========================================`n" -ForegroundColor Cyan

if ($updated.Count -gt 0) {
    Write-Host "修正されたIssue一覧:" -ForegroundColor Cyan
    foreach ($i in $updated) {
        Write-Host "  - #$($i.number): $($i.title)" -ForegroundColor White
        Write-Host "    URL: $($i.html_url)" -ForegroundColor Gray
    }
}

if ($failed.Count -gt 0) {
    Write-Host "`n失敗したIssue番号:" -ForegroundColor Red
    $failed | Sort-Object -Unique | ForEach-Object { Write-Host "  - #$_" -ForegroundColor Red }
}

Write-Host "`n本文修正プロセスが完了しました。" -ForegroundColor Cyan


