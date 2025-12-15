# GitHub Issue作成スクリプト
# GPT × Cursor × GitHub 協奏デモ用タスク

$ErrorActionPreference = "Stop"

$repo = "takakomaki/Taka_Git_Project"
$baseUrl = "https://api.github.com/repos/$repo"

# GitHub Tokenの設定（環境変数から取得、または直接設定）
if (-not $env:GITHUB_TOKEN) {
    Write-Host "GITHUB_TOKEN環境変数が設定されていません。" -ForegroundColor Yellow
    Write-Host "GitHub Personal Access Tokenを設定してください：" -ForegroundColor Yellow
    Write-Host '$env:GITHUB_TOKEN = "your_token_here"' -ForegroundColor Cyan
    Write-Host ""
    Write-Host "または、以下のコマンドで設定できます：" -ForegroundColor Yellow
    Write-Host 'Read-Host "GitHub Tokenを入力してください" | ForEach-Object { $env:GITHUB_TOKEN = $_ }' -ForegroundColor Cyan
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $env:GITHUB_TOKEN"
    "Accept" = "application/vnd.github.v3+json"
    "User-Agent" = "PowerShell-Script"
}

# Issueのタイトルと本文
$issueTitle = "[MVP] GPT × Cursor × GitHub 協奏デモ用タスク"

$issueBody = @"
## Why（なぜ）
グループコンサルで、
GPT × Cursor × GitHub を連携させて
「AIと人が協奏して仕事を進める最小構成（MVP）」を
実際の流れとして共有するため。

## What（やること）
- 小さな変更（ドキュメント追加または軽微な修正）を1件行う
- Cursorを使って作業し、Pull Requestを作成する
- 人間（Taka）がレビューし、マージするところまで進める

## Done（完了条件）
- このIssueに紐づくPRが1つマージされていること
- README または docs に、協奏フロー（5行程度）が追記されていること

## Notes
- 完璧さより「一連の流れが見えること」を最優先
- グループコンサルで画面共有できる状態をゴールとする
"@

# Issue作成
$issueUrl = "$baseUrl/issues"
$issueData = @{
    title = $issueTitle
    body = $issueBody
    labels = @("mvp", "demo")
} | ConvertTo-Json -Depth 10

try {
    Write-Host "Issueを作成しています..." -ForegroundColor Cyan
    $response = Invoke-RestMethod -Uri $issueUrl -Method Post -Headers $headers -Body $issueData -ContentType "application/json"
    
    Write-Host ""
    Write-Host "✅ Issueが正常に作成されました！" -ForegroundColor Green
    Write-Host ""
    Write-Host "Issue番号: #$($response.number)" -ForegroundColor White
    Write-Host "タイトル: $($response.title)" -ForegroundColor White
    Write-Host "URL: $($response.html_url)" -ForegroundColor Cyan
    Write-Host ""
    
    return $response
} catch {
    Write-Host "❌ Issue作成に失敗しました: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "エラー詳細: $responseBody" -ForegroundColor Red
    }
    exit 1
}

