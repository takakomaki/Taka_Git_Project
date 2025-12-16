# taka git project
プロジェクト

## GPT × Cursor × GitHub 協奏フロー

1. Issueを作成して作業内容を明確にする
2. Cursorで実装・修正を行う
3. Pull Requestを作成して変更を提案する
4. 人間がレビューしてフィードバックする
5. レビュー後にマージして完了とする

※ このフローは Issue #65 を起点に実際に運用した記録です。

## フォルダ/ファイル構造（文字化けなしでツリー生成）

日本語ファイル名が `tree` コマンドで文字化けする場合は、UTF-8でツリーを生成してください。

```powershell
pwsh -NoProfile -File .\\tools\\tree_utf8.ps1 -Path . -OutputFile .\\TREE_UTF8.txt -ExcludeGit
```