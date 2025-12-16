param(
    [switch]$NoPersist,
    [switch]$Visible
)

$ErrorActionPreference = "Stop"

function Read-SecretLine([string]$Prompt) {
    $secure = Read-Host -Prompt $Prompt -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try {
        $s = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
        if ($null -eq $s) { return "" }
        return $s
    } finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    }
}

$persistUser = -not $NoPersist

Write-Host "GitHub Personal Access Token (PAT) を設定します。" -ForegroundColor Cyan
Write-Host "  - 変数名: GITHUB_TOKEN" -ForegroundColor Gray
Write-Host "  - ヒント: 先頭は通常 ghp_ / github_pat_ です（末尾の改行や空白が混ざらないように注意）" -ForegroundColor Gray
Write-Host "  - 入力がうまく貼り付けできない場合: -Visible を付けて再実行してください" -ForegroundColor DarkGray

$token =
    if ($Visible) {
        Read-Host -Prompt "GitHub Token を貼り付けて Enter（表示入力モード）"
    } else {
        Read-SecretLine "GitHub Token を貼り付けて Enter"
    }

if ($null -eq $token) { $token = "" }
$token = ($token.ToString()).Trim()

if ([string]::IsNullOrWhiteSpace($token)) {
    Write-Host "❌ Token が空です。中止します。" -ForegroundColor Red
    exit 1
}

# ざっくり妥当性チェック（短すぎる・形式が違う場合は設定しない）
if ($token.Length -lt 20) {
    Write-Host "❌ Token が短すぎます（長さ: $($token.Length)）。貼り付けに失敗している可能性が高いので設定しません。" -ForegroundColor Red
    Write-Host "   対処: もう一度貼り付け / うまくいかなければ -Visible を付けて再実行" -ForegroundColor Yellow
    exit 1
}
if ($token -notmatch '^(ghp_|github_pat_)') {
    Write-Host "⚠️ Token の先頭が想定と異なります（ghp_ / github_pat_ 以外）。" -ForegroundColor Yellow
    Write-Host "   問題ない場合もありますが、Token を取り違えていないか確認してください。" -ForegroundColor Yellow
}

# current session
$env:GITHUB_TOKEN = $token
Write-Host "✅ 現在の PowerShell セッションに GITHUB_TOKEN を設定しました（長さ: $($token.Length)）" -ForegroundColor Green

if ($persistUser) {
    [System.Environment]::SetEnvironmentVariable("GITHUB_TOKEN", $token, "User")
    Write-Host "✅ ユーザー環境変数（永続）にも設定しました" -ForegroundColor Green
    Write-Host "   ※ 既に開いているターミナルには反映されないので、必要なら再起動してください" -ForegroundColor DarkGray
} else {
    Write-Host "ℹ️ 永続化は行いませんでした（このセッションのみ）" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "次は疎通確認を実行してください：" -ForegroundColor Cyan
Write-Host "  .\check_token_permissions.ps1" -ForegroundColor White


