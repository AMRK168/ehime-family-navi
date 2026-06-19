# Implementation Plan: QRコード＆ビジネス連携

## Overview

QRコード画面（生成・スキャン）とビジネス連携機能（スポンサーサービス、ポイントシステム、広告スロット）を既存のFlutter + Riverpodアーキテクチャ上に実装する。段階的に構築し、各ステップで動作確認を行う。

## Tasks

- [x] 1. パッケージ追加と依存関係セットアップ
  - `pubspec.yaml`に`qr_flutter: ^4.1.0`と`mobile_scanner: ^6.0.2`を追加
  - `flutter pub get`を実行して依存関係を解決
  - _Requirements: 1.1, 2.1, 3.1_

- [x] 2. ドメインモデル作成
  - [x] 2.1 Sponsorモデル作成 (`lib/domain/models/sponsor.dart`)
    - `SponsorRank` enum（gold, silver, bronze）を定義
    - `Sponsor` クラスを定義（id, companyName, rank, enablePointReward, isActive, regionId）
    - _Requirements: 4.1, 5.2_
  - [x] 2.2 PointRewardConfig モデル作成 (`lib/domain/models/point_reward_config.dart`)
    - `PointRewardConfig` クラスを定義（pointsPerConversion, maxDailyPoints のMap）
    - `defaultConfig`定数を定義: Gold=100, Silver=50, Bronze=20 / maxDaily: Gold=500, Silver=300, Bronze=100
    - _Requirements: 5.4, 5.5_

- [ ] 3. PointRuleEngine サービス作成
  - [-] 3.1 PointRuleEngine 実装 (`lib/services/point_rule_engine.dart`)
    - `calculateConversionPoints`メソッド実装: enablePointReward, rank, dailyPointsを引数に取る
    - enablePointReward=falseの場合は0を返す
    - dailyPoints >= maxDailyPointsの場合は0を返す
    - それ以外はpointsPerConversion[rank]を返す
    - _Requirements: 5.2, 5.3, 5.4, 5.5, 5.6_
  - [ ]* 3.2 PointRuleEngine プロパティテスト
    - **Property 3: enablePointReward=falseで常に0**
    - **Property 4: 日次上限超過で0**
    - **Property 5: 上限内で正しいランク別ポイント**
    - **Validates: Requirements 5.2, 5.3, 5.4, 5.5, 5.6**

- [ ] 4. モックサービス実装
  - [~] 4.1 MockSponsorService 作成 (`lib/data/mock/mock_sponsor_service.dart`)
    - `SponsorService`インターフェースを実装
    - Gold/Silver/Bronzeの3件以上のモックスポンサーイベントを返す
    - `reportConversion`でイベントログをインメモリに記録
    - _Requirements: 4.1, 4.3, 4.4_
  - [~] 4.2 MockPointService 作成 (`lib/data/mock/mock_point_service.dart`)
    - `PointService`インターフェースを実装
    - インメモリでユーザーポイント残高を管理（初期値250pt）
    - `addPoints`でポイント加算、`getBalance`で残高取得
    - _Requirements: 5.1_

- [~] 5. Checkpoint - モデルとサービスの確認
  - Ensure all tests pass, ask the user if questions arise.

- [~] 6. FeatureFlags 更新
  - `lib/config/feature_flags.dart`に`enableQrCode`フラグを追加（初期値: true）
  - 既存の`enableSponsorApi`と`enablePointSystem`はそのまま維持
  - _Requirements: 7.3, 7.4_

- [~] 7. app_providers.dart 更新
  - `sponsorServiceProvider`を追加（MockSponsorServiceのインスタンス）
  - `pointServiceProvider`を追加（MockPointServiceのインスタンス）
  - `pointRuleEngineProvider`を追加（PointRewardConfig.defaultConfigを使用）
  - _Requirements: 4.1, 5.1_

- [ ] 8. QRコード画面実装
  - [~] 8.1 QR URIパース関数の実装 (`lib/presentation/qr/qr_screen.dart`)
    - `QrAction` sealed class（JoinGroupAction, ViewEventAction, InvalidQrAction）を定義
    - `parseQrUri`関数を実装: URIスキーム判定、host/pathSegments解析
    - _Requirements: 3.2, 3.3, 3.4_
  - [ ]* 8.2 QR URIパースのプロパティテスト
    - **Property 1: QR URI round-trip (encode then parse)**
    - **Property 2: Invalid QR codes are rejected**
    - **Validates: Requirements 2.3, 3.2, 3.3, 3.4**
  - [~] 8.3 QR画面ウィジェット構築
    - `DefaultTabController`で「生成」「スキャン」2タブを構築
    - 生成タブ: `DropdownButton`（グループ招待/イベント共有）+ `QrImageView`（200x200最小サイズ）
    - スキャンタブ: `MobileScanner`でカメラプレビュー + スキャン結果ハンドリング
    - グループ名ラベル表示、イベントタイトル+日付表示
    - エラーハンドリング: カメラ権限拒否メッセージ、無効QRメッセージ、招待コード生成失敗メッセージ
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 3.1, 3.2, 3.3, 3.4, 3.5, 8.2, 8.3_

- [~] 9. QR画面アクセスポイント追加
  - `lib/main.dart`の`MainNavigation`にAppBarを追加
  - `FeatureFlags.enableQrCode`がtrueの場合のみQRアイコンボタンを表示
  - タップで`QrScreen`にナビゲーション（`Navigator.push`）
  - BottomNavigationBarは変更しない（4タブ維持）
  - _Requirements: 8.1, 8.4, 7.4_

- [ ] 10. 掲示板スポンサーカード統合
  - [~] 10.1 AdSlot interleave関数の実装
    - `interleaveWithAdSlots`関数を実装: 5件ごとに1件のスポンサーカードを挿入
    - 入力: 通常イベントリスト + スポンサーイベントリスト → 統合リスト出力
    - _Requirements: 6.2_
  - [ ]* 10.2 AdSlot interleavingのプロパティテスト
    - **Property 6: AdSlot interleaving inserts sponsors at correct positions**
    - **Validates: Requirements 6.2**
  - [~] 10.3 BulletinScreen更新
    - `FeatureFlags.enableSponsorApi`がtrueの場合、SponsorServiceからデータ取得
    - `interleaveWithAdSlots`を使用してリスト統合
    - スポンサーカードに「スポンサー」ラベルを表示
    - 通常イベントカードと同じビジュアルスタイル（ラベル以外）
    - ポップアップ・バナー・全画面オーバーレイは使用しない
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [~] 11. Final checkpoint - flutter analyze による検証
  - `flutter analyze`を実行してLintエラーがないことを確認
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Property tests validate universal correctness properties (URI parsing, point calculation, ad slot logic)
- Unit tests validate specific examples and edge cases
- The implementation uses Dart language throughout (Flutter project)
