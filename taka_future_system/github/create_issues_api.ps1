# GitHub Issues 自動生成スクリプト（GitHub API直接使用版）
# Taka Future Orchestration System
# Version: 1.0

$ErrorActionPreference = "Stop"

$repo = "takakomaki/Taka_Git_Project"
$baseUrl = "https://api.github.com/repos/$repo"

# GitHub Tokenの設定（環境変数から取得、または直接設定）
if (-not $env:GITHUB_TOKEN) {
    Write-Host "GITHUB_TOKEN環境変数が設定されていません。" -ForegroundColor Yellow
    Write-Host "GitHub Personal Access Tokenを設定してください：" -ForegroundColor Yellow
    Write-Host '$env:GITHUB_TOKEN = "your_token_here"' -ForegroundColor Cyan
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $env:GITHUB_TOKEN"
    "Accept" = "application/vnd.github.v3+json"
    "User-Agent" = "PowerShell-Script"
}

# Milestoneの作成または取得
function Get-Or-Create-Milestone {
    $milestoneUrl = "$baseUrl/milestones?state=open"
    
    # 既存のMilestoneを確認
    try {
        $milestones = Invoke-RestMethod -Uri $milestoneUrl -Method Get -Headers $headers
        $existing = $milestones | Where-Object { $_.title -eq "Taka Future System v1.0" }
        if ($existing) {
            Write-Host "Milestone already exists: Taka Future System v1.0 (#$($existing.number))" -ForegroundColor Green
            return $existing.number
        }
    } catch {
        Write-Host "Error checking milestones: $_" -ForegroundColor Yellow
    }
    
    # Milestoneを作成
    $milestoneUrl = "$baseUrl/milestones"
    $body = @{
        title = "Taka Future System v1.0"
        description = "Taka Future Orchestration System v1.0 - 7つのマスターファイルと実装"
        state = "open"
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri $milestoneUrl -Method Post -Headers $headers -Body $body -ContentType "application/json"
        Write-Host "Milestone created: Taka Future System v1.0 (#$($response.number))" -ForegroundColor Green
        return $response.number
    } catch {
        Write-Host "Error creating milestone: $_" -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Response: $responseBody" -ForegroundColor Red
        }
        return $null
    }
}

# Issueの作成
function New-GitHubIssue {
    param(
        [string]$Title,
        [string]$Body,
        [string[]]$Labels,
        [int]$Milestone
    )
    
    $issueUrl = "$baseUrl/issues"
    $issueBody = @{
        title = $Title
        body = $Body
        labels = $Labels
    }
    
    if ($Milestone) {
        $issueBody.milestone = $Milestone
    }
    
    $jsonBody = $issueBody | ConvertTo-Json -Depth 10
    
    try {
        $response = Invoke-RestMethod -Uri $issueUrl -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json"
        return $response
    } catch {
        Write-Host "Error creating issue '$Title': $_" -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Response: $responseBody" -ForegroundColor Red
        }
        return $null
    }
}

# Issue定義テンプレート関数
function Get-IssueBody {
    param(
        [string]$Purpose,
        [string]$MasterFile,
        [string[]]$Tasks,
        [string]$ExpectedOutput,
        [string]$RelatedIssues = "なし（初回）"
    )
    
    $tasksMarkdown = ($Tasks | ForEach-Object { "- [ ] $_" }) -join [Environment]::NewLine
    
    $body = "## Purpose`nこのIssueの目的：`n$Purpose`n`n## Related Master File`nこのIssueは以下のマスターファイルを参照します：`n- taka_future_system/master_files/$MasterFile`n`n## Tasks`n$tasksMarkdown`n- [ ] Review & Alignment with Master File`n`n## Expected Output`n$ExpectedOutput`n`n## Links`n- 関連Issue: $RelatedIssues`n- 関連Epic: Taka Future Orchestration System`n`n## Labels`n- domain: (各Issueで設定)`n- status: todo`n`n## Milestone`n- Taka Future System v1.0"
    
    return $body
}

# Milestone取得
Write-Host "`n=== Milestone確認中 ===" -ForegroundColor Cyan
$milestoneNumber = Get-Or-Create-Milestone

if (-not $milestoneNumber) {
    Write-Host "Milestoneの作成に失敗しました。続行します..." -ForegroundColor Yellow
}

