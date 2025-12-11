# Infrastructure Setup Script
# Taka Future Orchestration System
# Version: 1.0
# Created: 2025-12-11

# 3大コアフォルダの作成
$coreFolders = @(
    "orchestra",
    "projects",
    "taka-core"
)

foreach ($folder in $coreFolders) {
    $path = "c:\doc\$folder"
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force
        Write-Host "Created: $path" -ForegroundColor Green
    } else {
        Write-Host "Already exists: $path" -ForegroundColor Yellow
    }
}

# orchestra/ のサブフォルダ作成
$orchestraSubFolders = @(
    "orchestra\config",
    "orchestra\workflows",
    "orchestra\workflows\templates",
    "orchestra\workflows\automation",
    "orchestra\memory\gpt",
    "orchestra\memory\claude",
    "orchestra\memory\gemini",
    "orchestra\memory\grok",
    "orchestra\memory\deepseek",
    "orchestra\logs\workflows",
    "orchestra\logs\ai_interactions"
)

foreach ($folder in $orchestraSubFolders) {
    $path = "c:\doc\$folder"
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force
        Write-Host "Created: $path" -ForegroundColor Green
    }
}

# projects/ のサブフォルダ作成
$projectsSubFolders = @(
    "projects\active",
    "projects\archive",
    "projects\templates\lp_template",
    "projects\templates\course_template",
    "projects\templates\consulting_template"
)

foreach ($folder in $projectsSubFolders) {
    $path = "c:\doc\$folder"
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force
        Write-Host "Created: $path" -ForegroundColor Green
    }
}

# taka-core/ のサブフォルダ作成
$takaCoreSubFolders = @(
    "taka-core\curriculum\levels",
    "taka-core\curriculum\materials",
    "taka-core\brand\assets",
    "taka-core\brand\guidelines",
    "taka-core\business\architecture",
    "taka-core\business\value_proposition",
    "taka-core\business\financial",
    "taka-core\personal\documents",
    "taka-core\personal\images",
    "taka-core\personal\archive",
    "taka-core\wisdom\insights",
    "taka-core\wisdom\learnings\curriculum",
    "taka-core\wisdom\learnings\business",
    "taka-core\wisdom\learnings\ai_orchestra",
    "taka-core\wisdom\learnings\japanese_culture",
    "taka-core\wisdom\legacy\methods",
    "taka-core\wisdom\legacy\philosophies",
    "taka-core\wisdom\legacy\stories",
    "taka-core\wisdom\archive\projects",
    "taka-core\wisdom\archive\documents",
    "taka-core\wisdom\archive\media"
)

foreach ($folder in $takaCoreSubFolders) {
    $path = "c:\doc\$folder"
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force
        Write-Host "Created: $path" -ForegroundColor Green
    }
}

# プロジェクトテンプレートの作成
$projectTemplate = @"
# [Project Name]

## プロジェクト概要
[プロジェクトの概要を記述]

## 目的
[プロジェクトの目的を記述]

## 参照ファイル
- [参照ファイルのパス]

## AI Orchestra の関わり
- GPT: [GPTの役割]
- Claude: [Claudeの役割]
- Gemini: [Geminiの役割]
- Grok: [Grokの役割]
- DeepSeek: [DeepSeekの役割]

## 進捗状況
- [ ] 計画
- [ ] 実装
- [ ] レビュー
- [ ] 完了

## メモ
[メモを記述]
"@

$templatePath = "c:\doc\projects\templates\project_template.md"
if (-not (Test-Path $templatePath)) {
    $projectTemplate | Out-File -FilePath $templatePath -Encoding UTF8
    Write-Host "Created: $templatePath" -ForegroundColor Green
}

Write-Host "`nInfrastructure setup completed!" -ForegroundColor Cyan
Write-Host "Core folders created: orchestra/, projects/, taka-core/" -ForegroundColor Cyan

