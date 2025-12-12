# CONTEXT_PACK — Taka Future Orchestration System

GPT（Web版）へ “現状をロスなく同期” するための、自己完結型コンテキストパックです。

- **Repo**: `takakomaki/Taka_Git_Project`
- **Snapshot date**: 2025-12-12
- **Tone**: warm / grounded / non-pushy
- **Core values**: 真・愛・善・美

---

## 5. Implementations Summary

### 5.1 `taka_future_system/implementations/` ファイル一覧

- `ai_orchestra_protocols.json`
- `brand_guide_template.md`
- `business_architecture.mermaid`
- `curriculum_structure.yaml`
- `dashboard_template.md`
- `infrastructure_setup_script.ps1`
- `integrated_system_map.mermaid`
- `revenue_prediction.py`
- `taka_time_allocation_model.json`
- `value_proposition_matrix.json`
- `README.md`

### 5.2 Scripts（役割を1行で）

#### GitHub自動化（`taka_future_system/github/`）

- `create_all_issues.ps1`: 35Issue（v1.0）をまとめて作成する（API経由）。
- `create_failed_issues.ps1`: 作成に失敗したIssueだけを再作成する。
- `create_issues.ps1`: Issue作成の初期版（後続の整理版に置換されがち）。
- `create_issues_api.ps1`: GitHub APIを直接叩いてIssue作成する版。
- `create_issues_simple.ps1`: 最小構成でIssue作成を試す簡易版。
- `create_issues_test.ps1`: 認証/権限/リクエストの疎通テスト用。
- `fix_issue_titles.ps1`: 既存Issueタイトルの文字化け等を更新で修正する。
- `update_label_colors.ps1`: 「真・愛・善・美」に沿ったラベル色へ統一する。

#### ローカル運用（`taka_future_system/implementations/`）

- `infrastructure_setup_script.ps1`: コアフォルダ/雛形の作成など、環境セットアップを自動化する。

---

## 6. GitHub Issues Snapshot

### 6.1 数（Repo全体）

- **Total issues**: 49
- **Open**: 37
- **Closed**: 12

> 補足：v1.0の35Issue以外に、テスト/過去分のIssueが含まれます（Milestone未設定のものも存在）。

### 6.2 Milestones（一覧）

- **Taka Future System v1.0**（open）
  - open: 36 / closed: 0
  - `https://github.com/takakomaki/Taka_Git_Project/milestone/2`
- **Orchestra → Archive / v0.x**（open）
  - open: 0 / closed: 11
  - `https://github.com/takakomaki/Taka_Git_Project/milestone/1`

### 6.3 Labels（一覧と色）

#### 世界観に紐づく“意味づけ”（主に運用で使うラベル）

- **ティール（成長・学習・調和）**
  - `curriculum` `#00A39A`
  - `review` `#00A39A`
  - `ai-orchestra` `#7AB8A5`
  - `done` `#7AB8A5`
- **ゴールド（価値・光・美）**
  - `value-proposition` `#F5D193`
  - `in-progress` `#F5D193`
  - `brand` `#E8C47A`
- **ダークブルー（深さ・実践・基盤）**
  - `business` `#0E1C36`
  - `infrastructure` `#1A2F4A`
  - `integration` `#2A4A6E`
- **グレー（未着手）**
  - `todo` `#D0D0D0`

#### Repoに存在するラベル（色）

- `ai-gpt` `#1effd2`
- `ai-orchestra` `#7AB8A5`
- `brand` `#E8C47A`
- `bridge` `#c452b8`
- `bug` `#d73a4a`
- `business` `#0E1C36`
- `curriculum` `#00A39A`
- `documentation` `#0075ca`
- `done` `#7AB8A5`
- `duplicate` `#cfd3d7`
- `enhancement` `#a2eeef`
- `good first issue` `#7057ff`
- `gpt-memory` `#1f0272`
- `help wanted` `#008672`
- `in-progress` `#F5D193`
- `infrastructure` `#1A2F4A`
- `integration` `#2A4A6E`
- `invalid` `#e4e669`
- `orchestra-brief` `#fba6c6`
- `orchestra-core` `#5e06aa`
- `question` `#d876e3`
- `review` `#00A39A`
- `todo` `#D0D0D0`
- `value-proposition` `#F5D193`
- `wontfix` `#ffffff`

---

## 7. Current Phase & Priority

### 7.1 README / Issue状態から判断される現在フェーズ

- **Phase**: v1.0の“基盤整備が完了し、実行フェーズへ入る直前”
  - 7つの `master_files` が存在
  - `implementations` も雛形が存在
  - v1.0 MilestoneのIssueが多数 **Open + todo** のため、これから順次着手の段階

### 7.2 人間（Taka）が今やるべきこと

- **世界観の最終OK**
  - `taka_future_system/master_files/` の7ファイルを“気持ちがYESと言うか”で確認（言葉の温度・違和感をマーキング）
- **最初の1本（LP/商品）の決定**
  - 対象者1人、提供価値1つ、CTA1つに絞る（「何を捨てるか」まで決める）
- **Issueの優先順位を3つに圧縮**
  - 35個を一気に回さず、まず“3つだけ”を `in-progress` にする（残りは `todo` で寝かせる）

### 7.3 意図的に後回しにしていること

- GitHub Actionsの拡張/自動化の高度化（まずは人間の意図が安定してから）
- ダッシュボード自動更新の強化（運用パターンが見えてから）
- 売上予測/アルゴリズムの精密化（KPIと前提が固まってから）

---

## 8. Notes for GPT

### 8.1 トーン指定

- **warm**: 丁寧で、心を扱う
- **grounded**: 事実と構造に基づく（盛らない）
- **non-pushy**: 急かさない（圧をかけない）

### 8.2 価値観（真・愛・善・美）

- **真**: ありのままを受け取り、ありのままを発する
- **愛**: 感謝と慈しみを動機にする
- **善**: 道にかなった正しさで支援する
- **美**: 細部に美を宿す（表現・余白・整合）

### 8.3 GPTが常に意識すべき前提

- Takaは「急がない」を選ぶことで最大の創造性を出す（速度より整合）
- “世界観の破綻” は機能不具合と同じ扱い（品質基準に含める）
- 迷ったら「対象者」「約束（Promise）」「禁則（Don’t）」へ戻る

