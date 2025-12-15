# Pull Request作成スクリプト
# Issue #65用のPRを作成

$ErrorActionPreference = "Stop"

$repo = "takakomaki/Taka_Git_Project"
$baseUrl = "https://api.github.com/repos/$repo"

# GitHub Tokenの設定
if (-not $env:GITHUB_TOKEN) {
    Write-Host "GITHUB_TOKEN環境変数が設定されていません。" -ForegroundColor Yellow
    exit 1
}

# UTF-8エンコーディングを明示的に設定
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

# トークンをクリーンアップ（ASCII文字のみ）
$token = $env:GITHUB_TOKEN.Trim()
$tokenBytes = [System.Text.Encoding]::ASCII.GetBytes($token)
$tokenClean = [System.Text.Encoding]::ASCII.GetString($tokenBytes)

$headers = @{
    "Authorization" = "Bearer $tokenClean"
    "Accept" = "application/vnd.github.v3+json"
    "User-Agent" = "PowerShell-Script"
}

# PRのタイトルと本文
$prTitle = "[MVP] Add GPT × Cursor × GitHub collaboration flow to README"
$prBody = @"
Issue #65に基づいて、README.mdに協奏フローを追記しました。

## 変更内容
- README.mdに「GPT × Cursor × GitHub 協奏フロー」セクションを追加
- Issue → 実装 → PR → レビュー → マージの流れを5行で説明

Closes #65
"@

# PR作成
$prUrl = "$baseUrl/pulls"
$prData = @{
    title = $prTitle
    body = $prBody
    head = "issue-65-add-collaboration-flow"
    base = "main"
} | ConvertTo-Json -Depth 10

try {
    Write-Host "Pull Requestを作成しています..." -ForegroundColor Cyan
    $response = Invoke-RestMethod -Uri $prUrl -Method Post -Headers $headers -Body $prData -ContentType "application/json"
    
    Write-Host ""
    Write-Host "✅ Pull Requestが正常に作成されました！" -ForegroundColor Green
    Write-Host ""
    Write-Host "PR番号: #$($response.number)" -ForegroundColor White
    Write-Host "タイトル: $($response.title)" -ForegroundColor White
    Write-Host "URL: $($response.html_url)" -ForegroundColor Cyan
    Write-Host ""
    
    return $response
} catch {
    Write-Host "❌ Pull Request作成に失敗しました: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $statusDescription = $_.Exception.Response.StatusDescription
        Write-Host "ステータスコード: $statusCode" -ForegroundColor Red
        Write-Host "ステータス説明: $statusDescription" -ForegroundColor Red
        
        try {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $responseBody = $reader.ReadToEnd()
            Write-Host "エラー詳細: $responseBody" -ForegroundColor Red
        } catch {
            Write-Host "エラー詳細の取得に失敗しました" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "手動でPRを作成する場合は、以下のURLにアクセスしてください：" -ForegroundColor Yellow
    Write-Host "https://github.com/takakomaki/Taka_Git_Project/pull/new/issue-65-add-collaboration-flow" -ForegroundColor Cyan
    
    exit 1
}

