# Issueラベル色設定スクリプト
# 真・愛・善・美の世界観に基づいた色設定
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

# ラベル定義（ドメイン別の色設定）
$labels = @{
    # CURRICULUM - 学習・成長（ティール系：調和・成長・生命）
    "curriculum" = @{
        name = "curriculum"
        color = "00A39A"  # ティール - 成長・学習
        description = "カリキュラム関連"
    }
    
    # VALUE-PROPOSITION - 価値・光（ゴールド系：光・価値・美）
    "value-proposition" = @{
        name = "value-proposition"
        color = "F5D193"  # ゴールド - 価値・光
        description = "価値提供関連"
    }
    
    # BUSINESS - 実践・収益（ダークブルー系：深さ・実践）
    "business" = @{
        name = "business"
        color = "0E1C36"  # ダークブルー - 実践・深さ
        description = "ビジネス関連"
    }
    
    # AI-ORCHESTRA - 協創・調和（ティールとゴールドの中間：協創）
    "ai-orchestra" = @{
        name = "ai-orchestra"
        color = "7AB8A5"  # ティールとゴールドの中間色 - 協創・調和
        description = "AI Orchestra関連"
    }
    
    # INFRASTRUCTURE - 基盤・安定（ダークブルー系：基盤）
    "infrastructure" = @{
        name = "infrastructure"
        color = "1A2F4A"  # ダークブルーの少し明るい色 - 基盤・安定
        description = "インフラ関連"
    }
    
    # BRAND - 美・表現（ゴールド系：美・表現）
    "brand" = @{
        name = "brand"
        color = "E8C47A"  # ゴールドの少し明るい色 - 美・表現
        description = "ブランド関連"
    }
    
    # INTEGRATION - 統合・全体（ダークブルー系：統合）
    "integration" = @{
        name = "integration"
        color = "2A4A6E"  # ダークブルーの中間色 - 統合・全体
        description = "統合関連"
    }
    
    # TODO - 未着手（グレー系：未着手）
    "todo" = @{
        name = "todo"
        color = "D0D0D0"  # グレー - 未着手
        description = "未着手"
    }
    
    # その他のステータスラベル
    "in-progress" = @{
        name = "in-progress"
        color = "F5D193"  # ゴールド - 進行中
        description = "進行中"
    }
    
    "review" = @{
        name = "review"
        color = "00A39A"  # ティール - レビュー中
        description = "レビュー中"
    }
    
    "done" = @{
        name = "done"
        color = "7AB8A5"  # ティールとゴールドの中間 - 完了
        description = "完了"
    }
}

# ラベル更新関数
function Update-Label {
    param($LabelName, $Color, $Description)
    
    $labelUrl = "$baseUrl/labels/$LabelName"
    
    # まず既存のラベルを確認
    try {
        $existing = Invoke-RestMethod -Uri $labelUrl -Method Get -Headers $headers
        
        # ラベルを更新
        $body = @{
            name = $LabelName
            color = $Color
            description = $Description
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri $labelUrl -Method Patch -Headers $headers -Body $body -ContentType "application/json; charset=utf-8"
        return $response
    } catch {
        # ラベルが存在しない場合は作成
        if ($_.Exception.Response.StatusCode -eq 404) {
            $labelUrl = "$baseUrl/labels"
            $body = @{
                name = $LabelName
                color = $Color
                description = $Description
            } | ConvertTo-Json
            
            try {
                $response = Invoke-RestMethod -Uri $labelUrl -Method Post -Headers $headers -Body $body -ContentType "application/json; charset=utf-8"
                return $response
            } catch {
                Write-Host "Error creating label '$LabelName': $_" -ForegroundColor Red
                return $null
            }
        } else {
            Write-Host "Error updating label '$LabelName': $_" -ForegroundColor Red
            return $null
        }
    }
}

Write-Host "`n=== Issueラベル色設定を開始します ===" -ForegroundColor Cyan
Write-Host "真・愛・善・美の世界観に基づいた色設定`n" -ForegroundColor Cyan

$updatedLabels = @()
$failedLabels = @()

foreach ($labelKey in $labels.Keys) {
    $label = $labels[$labelKey]
    
    Write-Host "Updating label: $($label.name) (#$($label.color))" -ForegroundColor Yellow
    
    $result = Update-Label -LabelName $label.name -Color $label.color -Description $label.description
    
    if ($result) {
        $updatedLabels += $result
        Write-Host "  Success! Label updated: $($result.name) (#$($result.color))" -ForegroundColor Green
        Start-Sleep -Milliseconds 500  # Rate limiting対策
    } else {
        $failedLabels += $label.name
        Write-Host "  Failed: $($label.name)" -ForegroundColor Red
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "更新完了: $($updatedLabels.Count) 個" -ForegroundColor Green
Write-Host "更新失敗: $($failedLabels.Count) 個" -ForegroundColor Red
Write-Host "========================================`n" -ForegroundColor Cyan

if ($updatedLabels.Count -gt 0) {
    Write-Host "更新されたラベル一覧:" -ForegroundColor Cyan
    foreach ($label in $updatedLabels) {
        Write-Host "  - $($label.name): #$($label.color) - $($label.description)" -ForegroundColor White
    }
}

if ($failedLabels.Count -gt 0) {
    Write-Host "`n更新に失敗したラベル:" -ForegroundColor Red
    foreach ($labelName in $failedLabels) {
        Write-Host "  - $labelName" -ForegroundColor Red
    }
}

Write-Host "`nラベル色設定プロセスが完了しました！" -ForegroundColor Cyan
Write-Host "`n色の意味:" -ForegroundColor Cyan
Write-Host "  - ティール (#00A39A): 成長・学習・調和" -ForegroundColor Cyan
Write-Host "  - ゴールド (#F5D193): 価値・光・美" -ForegroundColor Cyan
Write-Host "  - ダークブルー (#0E1C36): 深さ・実践・基盤" -ForegroundColor Cyan
Write-Host "  - グレー (#D0D0D0): 未着手" -ForegroundColor Cyan