Write-Host "`n=== GitHub Issues作成を開始します ===" -ForegroundColor Cyan
Write-Host "合計 30個のIssueを作成します`n" -ForegroundColor Cyan

# Issue定義（全30個）
$issues = @()

# CURRICULUM Issues (5個)
$issues += @{
    Title = "[Curriculum] Define: レベル到達点（Transformation Points）"
    Body = Get-IssueBody -Purpose "Lv1〜Lv5の各レベルの到達点（Transformation Points）を明確に定義する" -MasterFile "curriculum_master_map.md" -Tasks @("Step1: Lv1〜Lv5の各レベルのTransformation Pointsを詳細に定義", "Step2: 各Transformation Pointの測定可能な指標を設定", "Step3: Transformation PointsをYAML形式でコード化") -ExpectedOutput "- Transformation Points定義ファイル（YAML形式）`n- 保存先: taka_future_system/implementations/transformation_points.yaml"
    Labels = @("curriculum", "todo")
}

$issues += @{
    Title = "[Curriculum] Design: 学習ステップ構造（Input → Resonance → Output）"
    Body = Get-IssueBody -Purpose "Input → Resonance → Output の学習ステップ構造を詳細に設計する" -MasterFile "curriculum_master_map.md" -Tasks @("Step1: Input / Resonance / Output の各ステップを詳細に設計", "Step2: 各ステップでのAI Orchestraの関与方法を定義", "Step3: 学習ステップ構造をYAML形式でコード化") -ExpectedOutput "- 学習ステップ構造定義ファイル（YAML形式）`n- 保存先: taka_future_system/implementations/learning_steps.yaml" -RelatedIssues "[Curriculum] Define"
    Labels = @("curriculum", "todo")
}

$issues += @{
    Title = "[Curriculum] Model: カリキュラム全体Mermaid化"
    Body = Get-IssueBody -Purpose "カリキュラム全体をMermaid図で可視化する" -MasterFile "curriculum_master_map.md" -Tasks @("Step1: カリキュラム全体のMermaid図を作成", "Step2: Lv1〜Lv5の階層構造を可視化", "Step3: 学習ステップの流れを可視化") -ExpectedOutput "- カリキュラム全体Mermaid図（.mermaid形式）`n- 保存先: taka_future_system/implementations/curriculum_map.mermaid" -RelatedIssues "[Curriculum] Define, [Curriculum] Design"
    Labels = @("curriculum", "todo")
}

$issues += @{
    Title = "[Curriculum] Develop: レベル別サブスキル体系"
    Body = Get-IssueBody -Purpose "各レベルのサブスキル体系を詳細に開発する" -MasterFile "curriculum_master_map.md" -Tasks @("Step1: Lv1〜Lv5の各レベルのサブスキルを定義", "Step2: スキル間の依存関係をマッピング", "Step3: サブスキル体系をYAML形式でコード化") -ExpectedOutput "- サブスキル体系定義ファイル（YAML形式）`n- 保存先: taka_future_system/implementations/subskills.yaml" -RelatedIssues "[Curriculum] Define, [Curriculum] Design"
    Labels = @("curriculum", "todo")
}

$issues += @{
    Title = "[Curriculum] Align: カリキュラム体系とビジネス導線の整合"
    Body = Get-IssueBody -Purpose "カリキュラム体系とビジネス導線（商品ライン）の整合を取る" -MasterFile "curriculum_master_map.md" -Tasks @("Step1: カリキュラムLv1〜Lv5と商品ライン（入口→コア→成長→継続）の対応関係を定義", "Step2: 整合性チェックを実施", "Step3: 整合性マップを作成") -ExpectedOutput "- カリキュラム・ビジネス整合性マップ（Markdown形式）`n- 保存先: taka_future_system/implementations/curriculum_business_alignment.md" -RelatedIssues "[Curriculum] Define, [Business] Develop"
    Labels = @("curriculum", "todo")
}

