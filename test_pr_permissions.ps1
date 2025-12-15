# PR作成権限テストスクリプト

$ErrorActionPreference = "Stop"

if (-not $env:GITHUB_TOKEN) {
    Write-Host "❌ GITHUB_TOKEN環境変数が設定されていません。" -ForegroundColor Red
    exit 1
}

# UTF-8エンコーディングを明示的に設定
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

# トークンをクリーンアップ
$token = $env:GITHUB_TOKEN.Trim()
$tokenBytes = [System.Text.Encoding]::ASCII.GetBytes($token)
$tokenClean = [System.Text.Encoding]::ASCII.GetString($tokenBytes)

$repo = "takakomaki/Taka_Git_Project"
$baseUrl = "https://api.github.com/repos/$repo"

$headers = @{
    "Authorization" = "Bearer $tokenClean"
    "Accept" = "application/vnd.github.v3+json"
    "User-Agent" = "PowerShell-Script"
}

Write-Host "PR作成権限をテストしています..." -ForegroundColor Cyan
Write-Host ""

# 1. リポジトリ情報を取得
try {
    $repoInfo = Invoke-RestMethod -Uri $baseUrl -Method Get -Headers $headers
    Write-Host "✅ リポジトリ情報取得: OK" -ForegroundColor Green
    Write-Host "   リポジトリ: $($repoInfo.full_name)" -ForegroundColor White
    Write-Host "   プライベート: $($repoInfo.private)" -ForegroundColor White
    Write-Host ""
} catch {
    Write-Host "❌ リポジトリ情報取得: FAILED" -ForegroundColor Red
    Write-Host "   エラー: $_" -ForegroundColor Red
    exit 1
}

# 2. ブランチ一覧を取得
try {
    $branchesUrl = "$baseUrl/branches"
    $branches = Invoke-RestMethod -Uri $branchesUrl -Method Get -Headers $headers
    Write-Host "✅ ブランチ一覧取得: OK" -ForegroundColor Green
    Write-Host "   ブランチ数: $($branches.Count)" -ForegroundColor White
    
    $targetBranch = $branches | Where-Object { $_.name -eq "issue-65-add-collaboration-flow" }
    if ($targetBranch) {
        Write-Host "   ✅ ターゲットブランチ 'issue-65-add-collaboration-flow' が見つかりました" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  ターゲットブランチ 'issue-65-add-collaboration-flow' が見つかりません" -ForegroundColor Yellow
    }
    Write-Host ""
} catch {
    Write-Host "❌ ブランチ一覧取得: FAILED" -ForegroundColor Red
    Write-Host "   エラー: $_" -ForegroundColor Red
    exit 1
}

# 3. PR作成を試行（実際には作成しない）
Write-Host "PR作成APIへのアクセス権限を確認中..." -ForegroundColor Cyan

# PR作成エンドポイントにGETリクエストを送って、エラーメッセージを確認
try {
    # 実際にはPRを作成せず、権限エラーを確認するため、無効なデータで試行
    $testPrUrl = "$baseUrl/pulls"
    $testPrData = @{
        title = "Test PR - This should fail"
        head = "nonexistent-branch"
        base = "main"
    } | ConvertTo-Json
    
    try {
        $testResponse = Invoke-RestMethod -Uri $testPrUrl -Method Post -Headers $headers -Body $testPrData -ContentType "application/json"
        Write-Host "⚠️  予期しない成功（テストPRが作成された可能性があります）" -ForegroundColor Yellow
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        
        if ($statusCode -eq 403) {
            Write-Host "❌ PR作成権限: DENIED (403)" -ForegroundColor Red
            Write-Host ""
            Write-Host "解決方法:" -ForegroundColor Yellow
            Write-Host "1. GitHubでPersonal Access Tokenの権限を確認してください" -ForegroundColor White
            Write-Host "2. 'repo'スコープが有効になっているか確認してください" -ForegroundColor White
            Write-Host "3. Fine-grained tokenを使用している場合、以下を確認:" -ForegroundColor White
            Write-Host "   - Repository access: 適切なリポジトリが選択されているか" -ForegroundColor White
            Write-Host "   - Permissions > Pull requests: Read and write" -ForegroundColor White
            Write-Host ""
        } elseif ($statusCode -eq 422) {
            Write-Host "✅ PR作成権限: OK (422エラーは予想通り - ブランチが存在しないため)" -ForegroundColor Green
            Write-Host "   実際のPR作成は可能です" -ForegroundColor White
        } else {
            Write-Host "⚠️  予期しないエラー: $statusCode" -ForegroundColor Yellow
            Write-Host "   エラー: $_" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "❌ PR作成権限テスト: FAILED" -ForegroundColor Red
    Write-Host "   エラー: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "テスト完了" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

