# リポジトリ構造ツリー（文字化けなし / UTF-8）

このファイルは `C:\doc\Taka_Git_Project` のフォルダ・ファイル構造を、AIが参照しやすいようにツリー化したものです。

## 生成方法

```powershell
pwsh -NoProfile -File .\tools\tree_utf8.ps1 -Path . -OutputFile .\TREE_UTF8.txt -ExcludeGit
```

## ツリー（`.git` 除外）

```text
Taka_Git_Project
├── .github
│   └── workflows
│       └── ai-orchestra-issues.yml
├── memory
│   ├── claude
│   │   ├── .gitkeep
│   │   ├── 20251202_claude.bak
│   │   ├── 20251202_claude.txt
│   │   └── claude_orchestra_bridge.md
│   ├── cursor
│   │   └── .gitkeep
│   ├── deepseek
│   │   ├── .gitkeep
│   │   └── 251202_deepseek.txt
│   ├── gemini
│   │   ├── .gitkeep
│   │   └── 251202_Gemini.txt
│   ├── gpt
│   │   ├── .gitkeep
│   │   ├── AI_orchestra_Hikitugi.md
│   │   └── issue-log.md
│   ├── grok
│   │   ├── .gitkeep
│   │   └── 251202_grok.txt
│   ├── index
│   │   ├── ai_orchestra_cli_starter_prompts.md
│   │   ├── Bedrock_Principles.md
│   │   ├── MASTER_COMMAND.md
│   │   ├── Roles.md
│   │   ├── UNIFIED_BRIEF.md
│   │   └── welcome.md
│   └── .gitkeep
├── taka_future_system
│   ├── github
│   │   ├── 2025-12-11_作業記録.md
│   │   ├── create_all_issues.ps1
│   │   ├── create_failed_issues.ps1
│   │   ├── create_issues_api.ps1
│   │   ├── create_issues_simple.ps1
│   │   ├── create_issues_test.ps1
│   │   ├── create_issues.ps1
│   │   ├── create_memory_eventlog_issues.ps1
│   │   ├── dashboard_template.md
│   │   ├── fix_issue_bodies.ps1
│   │   ├── fix_issue_titles.ps1
│   │   ├── GitHub_Epic_Issue_Templates.md
│   │   ├── GitHub_Epic_Taka未来計画.md
│   │   ├── GitHub_登録手順.md
│   │   ├── GPT_ラベル色設定への感想.md
│   │   ├── Issue_自動生成フルプロンプト.md
│   │   ├── Issue作成手順.md
│   │   └── update_label_colors.ps1
│   ├── implementations
│   │   ├── .github
│   │   │   └── workflows
│   │   │       └── auto-sync.yml
│   │   ├── ai_orchestra_protocols.json
│   │   ├── brand_guide_template.md
│   │   ├── business_architecture.map.md
│   │   ├── curriculum_structure.yaml
│   │   ├── dashboard_template.md
│   │   ├── infrastructure_setup_script.ps1
│   │   ├── integrated_system_map.md
│   │   ├── README.md
│   │   ├── revenue_prediction.py
│   │   ├── taka_time_allocation_model.json
│   │   └── value_proposition_matrix.json
│   ├── master_files
│   │   ├── ai_orchestra_blueprint.md
│   │   ├── business_architecture_map.md
│   │   ├── curriculum_master_map.md
│   │   ├── infrastructure_setup.md
│   │   ├── taka_brand_bible.md
│   │   ├── taka_integrated_system_map.md
│   │   └── value_proposition_matrix.md
│   ├── memory
│   │   └── events
│   │       ├── _TEMPLATE_decision.md
│   │       ├── _TEMPLATE_insight.md
│   │       ├── _TEMPLATE_shift.md
│   │       ├── 2025-12-12_insight_claude_remember_not_fix.md
│   │       └── 2025-12-12_insight_gemini_translate_wisdom.md
│   └── README.md
├── tools
│   └── tree_utf8.ps1
├── .gitignore
├── 1st_branch.txt
├── check_token_permissions.ps1
├── CONTEXT_PACK.md
├── cursor_ファイルPush指示文.txt
├── GitHub_Token_設定ガイド.md
├── GitHub超初心者ガイド.md
├── README.md
└── setup_github_token.ps1
```