# VALUE Issues (5個)
$issues += @{
    Title = "[Value] Define: 深さ×対象者マトリクス拡張"
    Body = Get-IssueBody -Purpose "深さ（D1〜D4）×対象者（T1〜T4）のマトリクスを拡張・詳細化する" -MasterFile "value_proposition_matrix.md" -Tasks @("Step1: 既存のマトリクスを確認・拡張", "Step2: 空白のマスを特定し、商品候補を提案", "Step3: 拡張マトリクスをJSON形式で更新") -ExpectedOutput "- 拡張マトリクス定義ファイル（JSON形式）`n- 商品候補リスト（Markdown形式）`n- 保存先: taka_future_system/implementations/value_proposition_matrix_extended.json"
    Labels = @("value-proposition", "todo")
}

$issues += @{
    Title = "[Value] Model: 価値レイヤーのJSONマッピング"
    Body = Get-IssueBody -Purpose "価値レイヤーをJSON形式でマッピングし、構造化する" -MasterFile "value_proposition_matrix.md" -Tasks @("Step1: 価値レイヤーの構造を定義", "Step2: JSON形式でマッピング", "Step3: 価値の階層構造を可視化") -ExpectedOutput "- 価値レイヤーマッピングファイル（JSON形式）`n- 保存先: taka_future_system/implementations/value_layers.json" -RelatedIssues "[Value] Define"
    Labels = @("value-proposition", "todo")
}

$issues += @{
    Title = "[Value] Evaluate: 価格帯体系の整合性チェック"
    Body = Get-IssueBody -Purpose "価格帯体系の整合性をチェックし、最適化する" -MasterFile "value_proposition_matrix.md" -Tasks @("Step1: 現在の価格帯体系を分析", "Step2: 価値と価格のバランスを検証", "Step3: 整合性チェックレポートを作成") -ExpectedOutput "- 価格帯整合性チェックレポート（Markdown形式）`n- 保存先: taka_future_system/implementations/pricing_consistency_report.md" -RelatedIssues "[Value] Define, [Value] Model"
    Labels = @("value-proposition", "todo")
}

$issues += @{
    Title = "[Value] Visualize: 価値マップMermaidモデル"
    Body = Get-IssueBody -Purpose "価値マップをMermaid図で可視化する" -MasterFile "value_proposition_matrix.md" -Tasks @("Step1: 価値マップのMermaid図を作成", "Step2: 深さ×対象者のマトリクスを可視化", "Step3: 価値の流れを可視化") -ExpectedOutput "- 価値マップMermaid図（.mermaid形式）`n- 保存先: taka_future_system/implementations/value_map.mermaid" -RelatedIssues "[Value] Define, [Value] Model"
    Labels = @("value-proposition", "todo")
}

$issues += @{
    Title = "[Value] Align: Value体系とブランド表現の整合"
    Body = Get-IssueBody -Purpose "Value体系とブランド表現の整合を取る" -MasterFile "value_proposition_matrix.md" -Tasks @("Step1: Value体系とブランド表現の対応関係を定義", "Step2: 整合性チェックを実施", "Step3: 整合性マップを作成") -ExpectedOutput "- Value・ブランド整合性マップ（Markdown形式）`n- 保存先: taka_future_system/implementations/value_brand_alignment.md" -RelatedIssues "[Value] Define, [Brand] Define"
    Labels = @("value-proposition", "todo")
}

# BUSINESS Issues (5個)
$issues += @{
    Title = "[Business] Model: 収益源構造モデル"
    Body = Get-IssueBody -Purpose "6つの収益源の構造モデルを詳細に設計する" -MasterFile "business_architecture_map.md" -Tasks @("Step1: 6つの収益源の構造を詳細に設計", "Step2: 各収益源の収益構造をモデル化", "Step3: 収益源構造モデルをJSON形式で作成") -ExpectedOutput "- 収益源構造モデルファイル（JSON形式）`n- 保存先: taka_future_system/implementations/revenue_sources_model.json"
    Labels = @("business", "todo")
}

$issues += @{
    Title = "[Business] Develop: 商品ライン（入口→コア→成長→継続）"
    Body = Get-IssueBody -Purpose "商品ライン（入口→コア→成長→継続）を詳細に開発する" -MasterFile "business_architecture_map.md" -Tasks @("Step1: 入口商品の詳細仕様を定義", "Step2: コア商品の詳細仕様を定義", "Step3: 成長商品の詳細仕様を定義", "Step4: 継続商品の詳細仕様を定義") -ExpectedOutput "- 商品ライン定義ファイル（JSON形式）`n- 保存先: taka_future_system/implementations/product_line.json" -RelatedIssues "[Business] Model"
    Labels = @("business", "todo")
}

