# GitHub Issues 自動生成スクリプト（テスト版）
# Taka Future Orchestration System
# Version: 1.0

$repo = "takakomaki/Taka_Git_Project"
$baseUrl = "https://api.github.com/repos/$repo"

if (-not $env:GITHUB_TOKEN) {
    Write-Host "GITHUB_TOKEN環境変数が設定されていません。" -ForegroundColor Yellow
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $env:GITHUB_TOKEN"
    "Accept" = "application/vnd.github.v3+json"
}

# Milestone取得または作成
function Get-Milestone {
    $url = "$baseUrl/milestones?state=open"
    try {
        $milestones = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
        $existing = $milestones | Where-Object { $_.title -eq "Taka Future System v1.0" }
        if ($existing) {
            Write-Host "Milestone exists: #$($existing.number)" -ForegroundColor Green
            return $existing.number
        }
    } catch {
        # Ignore error
    }
    
    $url = "$baseUrl/milestones"
    $body = '{"title":"Taka Future System v1.0","description":"Taka Future Orchestration System v1.0","state":"open"}'
    try {
        $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body -ContentType "application/json"
        Write-Host "Milestone created: #$($response.number)" -ForegroundColor Green
        return $response.number
    } catch {
        Write-Host "Error creating milestone: $_" -ForegroundColor Red
        return $null
    }
}

# Issue作成
function New-Issue {
    param($Title, $Body, $Labels, $Milestone)
    
    $issueBody = @{
        title = $Title
        body = $Body
        labels = $Labels
    }
    if ($Milestone) { $issueBody.milestone = $Milestone }
    
    $json = $issueBody | ConvertTo-Json -Depth 10
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/issues" -Method Post -Headers $headers -Body $json -ContentType "application/json"
        return $response
    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
        return $null
    }
}

# 実行
$milestone = Get-Milestone

$testIssue = @{
    Title = "[Curriculum] Define: レベル到達点（Transformation Points）"
    Body = "## Purpose`n`nLv1〜Lv5の各レベルの到達点（Transformation Points）を明確に定義する。`n`n## Related Master File`n`n- taka_future_system/master_files/curriculum_master_map.md`n`n## Tasks`n`n- [ ] Step1: Lv1〜Lv5の各レベルのTransformation Pointsを詳細に定義`n- [ ] Step2: 各Transformation Pointの測定可能な指標を設定`n- [ ] Step3: Transformation PointsをYAML形式でコード化`n`n## Expected Output`n`n- Transformation Points定義ファイル（YAML形式）`n- 保存先: taka_future_system/implementations/transformation_points.yaml`n`n## Milestone`n`n- Taka Future System v1.0"
    Labels = @("curriculum", "todo")
}

Write-Host "Creating test issue..." -ForegroundColor Cyan
$result = New-Issue -Title $testIssue.Title -Body $testIssue.Body -Labels $testIssue.Labels -Milestone $milestone

if ($result) {
    Write-Host "Success! Issue #$($result.number) created: $($result.html_url)" -ForegroundColor Green
} else {
    Write-Host "Failed to create issue" -ForegroundColor Red
}

