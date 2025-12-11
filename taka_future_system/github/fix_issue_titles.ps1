# Issueタイトル修正スクリプト
# 文字化けしたIssueタイトルを修正
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

# Issue更新関数
function Update-IssueTitle {
    param($IssueNumber, $NewTitle)
    
    $issueUrl = "$baseUrl/issues/$IssueNumber"
    
    # まず現在のIssueを取得
    try {
        $currentIssue = Invoke-RestMethod -Uri $issueUrl -Method Get -Headers $headers
        
        # タイトルと本文を更新
        $body = @{
            title = $NewTitle
            body = $currentIssue.body
        } | ConvertTo-Json -Depth 10
        
        $response = Invoke-RestMethod -Uri $issueUrl -Method Patch -Headers $headers -Body $body -ContentType "application/json; charset=utf-8"
        return $response
    } catch {
        Write-Host "Error updating issue #$IssueNumber : $_" -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Response: $responseBody" -ForegroundColor Red
        }
        return $null
    }
}

# 修正が必要なIssueのマッピング
$fixes = @{
    "#52" = "[Value] Define: 深さ×対象者マトリクス拡張"
    "#53" = "[Value] Visualize: 価値マップMermaidモデル"
    "#51" = "[Integration] Automate: Dashboard定期更新"
    "#50" = "[Integration] Visualize: 統合システムMermaid図"
    "#49" = "[Integration] Develop: 時間配分モデル"
    "#48" = "[Integration] Model: 価値増幅ノード（Resonance Nodes）"
    "#47" = "[Integration] Design: 全体一筆書き構造モデル"
    "#46" = "[Brand] Visualize: 色・構図・余白ルール"
    "#45" = "[Brand] Document: 英語ブランド表現体系化"
    "#44" = "[Brand] Align: Value・Businessとの統合"
    "#43" = "[Brand] Develop: ブランドガイドテンプレ更新"
    "#42" = "[Brand] Define: 世界観の言語化（真・愛・善・美）"
    "#41" = "[Infrastructure] Document: 運用ルール（命名・構造）"
    "#40" = "[Infrastructure] Design: GitHub Projects ダッシュボード"
    "#39" = "[Infrastructure] Develop: 自動バックアップScript"
    "#38" = "[Infrastructure] Automate: Obsidian ⇄ GitHub 自動同期"
    "#37" = "[Infrastructure] Setup: 3コアフォルダ構造の最適化"
    "#36" = "[AI-Orchestra] Document: AI利用ガイドライン"
    "#35" = "[AI-Orchestra] Design: AI協奏ルールモデル"
    "#34" = "[AI-Orchestra] Develop: Input Level 1〜3テンプレ生成"
    "#33" = "[AI-Orchestra] Automate: GPTレビューWorkflow構築"
    "#32" = "[AI-Orchestra] Define: 各AIプロトコル定義"
    "#31" = "[Business] Align: カリキュラム体系との整合"
    "#30" = "[Business] Visualize: 事業体系Mermaidモデル"
    "#29" = "[Business] Automate: 収益予測アルゴリズム改善"
    "#28" = "[Business] Develop: 商品ライン（入口→コア→成長→継続）"
    "#27" = "[Business] Model: 収益源構造モデル"
    "#26" = "[Value] Align: Value体系とブランド表現の整合"
    "#25" = "[Value] Evaluate: 価格帯体系の整合性チェック"
    "#24" = "[Value] Model: 価値レイヤーのJSONマッピング"
    "#23" = "[Curriculum] Align: カリキュラム体系とビジネス導線の整合"
    "#22" = "[Curriculum] Develop: レベル別サブスキル体系"
    "#21" = "[Curriculum] Model: カリキュラム全体Mermaid化"
    "#20" = "[Curriculum] Design: 学習ステップ構造（Input → Resonance → Output）"
    "#19" = "[Curriculum] Define: レベル到達点（Transformation Points）"
}

Write-Host "`n=== Issueタイトル修正を開始します ===" -ForegroundColor Cyan
Write-Host "合計 $($fixes.Count) 個のIssueを修正します`n" -ForegroundColor Cyan

$updatedIssues = @()
$failedIssues = @()

foreach ($issueNum in $fixes.Keys) {
    $issueNumber = $issueNum -replace '#', ''
    $newTitle = $fixes[$issueNum]
    
    Write-Host "Updating Issue #$issueNumber : $newTitle" -ForegroundColor Yellow
    
    $result = Update-IssueTitle -IssueNumber $issueNumber -NewTitle $newTitle
    
    if ($result) {
        $updatedIssues += $result
        Write-Host "  Success! Updated: $($result.html_url)" -ForegroundColor Green
        Start-Sleep -Seconds 1  # Rate limiting対策
    } else {
        $failedIssues += $issueNum
        Write-Host "  Failed: Issue #$issueNumber" -ForegroundColor Red
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "修正完了: $($updatedIssues.Count) 個" -ForegroundColor Green
Write-Host "修正失敗: $($failedIssues.Count) 個" -ForegroundColor Red
Write-Host "========================================`n" -ForegroundColor Cyan

if ($updatedIssues.Count -gt 0) {
    Write-Host "修正されたIssue一覧:" -ForegroundColor Cyan
    foreach ($issue in $updatedIssues) {
        Write-Host "  - #$($issue.number): $($issue.title)" -ForegroundColor White
        Write-Host "    URL: $($issue.html_url)" -ForegroundColor Gray
    }
}

if ($failedIssues.Count -gt 0) {
    Write-Host "`n修正に失敗したIssue:" -ForegroundColor Red
    foreach ($issueNum in $failedIssues) {
        Write-Host "  - $issueNum" -ForegroundColor Red
    }
}

Write-Host "`nタイトル修正プロセスが完了しました！" -ForegroundColor Cyan