$issues += @{
    Title = "[Business] Automate: 収益予測アルゴリズム改善"
    Body = Get-IssueBody -Purpose "収益予測アルゴリズムを改善し、より精度の高い予測を実現する" -MasterFile "business_architecture_map.md" -Tasks @("Step1: 既存の収益予測アルゴリズムを分析", "Step2: 改善点を特定し、アルゴリズムを改善", "Step3: 複数シナリオに対応") -ExpectedOutput "- 改善された収益予測アルゴリズム（Python形式）`n- 保存先: taka_future_system/implementations/revenue_prediction_improved.py" -RelatedIssues "[Business] Model"
    Labels = @("business", "todo")
}

$issues += @{
    Title = "[Business] Visualize: 事業体系Mermaidモデル"
    Body = Get-IssueBody -Purpose "事業体系をMermaid図で可視化する" -MasterFile "business_architecture_map.md" -Tasks @("Step1: 事業体系のMermaid図を作成", "Step2: 収益源と商品ラインの関係を可視化", "Step3: 年商ロードマップを可視化") -ExpectedOutput "- 事業体系Mermaid図（.mermaid形式）`n- 保存先: taka_future_system/implementations/business_architecture_detailed.mermaid" -RelatedIssues "[Business] Model, [Business] Develop"
    Labels = @("business", "todo")
}

$issues += @{
    Title = "[Business] Align: カリキュラム体系との整合"
    Body = Get-IssueBody -Purpose "ビジネス構造とカリキュラム体系の整合を取る" -MasterFile "business_architecture_map.md" -Tasks @("Step1: ビジネス構造とカリキュラム体系の対応関係を定義", "Step2: 整合性チェックを実施", "Step3: 整合性マップを作成") -ExpectedOutput "- ビジネス・カリキュラム整合性マップ（Markdown形式）`n- 保存先: taka_future_system/implementations/business_curriculum_alignment.md" -RelatedIssues "[Business] Develop, [Curriculum] Align"
    Labels = @("business", "todo")
}

# AI-ORCHESTRA Issues (5個)
$issues += @{
    Title = "[AI-Orchestra] Define: 各AIプロトコル定義"
    Body = Get-IssueBody -Purpose "GPT、Claude、Gemini、Grok、DeepSeekの各AIプロトコルを詳細に定義する" -MasterFile "ai_orchestra_blueprint.md" -Tasks @("Step1: 各AIのプロトコルを詳細に定義", "Step2: 入力形式と出力形式を標準化", "Step3: プロトコル定義をJSON形式で作成") -ExpectedOutput "- AIプロトコル定義ファイル（JSON形式）`n- 保存先: taka_future_system/implementations/ai_protocols_detailed.json"
    Labels = @("ai-orchestra", "todo")
}

$issues += @{
    Title = "[AI-Orchestra] Automate: GPTレビューWorkflow構築"
    Body = Get-IssueBody -Purpose "GPTレビューの自動化Workflowを構築する" -MasterFile "ai_orchestra_blueprint.md" -Tasks @("Step1: GPTレビューWorkflowの設計", "Step2: GitHub Actionsの設定ファイルを作成", "Step3: 自動レビューのテスト") -ExpectedOutput "- GitHub Actions Workflowファイル（.yml形式）`n- 保存先: .github/workflows/gpt_review.yml" -RelatedIssues "[AI-Orchestra] Define"
    Labels = @("ai-orchestra", "todo")
}

$issues += @{
    Title = "[AI-Orchestra] Develop: Input Level 1〜3テンプレ生成"
    Body = Get-IssueBody -Purpose "Input Level 1〜3のテンプレートを自動生成する機能を開発する" -MasterFile "ai_orchestra_blueprint.md" -Tasks @("Step1: Input Level 1〜3のテンプレートを定義", "Step2: テンプレート生成ツールを作成（Python/PowerShell）", "Step3: テンプレート生成のテスト") -ExpectedOutput "- テンプレート生成ツール（Python/PowerShell形式）`n- テンプレートファイル（Markdown形式）`n- 保存先: taka_future_system/implementations/template_generator.py" -RelatedIssues "[AI-Orchestra] Define"
    Labels = @("ai-orchestra", "todo")
}

