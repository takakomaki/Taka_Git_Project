# GitHub Issues作成手順

## 方法1: GitHub CLIを使用（推奨）

GitHub CLIがインストールされている場合：

```bash
# GitHub CLIでログイン
gh auth login

# Issue作成スクリプトを実行
cd taka_future_system/github
powershell -ExecutionPolicy Bypass -File create_issues.ps1
```

## 方法2: GitHub APIを直接使用

PowerShellで直接APIを呼び出す場合：

```powershell
# GitHub Tokenを設定
$env:GITHUB_TOKEN = "your_token_here"

# スクリプトを実行
cd taka_future_system/github
powershell -ExecutionPolicy Bypass -File create_issues_simple.ps1
```

## 方法3: 手動でIssueを作成

`Issue_自動生成フルプロンプト.md` の内容に沿って、GitHubのWeb UIから手動でIssueを作成することもできます。

## 注意事項

- GitHub APIのRate Limitに注意してください（1時間あたり5,000リクエスト）
- 30個のIssueを一度に作成する場合、適切な間隔（1-2秒）を空けてください
- Milestone「Taka Future System v1.0」が存在しない場合は、自動的に作成されます

