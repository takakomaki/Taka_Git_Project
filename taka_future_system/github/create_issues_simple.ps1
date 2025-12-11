# GitHub Issues 自動生成スクリプト（簡易版）
# Taka Future Orchestration System
# Version: 1.0

$repo = "takakomaki/Taka_Git_Project"
$baseUrl = "https://api.github.com/repos/$repo"

# GitHub Tokenの確認
if (-not $env:GITHUB_TOKEN) {
    Write-Host "GITHUB_TOKEN環境変数が設定されていません。" -ForegroundColor Yellow
    Write-Host "GitHub Personal Access Tokenを設定してください：" -ForegroundColor Yellow
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $env:GITHUB_TOKEN"
    "Accept" = "application/vnd.github.v3+json"
}

# Milestoneの作成または取得
function Get-Or-Create-Milestone {
    $milestoneUrl = "$baseUrl/milestones"
    
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
    $body = @{
        title = "Taka Future System v1.0"
        description = "Taka Future Orchestration System v1.0"
        state = "open"
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri $milestoneUrl -Method Post -Headers $headers -Body $body -ContentType "application/json"
        Write-Host "Milestone created: Taka Future System v1.0 (#$($response.number))" -ForegroundColor Green
        return $response.number
    } catch {
        Write-Host "Error creating milestone: $_" -ForegroundColor Red
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

# Milestone取得
$milestoneNumber = Get-Or-Create-Milestone

if (-not $milestoneNumber) {
    Write-Host "Milestoneの作成に失敗しました。続行します..." -ForegroundColor Yellow
}

Write-Host "`nGitHub Issues作成を開始します...`n" -ForegroundColor Cyan

# Issue定義（簡易版 - 最初の5つをテスト）
$testIssues = @(
    @{
        Title = "[Curriculum] Define: レベル到達点（Transformation Points）"
        Body = "## Purpose`n`nLv1〜Lv5の各レベルの到達点（Transformation Points）を明確に定義する。`n`n## Related Master File`n`n- taka_future_system/master_files/curriculum_master_map.md`n`n## Tasks`n`n- [ ] Step1: Lv1〜Lv5の各レベルのTransformation Pointsを詳細に定義`n- [ ] Step2: 各Transformation Pointの測定可能な指標を設定`n- [ ] Step3: Transformation PointsをYAML形式でコード化`n`n## Expected Output`n`n- Transformation Points定義ファイル（YAML形式）`n- 保存先: taka_future_system/implementations/transformation_points.yaml`n`n## Milestone`n`n- Taka Future System v1.0"
        Labels = @("curriculum", "todo")
    },
    @{
        Title = "[Curriculum] Design: 学習ステップ構造（Input → Resonance → Output）"
        Body = "## Purpose`n`nInput → Resonance → Output の学習ステップ構造を詳細に設計する。`n`n## Related Master File`n`n- taka_future_system/master_files/curriculum_master_map.md`n`n## Tasks`n`n- [ ] Step1: Input / Resonance / Output の各ステップを詳細に設計`n- [ ] Step2: 各ステップでのAI Orchestraの関与方法を定義`n- [ ] Step3: 学習ステップ構造をYAML形式でコード化`n`n## Expected Output`n`n- 学習ステップ構造定義ファイル（YAML形式）`n- 保存先: taka_future_system/implementations/learning_steps.yaml`n`n## Milestone`n`n- Taka Future System v1.0"
        Labels = @("curriculum", "todo")
    }
)

$createdIssues = @()
foreach ($issue in $testIssues) {
    Write-Host "Creating: $($issue.Title)..." -ForegroundColor Yellow
    $result = New-GitHubIssue -Title $issue.Title -Body $issue.Body -Labels $issue.Labels -Milestone $milestoneNumber
    if ($result) {
        $createdIssues += $result
        Write-Host "  Created: #$($result.number) - $($result.html_url)" -ForegroundColor Green
        Start-Sleep -Seconds 2
    }
}

Write-Host "`n作成完了: $($createdIssues.Count) 個のIssue`n" -ForegroundColor Cyan