$issues += @{
    Title = "[AI-Orchestra] Design: AI協奏ルールモデル"
    Body = Get-IssueBody -Purpose "AI協奏のルールモデルを設計する" -MasterFile "ai_orchestra_blueprint.md" -Tasks @("Step1: AI協奏のルールを定義", "Step2: AI間の連携ルールを設計", "Step3: ルールモデルをJSON形式で作成") -ExpectedOutput "- AI協奏ルールモデルファイル（JSON形式）`n- 保存先: taka_future_system/implementations/ai_orchestration_rules.json" -RelatedIssues "[AI-Orchestra] Define"
    Labels = @("ai-orchestra", "todo")
}

$issues += @{
    Title = "[AI-Orchestra] Document: AI利用ガイドライン"
    Body = Get-IssueBody -Purpose "AI利用のガイドラインを文書化する" -MasterFile "ai_orchestra_blueprint.md" -Tasks @("Step1: AI利用ガイドラインを作成", "Step2: 各AIの使い方とベストプラクティスを文書化", "Step3: ガイドラインをMarkdown形式で作成") -ExpectedOutput "- AI利用ガイドラインファイル（Markdown形式）`n- 保存先: taka_future_system/implementations/ai_usage_guidelines.md" -RelatedIssues "[AI-Orchestra] Define, [AI-Orchestra] Design"
    Labels = @("ai-orchestra", "todo")
}

# INFRASTRUCTURE Issues (5個)
$issues += @{
    Title = "[Infrastructure] Setup: 3コアフォルダ構造の最適化"
    Body = Get-IssueBody -Purpose "orchestra、projects、taka-coreの3コアフォルダ構造を最適化する" -MasterFile "infrastructure_setup.md" -Tasks @("Step1: 現在のフォルダ構造を分析", "Step2: 最適化案を設計", "Step3: フォルダ構造自動生成スクリプトを改善") -ExpectedOutput "- 改善されたフォルダ構造自動生成スクリプト（PowerShell形式）`n- 保存先: taka_future_system/implementations/infrastructure_setup_optimized.ps1"
    Labels = @("infrastructure", "todo")
}

$issues += @{
    Title = "[Infrastructure] Automate: Obsidian ⇄ GitHub 自動同期"
    Body = Get-IssueBody -Purpose "ObsidianとGitHubの自動同期機能を実装する" -MasterFile "infrastructure_setup.md" -Tasks @("Step1: Obsidian ⇄ GitHub同期の設計", "Step2: GitHub Actionsの設定ファイルを作成", "Step3: 自動同期のテスト") -ExpectedOutput "- GitHub Actions Workflowファイル（.yml形式）`n- 保存先: .github/workflows/obsidian_sync.yml" -RelatedIssues "[Infrastructure] Setup"
    Labels = @("infrastructure", "todo")
}

$issues += @{
    Title = "[Infrastructure] Develop: 自動バックアップScript"
    Body = Get-IssueBody -Purpose "自動バックアップスクリプトを開発する" -MasterFile "infrastructure_setup.md" -Tasks @("Step1: バックアップ要件を定義", "Step2: 自動バックアップスクリプトを作成", "Step3: バックアップのテスト") -ExpectedOutput "- 自動バックアップスクリプト（PowerShell形式）`n- 保存先: taka_future_system/implementations/auto_backup.ps1" -RelatedIssues "[Infrastructure] Setup"
    Labels = @("infrastructure", "todo")
}

$issues += @{
    Title = "[Infrastructure] Design: GitHub Projects ダッシュボード"
    Body = Get-IssueBody -Purpose "GitHub Projectsのダッシュボードを設計する" -MasterFile "infrastructure_setup.md" -Tasks @("Step1: ダッシュボードの要件を定義", "Step2: ダッシュボードの設計", "Step3: ダッシュボードテンプレートを作成") -ExpectedOutput "- ダッシュボードテンプレート（Markdown形式）`n- 保存先: taka_future_system/github/dashboard_template.md" -RelatedIssues "[Infrastructure] Automate"
    Labels = @("infrastructure", "todo")
}

