# GitHub Personal Access Token 設定ガイド
## Cursor用のGitHub API権限設定

---

## 📋 概要

このガイドでは、CursorがGitHub APIを使用するために必要なPersonal Access Tokenの作成と設定方法を説明します。

---

## 🔑 Step 1: GitHubでトークンを作成

### 1. GitHubにアクセス
- https://github.com にログイン

### 2. 設定画面を開く
1. 右上のアイコンをクリック
2. **Settings**（設定）を選択

### 3. Developer settingsに移動
1. 左メニューの一番下までスクロール
2. **Developer settings** をクリック

### 4. Personal access tokensを選択
1. **Personal access tokens** をクリック
2. **Tokens (classic)** を選択
   - ⚠️ **Fine-grained tokens**ではなく、**Tokens (classic)**を選択してください

### 5. 新しいトークンを生成
1. **Generate new token (classic)** をクリック
2. 必要に応じてパスワードを入力

### 6. トークンの設定

#### Note（メモ）
- 例: `Cursor GitHub API用`
- 用途が分かる名前を入力

#### Expiration（有効期限）
- 推奨: **90日** または **1年**
- セキュリティのため、長すぎる期間は避ける

#### Select scopes（権限の選択）
**必須の権限:**
- ✅ **`repo`** - Full control of private repositories
  - これにチェックを入れると、以下が自動的に含まれます:
    - `repo:status` - リポジトリのステータスへのアクセス
    - `repo_deployment` - デプロイメントへのアクセス
    - `public_repo` - パブリックリポジトリへのアクセス
    - `repo:invite` - リポジトリへの招待
    - `security_events` - セキュリティイベントへのアクセス

**`repo`スコープで可能になること:**
- ✅ Issueの作成・編集・削除
- ✅ Pull Requestの作成・編集・マージ
- ✅ リポジトリへの読み書き
- ✅ ブランチの作成・削除
- ✅ コミットの作成

### 7. トークンを生成
1. **Generate token** をクリック
2. **表示されたトークンを必ずコピー**
   - ⚠️ **この画面を閉じると、トークンは再表示できません！**
   - トークンは `ghp_` で始まる40文字以上の文字列です

---

## 💻 Step 2: 環境変数に設定

### 方法1: スクリプトを使用（推奨）

```powershell
cd Taka_Git_Project
.\setup_github_token.ps1
```

スクリプトがトークンの入力を求めますので、コピーしたトークンを貼り付けてください。

### 方法2: 手動で設定

#### PowerShellで設定（永続的）

```powershell
# ユーザー環境変数として永続的に設定
[System.Environment]::SetEnvironmentVariable("GITHUB_TOKEN", "ghp_あなたのトークン", "User")

# 現在のセッションにも反映
$env:GITHUB_TOKEN = [System.Environment]::GetEnvironmentVariable("GITHUB_TOKEN", "User")
```

#### 一時的な設定（現在のセッションのみ）

```powershell
$env:GITHUB_TOKEN = "ghp_あなたのトークン"
```

---

## ✅ Step 3: 設定の確認

### 権限確認スクリプトを実行

```powershell
cd Taka_Git_Project
.\check_token_permissions.ps1
```

必要なら、Issueの作成→クローズまで含めてチェックできます（権限不足の検出に強いです）：

```powershell
cd Taka_Git_Project
.\check_token_permissions.ps1 -CreateTestIssue
```

以下のような出力が表示されれば成功です：

```
✅ Token is valid
   ユーザー: takakomaki

✅ Repository access: OK
   リポジトリ: takakomaki/Taka_Git_Project

✅ Issue creation: OK
   テストIssue #XX を作成しました

✅ Pull Request creation: OK (ブランチ確認)
   ブランチ数: X
```

---

## 🔒 セキュリティのベストプラクティス

1. **トークンは秘密に**
   - トークンをGitHubにコミットしない
   - トークンを他人と共有しない
   - スクリーンショットに含めない

2. **有効期限を設定**
   - 長すぎる有効期限は避ける
   - 定期的にトークンを更新する

3. **最小権限の原則**
   - 必要な権限のみを付与する
   - 使用していないトークンは削除する

4. **トークンの無効化**
   - 漏洩が疑われる場合は即座に無効化
   - GitHubの設定画面から削除可能

---

## 🛠️ トラブルシューティング

### エラー: "Resource not accessible by personal access token (403)"

**原因**: トークンの権限が不足している

**解決方法**:
1. GitHubでトークンの権限を確認
2. `repo`スコープが有効になっているか確認
3. 必要に応じて新しいトークンを作成

### エラー: "Request headers must contain only ASCII characters"

**原因**: トークンに非ASCII文字が含まれている

**解決方法**:
1. トークンを再コピー
2. 余分な空白や改行がないか確認
3. 環境変数を再設定

### エラー: "Token is invalid or expired"

**原因**: トークンが無効または期限切れ

**解決方法**:
1. GitHubでトークンの有効期限を確認
2. 必要に応じて新しいトークンを作成
3. 環境変数を更新

---

## 📝 環境変数の確認方法

### 現在の設定を確認

```powershell
# 環境変数の値を確認（マスク表示）
$token = [System.Environment]::GetEnvironmentVariable("GITHUB_TOKEN", "User")
if ($token) {
    Write-Host "トークンは設定されています（長さ: $($token.Length)文字）"
} else {
    Write-Host "トークンが設定されていません"
}
```

### 環境変数の削除

```powershell
# 環境変数を削除
[System.Environment]::SetEnvironmentVariable("GITHUB_TOKEN", $null, "User")
```

---

## 🎯 次のステップ

設定が完了したら、以下のコマンドでCursorの機能をテストできます：

```powershell
cd Taka_Git_Project

# 権限確認
.\check_token_permissions.ps1

# Issue作成テスト
.\create_demo_issue.ps1

# PR作成テスト
.\create_pr.ps1
```

---

**作成日**: 2025-12-15  
**更新日**: 2025-12-15

