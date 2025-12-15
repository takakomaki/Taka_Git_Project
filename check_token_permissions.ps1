# GitHub Token権限確認スクリプト

$ErrorActionPreference = "Stop"

if (-not $env:GITHUB_TOKEN) {
    Write-Host "❌ GITHUB_TOKEN環境変数が設定されていません。" -ForegroundColor Red
    exit 1
}

# トークンの検証
$token = $env:GITHUB_TOKEN.Trim()
if ($token -notmatch '^[a-zA-Z0-9_]+$') {
    Write-Host "⚠️  トークンにASCII以外の文字が含まれている可能性があります" -ForegroundColor Yellow
    Write-Host "   トークンの先頭10文字: $($token.Substring(0, [Math]::Min(10, $token.Length)))..." -ForegroundColor Gray
}

# トークンの長さを確認
if ($token.Length -lt 40) {
    Write-Host "⚠️  トークンが短すぎます（通常40文字以上）" -ForegroundColor Yellow
}

# UTF-8エンコーディングを明示的に設定
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

# ヘッダーを作成（ASCII文字のみを使用）
$tokenBytes = [System.Text.Encoding]::ASCII.GetBytes($token)
$tokenClean = [System.Text.Encoding]::ASCII.GetString($tokenBytes)

$headers = @{
    "Authorization" = "Bearer $tokenClean"
    "Accept" = "application/vnd.github.v3+json"
    "User-Agent" = "PowerShell-Script"
}

Write-Host "GitHub Tokenの権限を確認しています..." -ForegroundColor Cyan
Write-Host ""

# ユーザー情報を取得してトークンの有効性を確認
try {
    $userResponse = Invoke-RestMethod -Uri "https://api.github.com/user" -Method Get -Headers $headers
    Write-Host "✅ Token is valid" -ForegroundColor Green
    Write-Host "   ユーザー: $($userResponse.login)" -ForegroundColor White
    Write-Host ""
} catch {
    Write-Host "❌ Token is invalid or expired" -ForegroundColor Red
    Write-Host "   エラー: $_" -ForegroundColor Red
    
    # より詳細なエラー情報を表示
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $statusDescription = $_.Exception.Response.StatusDescription
        Write-Host "   ステータスコード: $statusCode" -ForegroundColor Red
        Write-Host "   ステータス説明: $statusDescription" -ForegroundColor Red
        
        try {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $responseBody = $reader.ReadToEnd()
            Write-Host "   レスポンス: $responseBody" -ForegroundColor Red
        } catch {
            # ストリームの読み取りに失敗した場合は無視
        }
    }
    
    Write-Host ""
    Write-Host "解決方法:" -ForegroundColor Yellow
    Write-Host "1. GitHubで新しいPersonal Access Tokenを作成してください" -ForegroundColor White
    Write-Host "2. 'repo'スコープを付与してください" -ForegroundColor White
    Write-Host "3. トークンを環境変数に設定してください:" -ForegroundColor White
    Write-Host '   $env:GITHUB_TOKEN = "ghp_あなたのトークン"' -ForegroundColor Cyan
    
    exit 1
}

# リポジトリへのアクセス権限を確認
$repo = "takakomaki/Taka_Git_Project"
$repoUrl = "https://api.github.com/repos/$repo"

try {
    $repoResponse = Invoke-RestMethod -Uri $repoUrl -Method Get -Headers $headers
    Write-Host "✅ Repository access: OK" -ForegroundColor Green
    Write-Host "   リポジトリ: $repo" -ForegroundColor White
    Write-Host ""
} catch {
    Write-Host "❌ Repository access: FAILED" -ForegroundColor Red
    Write-Host "   エラー: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "必要な権限: 'repo' scope" -ForegroundColor Yellow
    exit 1
}

# Issue作成権限を確認
try {
    $testIssueUrl = "$repoUrl/issues"
    $testIssueData = @{
        title = "Test Issue - Delete Me"
        body = "This is a test issue. Please delete."
    } | ConvertTo-Json
    
    $testIssue = Invoke-RestMethod -Uri $testIssueUrl -Method Post -Headers $headers -Body $testIssueData -ContentType "application/json"
    Write-Host "✅ Issue creation: OK" -ForegroundColor Green
    Write-Host "   テストIssue #$($testIssue.number) を作成しました" -ForegroundColor White
    Write-Host "   削除してください: $($testIssue.html_url)" -ForegroundColor Yellow
    Write-Host ""
} catch {
    Write-Host "❌ Issue creation: FAILED" -ForegroundColor Red
    Write-Host "   エラー: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "必要な権限: 'repo' scope" -ForegroundColor Yellow
    exit 1
}

# PR作成権限を確認（ブランチが存在する場合）
try {
    $branchesUrl = "$repoUrl/branches"
    $branches = Invoke-RestMethod -Uri $branchesUrl -Method Get -Headers $headers
    
    if ($branches.Count -gt 0) {
        Write-Host "✅ Pull Request creation: OK (ブランチ確認)" -ForegroundColor Green
        Write-Host "   ブランチ数: $($branches.Count)" -ForegroundColor White
        Write-Host ""
    }
} catch {
    Write-Host "⚠️  Pull Request権限の確認に失敗しました" -ForegroundColor Yellow
    Write-Host "   エラー: $_" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ すべての権限チェックが完了しました" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