$issues += @{
    Title = "[Infrastructure] Document: 運用ルール（命名・構造）"
    Body = Get-IssueBody -Purpose "運用ルール（命名規則・構造規則）を文書化する" -MasterFile "infrastructure_setup.md" -Tasks @("Step1: 命名規則を定義", "Step2: 構造規則を定義", "Step3: 運用ルールをMarkdown形式で文書化") -ExpectedOutput "- 運用ルール文書（Markdown形式）`n- 保存先: taka_future_system/implementations/operational_rules.md" -RelatedIssues "[Infrastructure] Setup"
    Labels = @("infrastructure", "todo")
}

# BRAND Issues (5個)
$issues += @{
    Title = "[Brand] Define: 世界観の言語化（真・愛・善・美）"
    Body = Get-IssueBody -Purpose "真・愛・善・美の世界観を言語化する" -MasterFile "taka_brand_bible.md" -Tasks @("Step1: 真・愛・善・美の世界観を詳細に言語化", "Step2: 世界観を伝える言葉と表現を定義", "Step3: 言語化された世界観をMarkdown形式で作成") -ExpectedOutput "- 世界観言語化ファイル（Markdown形式）`n- 保存先: taka_future_system/implementations/worldview_language.md"
    Labels = @("brand", "todo")
}

$issues += @{
    Title = "[Brand] Develop: ブランドガイドテンプレ更新"
    Body = Get-IssueBody -Purpose "ブランドガイドテンプレートを更新・改善する" -MasterFile "taka_brand_bible.md" -Tasks @("Step1: 既存のブランドガイドテンプレートを確認", "Step2: 更新・改善点を特定", "Step3: ブランドガイドテンプレートを更新") -ExpectedOutput "- 更新されたブランドガイドテンプレート（Markdown形式）`n- 保存先: taka_future_system/implementations/brand_guide_template_updated.md" -RelatedIssues "[Brand] Define"
    Labels = @("brand", "todo")
}

$issues += @{
    Title = "[Brand] Align: Value・Businessとの統合"
    Body = Get-IssueBody -Purpose "ブランドとValue・Businessの統合を実現する" -MasterFile "taka_brand_bible.md" -Tasks @("Step1: ブランドとValue・Businessの対応関係を定義", "Step2: 整合性チェックを実施", "Step3: 統合マップを作成") -ExpectedOutput "- ブランド・Value・Business統合マップ（Markdown形式）`n- 保存先: taka_future_system/implementations/brand_value_business_integration.md" -RelatedIssues "[Brand] Define, [Value] Align, [Business] Align"
    Labels = @("brand", "todo")
}

$issues += @{
    Title = "[Brand] Document: 英語ブランド表現体系化"
    Body = Get-IssueBody -Purpose "英語でのブランド表現を体系化する" -MasterFile "taka_brand_bible.md" -Tasks @("Step1: 英語ブランド表現の要件を定義", "Step2: 英語ブランド表現を体系化", "Step3: 英語ブランド表現ガイドを作成") -ExpectedOutput "- 英語ブランド表現ガイド（Markdown形式）`n- 保存先: taka_future_system/implementations/brand_english_guide.md" -RelatedIssues "[Brand] Define"
    Labels = @("brand", "todo")
}

$issues += @{
    Title = "[Brand] Visualize: 色・構図・余白ルール"
    Body = Get-IssueBody -Purpose "色・構図・余白のルールを可視化する" -MasterFile "taka_brand_bible.md" -Tasks @("Step1: 色・構図・余白のルールを定義", "Step2: デザインガイドラインを作成", "Step3: 視覚的なガイドを作成") -ExpectedOutput "- デザインガイドラインファイル（Markdown形式）`n- 視覚的なガイド（画像/Mermaid形式）`n- 保存先: taka_future_system/implementations/design_guidelines.md" -RelatedIssues "[Brand] Define, [Brand] Develop"
    Labels = @("brand", "todo")
}

# INTEGRATION Issues (5個)
$issues += @{
    Title = "[Integration] Design: 全体一筆書き構造モデル"
    Body = Get-IssueBody -Purpose "カリキュラム → 商品 → ビジネス → AI の一筆書き構造モデルを設計する" -MasterFile "taka_integrated_system_map.md" -Tasks @("Step1: 全体一筆書き構造を設計", "Step2: 各要素間の接続関係を定義", "Step3: 構造モデルをMermaid形式で作成") -ExpectedOutput "- 全体一筆書き構造モデル（Mermaid形式）`n- 保存先: taka_future_system/implementations/integrated_structure_model.mermaid"
    Labels = @("integration", "todo")
}

