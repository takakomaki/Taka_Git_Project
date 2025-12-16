param(
    [string]$Repo = "takakomaki/Taka_Git_Project",
    [switch]$CreateTestIssue
)

$ErrorActionPreference = "Stop"

function New-GitHubHeaders([string]$Token) {
    return @{
        "Authorization" = "Bearer $Token"
        "Accept"        = "application/vnd.github.v3+json"
        "User-Agent"    = "Taka-GitHub-Token-Check (PowerShell)"
    }
}

function Invoke-GHWeb([string]$Uri, [string]$Method, [hashtable]$Headers, [string]$BodyJson = $null) {
    $params = @{
        Uri         = $Uri
        Method      = $Method
        Headers     = $Headers
        ErrorAction = "Stop"
    }
    if ($null -ne $BodyJson) {
        $params["Body"] = $BodyJson
        $params["ContentType"] = "application/json"
    }
    return Invoke-WebRequest @params
}

function Parse-Json([string]$Text) {
    if ([string]::IsNullOrWhiteSpace($Text)) { return $null }
    return ($Text | ConvertFrom-Json -ErrorAction Stop)
}

if (-not $env:GITHUB_TOKEN) {
    Write-Host "❌ GITHUB_TOKEN 環境変数が設定されていません。" -ForegroundColor Red
    Write-Host "   先に以下を実行してください：" -ForegroundColor Yellow
    Write-Host "   .\setup_github_token.ps1" -ForegroundColor White
    exit 1
}

$token = ($env:GITHUB_TOKEN ?? "").Trim()
if ([string]::IsNullOrWhiteSpace($token)) {
    Write-Host "❌ GITHUB_TOKEN が空/空白です（改行や空白のみ）。" -ForegroundColor Red
    exit 1
}

$headers = New-GitHubHeaders -Token $token

Write-Host "`n=== ✅ Token validity check (/user) ===" -ForegroundColor Cyan
try {
    $res = Invoke-GHWeb -Uri "https://api.github.com/user" -Method "GET" -Headers $headers
    $user = Parse-Json $res.Content

    Write-Host "✅ Token is valid" -ForegroundColor Green
    Write-Host ("   ユーザー: {0}" -f $user.login) -ForegroundColor Gray

    if ($res.Headers["X-OAuth-Scopes"]) {
        Write-Host ("   Scopes: {0}" -f $res.Headers["X-OAuth-Scopes"]) -ForegroundColor Gray
    } elseif ($res.Headers["X-Accepted-OAuth-Scopes"]) {
        Write-Host ("   Accepted Scopes: {0}" -f $res.Headers["X-Accepted-OAuth-Scopes"]) -ForegroundColor Gray
    } else {
        Write-Host "   Scopes ヘッダが取得できませんでした（Fine-grained token の場合など）。" -ForegroundColor DarkGray
    }
} catch {
    Write-Host "❌ Token check failed (/user)" -ForegroundColor Red
    Write-Host "   例外: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $body = $reader.ReadToEnd()
            Write-Host "   Response: $body" -ForegroundColor DarkGray
        } catch {}
    }
    exit 1
}

Write-Host "`n=== ✅ Repository access check (/repos/{owner}/{repo}) ===" -ForegroundColor Cyan
$repoUrl = "https://api.github.com/repos/$Repo"
try {
    $repoRes = Invoke-GHWeb -Uri $repoUrl -Method "GET" -Headers $headers
    $repoObj = Parse-Json $repoRes.Content
    Write-Host "✅ Repository access: OK" -ForegroundColor Green
    Write-Host ("   リポジトリ: {0} (private={1})" -f $repoObj.full_name, $repoObj.private) -ForegroundColor Gray
} catch {
    Write-Host "❌ Repository access: NG" -ForegroundColor Red
    Write-Host "   リポジトリ: $Repo" -ForegroundColor Red
    Write-Host "   例外: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $body = $reader.ReadToEnd()
            Write-Host "   Response: $body" -ForegroundColor DarkGray
        } catch {}
    }
    exit 1
}

if ($CreateTestIssue) {
    Write-Host "`n=== ✅ Issue create/close test (/issues) ===" -ForegroundColor Cyan
    $issuesUrl = "https://api.github.com/repos/$Repo/issues"
    $title = "[TokenCheck] $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    $payload = @{
        title = $title
        body  = "This issue was created by check_token_permissions.ps1 and will be closed immediately."
    } | ConvertTo-Json -Depth 10

    try {
        $createRes = Invoke-GHWeb -Uri $issuesUrl -Method "POST" -Headers $headers -BodyJson $payload
        $issueObj = Parse-Json $createRes.Content
        Write-Host ("✅ Issue creation: OK (#$($issueObj.number))") -ForegroundColor Green
        Write-Host ("   URL: {0}" -f $issueObj.html_url) -ForegroundColor Gray

        $closeUrl = "https://api.github.com/repos/$Repo/issues/$($issueObj.number)"
        $closePayload = @{ state = "closed" } | ConvertTo-Json
        [void](Invoke-GHWeb -Uri $closeUrl -Method "PATCH" -Headers $headers -BodyJson $closePayload)
        Write-Host "✅ Issue close: OK" -ForegroundColor Green
    } catch {
        Write-Host "❌ Issue create/close: NG" -ForegroundColor Red
        Write-Host "   例外: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            try {
                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                $body = $reader.ReadToEnd()
                Write-Host "   Response: $body" -ForegroundColor DarkGray
            } catch {}
        }
        exit 1
    }
} else {
    Write-Host "`nℹ️ Issue 作成テストはスキップしました（必要なら -CreateTestIssue を付けてください）" -ForegroundColor Yellow
}

Write-Host "`n🎉 完了：Token はこの環境で利用可能です。" -ForegroundColor Cyan


