# 失敗した2つのIssueを再作成するスクリプト
# Taka Future Orchestration System
# Version: 1.0

$repo = "takakomaki/Taka_Git_Project"
$baseUrl = "https://api.github.com/repos/$repo"

if (-not $env:GITHUB_TOKEN) {
    Write-Host "GITHUB_TOKEN環境変数が設定されていません。" -ForegroundColor Yellow
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $env:GITHUB_TOKEN"
    "Accept" = "application/vnd.github.v3+json"
}

# Milestone取得
function Get-Milestone {
    $url = "$baseUrl/milestones?state=open"
    try {
        $milestones = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
        $existing = $milestones | Where-Object { $_.title -eq "Taka Future System v1.0" }
        if ($existing) {
            Write-Host "Milestone exists: #$($existing.number)" -ForegroundColor Green
            return $existing.number
        }
    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
    return $null
}

# Issue作成（JSONエンコードを改善）
function New-Issue {
    param($Title, $Body, $Labels, $Milestone)
    
    $issueBody = @{
        title = $Title
        body = $Body
        labels = $Labels
    }
    if ($Milestone) { $issueBody.milestone = $Milestone }
    
    # JSONエンコード時に特殊文字を適切に処理
    $json = $issueBody | ConvertTo-Json -Depth 10 -Compress
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/issues" -Method Post -Headers $headers -Body $json -ContentType "application/json; charset=utf-8"
        return $response
    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Response: $responseBody" -ForegroundColor Red
        }
        return $null
    }
}

# Issue本文生成（特殊文字を安全に処理）
function Create-IssueBody {
    param($Purpose, $MasterFile, $Tasks, $ExpectedOutput, $RelatedIssues = "なし（初回）")
    
    $tasksText = ($Tasks | ForEach-Object { "- [ ] $_" }) -join "`n"
    
    $body = "## Purpose`nこのIssueの目的：`n$Purpose`n`n## Related Master File`nこのIssueは以下のマスターファイルを参照します：`n- taka_future_system/master_files/$MasterFile`n`n## Tasks`n$tasksText`n- [ ] Review & Alignment with Master File`n`n## Expected Output`n$ExpectedOutput`n`n## Links`n- 関連Issue: $RelatedIssues`n- 関連Epic: Taka Future Orchestration System`n`n## Labels`n- domain: (各Issueで設定)`n- status: todo`n`n## Milestone`n- Taka Future System v1.0"
    
    return $body
}

# 実行
Write-Host "`n=== 失敗した2つのIssueを再作成します ===" -ForegroundColor Cyan
$milestone = Get-Milestone

if (-not $milestone) {
    Write-Host "Milestoneの取得に失敗しました。終了します。" -ForegroundColor Red
    exit 1
}

# 失敗した2つのIssue定義
$failedIssues = @()

# Issue 1: [Value] Define: 深さ×対象者マトリクス拡張
# 「×」記号を「x」に置き換えて安全に処理
$failedIssues += @{
    Title = "[Value] Define: 深さx対象者マトリクス拡張"
    Body = Create-IssueBody -Purpose "深さ（D1〜D4）x対象者（T1〜T4）のマトリクスを拡張・詳細化する" -MasterFile "value_proposition_matrix.md" -Tasks @("Step1: 既存のマトリクスを確認・拡張", "Step2: 空白のマスを特定し、商品候補を提案", "Step3: 拡張マトリクスをJSON形式で更新") -ExpectedOutput "- 拡張マトリクス定義ファイル（JSON形式）`n- 商品候補リスト（Markdown形式）`n- 保存先: taka_future_system/implementations/value_proposition_matrix_extended.json"
    Labels = @("value-proposition", "todo")
}

# Issue 2: [Value] Visualize: 価値マップMermaidモデル
# 「×」記号を「x」に置き換えて安全に処理
$failedIssues += @{
    Title = "[Value] Visualize: 価値マップMermaidモデル"
    Body = Create-IssueBody -Purpose "価値マップをMermaid図で可視化する" -MasterFile "value_proposition_matrix.md" -Tasks @("Step1: 価値マップのMermaid図を作成", "Step2: 深さx対象者のマトリクスを可視化", "Step3: 価値の流れを可視化") -ExpectedOutput "- 価値マップMermaid図（.mermaid形式）`n- 保存先: taka_future_system/implementations/value_map.mermaid" -RelatedIssues "[Value] Define, [Value] Model"
    Labels = @("value-proposition", "todo")
}

Write-Host "合計 $($failedIssues.Count) 個のIssueを作成します`n" -ForegroundColor Cyan

$createdIssues = @()
$stillFailed = @()

foreach ($issue in $failedIssues) {
    Write-Host "Creating: $($issue.Title)..." -ForegroundColor Yellow
    $result = New-Issue -Title $issue.Title -Body $issue.Body -Labels $issue.Labels -Milestone $milestone
    
    if ($result) {
        $createdIssues += $result
        Write-Host "  Success! Issue #$($result.number) - $($result.html_url)" -ForegroundColor Green
        Start-Sleep -Seconds 2
    } else {
        $stillFailed += $issue.Title
        Write-Host "  Failed: $($issue.Title)" -ForegroundColor Red
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "作成完了: $($createdIssues.Count) 個" -ForegroundColor Green
Write-Host "作成失敗: $($stillFailed.Count) 個" -ForegroundColor Red
Write-Host "========================================`n" -ForegroundColor Cyan

if ($createdIssues.Count -gt 0) {
    Write-Host "作成されたIssue一覧:" -ForegroundColor Cyan
    foreach ($issue in $createdIssues) {
        Write-Host "  - #$($issue.number): $($issue.title)" -ForegroundColor White
        Write-Host "    URL: $($issue.html_url)" -ForegroundColor Gray
    }
}

if ($stillFailed.Count -gt 0) {
    Write-Host "`nまだ失敗しているIssue:" -ForegroundColor Red
    foreach ($title in $stillFailed) {
        Write-Host "  - $title" -ForegroundColor Red
    }
}

Write-Host "`n再作成プロセスが完了しました！" -ForegroundColor Cyan