$issues += @{
    Title = "[Integration] Model: 価値増幅ノード（Resonance Nodes）"
    Body = Get-IssueBody -Purpose "価値が増幅するポイント（Resonance Nodes）をモデル化する" -MasterFile "taka_integrated_system_map.md" -Tasks @("Step1: Resonance Nodesを特定", "Step2: 価値増幅のメカニズムをモデル化", "Step3: Resonance NodesモデルをJSON形式で作成") -ExpectedOutput "- Resonance Nodesモデルファイル（JSON形式）`n- 保存先: taka_future_system/implementations/resonance_nodes_model.json" -RelatedIssues "[Integration] Design"
    Labels = @("integration", "todo")
}

$issues += @{
    Title = "[Integration] Develop: 時間配分モデル"
    Body = Get-IssueBody -Purpose "Takaさんの最適時間配分モデルを開発する" -MasterFile "taka_integrated_system_map.md" -Tasks @("Step1: 現在の時間配分を分析", "Step2: 最適時間配分モデルを設計", "Step3: 時間配分モデルをJSON形式で作成") -ExpectedOutput "- 時間配分モデルファイル（JSON形式）`n- 保存先: taka_future_system/implementations/time_allocation_model.json" -RelatedIssues "[Integration] Model"
    Labels = @("integration", "todo")
}

$issues += @{
    Title = "[Integration] Visualize: 統合システムMermaid図"
    Body = Get-IssueBody -Purpose "統合システム全体をMermaid図で可視化する" -MasterFile "taka_integrated_system_map.md" -Tasks @("Step1: 統合システム全体のMermaid図を作成", "Step2: 各要素間の関係を可視化", "Step3: 価値の流れを可視化") -ExpectedOutput "- 統合システムMermaid図（.mermaid形式）`n- 保存先: taka_future_system/implementations/integrated_system_detailed.mermaid" -RelatedIssues "[Integration] Design, [Integration] Model"
    Labels = @("integration", "todo")
}

$issues += @{
    Title = "[Integration] Automate: Dashboard定期更新"
    Body = Get-IssueBody -Purpose "Dashboardの定期更新を自動化する" -MasterFile "taka_integrated_system_map.md" -Tasks @("Step1: Dashboard更新の設計", "Step2: GitHub Actionsの設定ファイルを作成", "Step3: 自動更新のテスト") -ExpectedOutput "- GitHub Actions Workflowファイル（.yml形式）`n- 保存先: .github/workflows/dashboard_update.yml" -RelatedIssues "[Integration] Visualize"
    Labels = @("integration", "todo")
}

# Issue作成の実行
$createdIssues = @()
$failedIssues = @()

foreach ($issue in $issues) {
    Write-Host "Creating: $($issue.Title)..." -ForegroundColor Yellow
    
    $result = New-GitHubIssue -Title $issue.Title -Body $issue.Body -Labels $issue.Labels -Milestone $milestoneNumber
    
    if ($result) {
        $createdIssues += $result
        Write-Host "  ✅ Created: #$($result.number) - $($result.html_url)" -ForegroundColor Green
        Start-Sleep -Seconds 2  # Rate limiting対策
    } else {
        $failedIssues += $issue.Title
        Write-Host "  ❌ Failed: $($issue.Title)" -ForegroundColor Red
    }
}

# 結果の表示
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "✅ 作成完了: $($createdIssues.Count) 個" -ForegroundColor Green
Write-Host "❌ 作成失敗: $($failedIssues.Count) 個" -ForegroundColor Red
Write-Host "========================================`n" -ForegroundColor Cyan

if ($createdIssues.Count -gt 0) {
    Write-Host "作成されたIssue一覧:" -ForegroundColor Cyan
    foreach ($issue in $createdIssues) {
        Write-Host "  - #$($issue.number): $($issue.title)" -ForegroundColor White
        Write-Host "    URL: $($issue.html_url)" -ForegroundColor Gray
    }
}

if ($failedIssues.Count -gt 0) {
    Write-Host "`n失敗したIssue:" -ForegroundColor Red
    foreach ($title in $failedIssues) {
        Write-Host "  - $title" -ForegroundColor Red
    }
}

Write-Host "`n✨ Issue作成プロセスが完了しました！" -ForegroundColor Cyan

