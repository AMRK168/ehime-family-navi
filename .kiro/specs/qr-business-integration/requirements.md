# Requirements Document

## Introduction

「えひめファミリーナビ」アプリにQRコード画面と外部ビジネス連携機能を追加する。QRコード機能はグループ招待やイベント情報の共有をスキャン/生成で実現し、ビジネス連携機能はスポンサーサービス・ポイントシステムをモックデータで有効化し、掲示板画面にネイティブ広告スタイルのスポンサーコンテンツを表示する。既存UI/UXは変更せず、フィーチャーフラグで段階的に有効化可能とする。

## Glossary

- **QR_Code_Screen**: QRコードの生成・スキャンを行う画面コンポーネント
- **GroupService**: グループの作成・招待・参加を管理する抽象サービスインターフェース
- **SponsorService**: 協賛企業イベントの取得・コンバージョン報告を行う抽象サービスインターフェース
- **PointService**: ユーザーポイントの取得・付与を管理する抽象サービスインターフェース
- **PointRuleEngine**: スポンサーランクと協賛有無に基づきポイント付与量を算出するエンジン
- **SponsorRank**: スポンサー企業のランク（Gold, Silver, Bronze）
- **FeatureFlags**: 機能の有効/無効を制御する静的フラグクラス
- **AdSlot**: イベントリスト内にネイティブ広告を配置するためのスロット
- **InviteCode**: グループへの参加に使用する一意の招待コード文字列
- **Mock_Implementation**: バックエンド接続前のローカルモックデータによる実装

## Requirements

### Requirement 1: QRコード生成（グループ招待）

**User Story:** As a グループメンバー, I want to グループ招待コードをQRコードとして生成する, so that 他のユーザーが簡単にグループに参加できる.

#### Acceptance Criteria

1. WHEN a user selects a group and requests an invite QR code, THE QR_Code_Screen SHALL call GroupService.generateInviteCode and encode the returned InviteCode into a QR code image
2. WHEN the QR code is generated, THE QR_Code_Screen SHALL display the QR code image with the group name as a label
3. WHEN the invite code generation fails, THE QR_Code_Screen SHALL display an error message indicating the failure reason
4. THE QR_Code_Screen SHALL render the QR code at a minimum size of 200x200 logical pixels for reliable scanning

### Requirement 2: QRコード生成（イベント共有）

**User Story:** As a ユーザー, I want to イベント情報をQRコードとして生成する, so that 他のユーザーとイベント情報を簡単に共有できる.

#### Acceptance Criteria

1. WHEN a user selects an event for sharing, THE QR_Code_Screen SHALL encode the event ID into a QR code image
2. WHEN the event QR code is displayed, THE QR_Code_Screen SHALL show the event title and date as context information below the QR code
3. THE QR_Code_Screen SHALL encode event data using a URI scheme in the format "ehime-navi://event/{eventId}"

### Requirement 3: QRコードスキャン

**User Story:** As a ユーザー, I want to QRコードをスキャンする, so that グループに素早く参加したりイベント情報にアクセスできる.

#### Acceptance Criteria

1. WHEN the user activates the QR scanner, THE QR_Code_Screen SHALL request camera permission and display a camera preview with a scan overlay
2. WHEN a valid group invite QR code is scanned, THE QR_Code_Screen SHALL call GroupService.joinGroup with the decoded InviteCode and display a success confirmation
3. WHEN a valid event QR code is scanned, THE QR_Code_Screen SHALL navigate the user to the event detail view for the decoded event ID
4. IF an invalid or unrecognized QR code is scanned, THEN THE QR_Code_Screen SHALL display an error message indicating the code is not supported
5. IF camera permission is denied, THEN THE QR_Code_Screen SHALL display a message guiding the user to enable camera access in device settings

### Requirement 4: スポンサーサービス有効化

**User Story:** As a 開発者, I want to SponsorServiceをモックデータで有効化する, so that 協賛企業イベントが掲示板に表示される.

#### Acceptance Criteria

1. WHEN FeatureFlags.enableSponsorApi is true, THE SponsorService SHALL return mock sponsor event data including sponsor name, point reward, and event details
2. WHEN FeatureFlags.enableSponsorApi is false, THE SponsorService SHALL not be instantiated and sponsor-related UI elements SHALL remain hidden
3. THE Mock_Implementation SHALL provide at least 3 sponsor events with varying SponsorRank values (Gold, Silver, Bronze)
4. WHEN SponsorService.fetchSponsorEvents is called, THE Mock_Implementation SHALL return events associated with the current region

### Requirement 5: ポイントシステム実装

**User Story:** As a ユーザー, I want to スポンサーイベントへの参加でポイントを獲得する, so that アプリ利用のインセンティブを得られる.

#### Acceptance Criteria

1. WHEN FeatureFlags.enablePointSystem is true, THE PointService SHALL track and return the user point balance
2. WHEN a user completes a conversion action on a sponsor event, THE PointRuleEngine SHALL calculate point reward based on the sponsor SponsorRank and enablePointReward flag
3. WHEN enablePointReward is false for a sponsor, THE PointRuleEngine SHALL return 0 points regardless of the SponsorRank
4. THE PointRuleEngine SHALL apply the following base point values per conversion: Gold=100, Silver=50, Bronze=20
5. THE PointRuleEngine SHALL enforce a daily maximum point limit per SponsorRank: Gold=500, Silver=300, Bronze=100
6. WHEN the user daily points reach the maximum limit, THE PointRuleEngine SHALL return 0 for subsequent actions of that rank

### Requirement 6: 掲示板スポンサーコンテンツ表示

**User Story:** As a ユーザー, I want to 掲示板でスポンサーイベントを自然に見る, so that 有益な協賛情報を邪魔なく受け取れる.

#### Acceptance Criteria

1. WHILE FeatureFlags.enableSponsorApi is true, THE BulletinScreen SHALL display sponsor events within the event list using native ad-style cards
2. THE AdSlot SHALL insert one sponsor event card per every 5 regular event items in the list
3. THE AdSlot SHALL display a "スポンサー" label on each sponsor event card to distinguish it from regular events
4. THE AdSlot SHALL display sponsor event cards with the same visual style as regular event cards except for the sponsor label
5. THE BulletinScreen SHALL NOT display popups, banners, full-screen overlays, or interstitial advertisements

### Requirement 7: フィーチャーフラグ制御

**User Story:** As a 開発者, I want to 新機能をフィーチャーフラグで制御する, so that 段階的に機能をリリースできる.

#### Acceptance Criteria

1. WHEN FeatureFlags.enableSponsorApi is toggled, THE application SHALL show or hide sponsor-related content without requiring a restart
2. WHEN FeatureFlags.enablePointSystem is toggled, THE application SHALL show or hide the point balance card and point reward badges without requiring a restart
3. THE FeatureFlags class SHALL include a new enableQrCode flag to control QR code feature visibility
4. WHEN FeatureFlags.enableQrCode is false, THE QR_Code_Screen access point SHALL be hidden from the navigation

### Requirement 8: QRコード画面アクセス

**User Story:** As a ユーザー, I want to QRコード画面にアプリ内から簡単にアクセスする, so that QRコードの生成・スキャンをすぐに利用できる.

#### Acceptance Criteria

1. WHEN FeatureFlags.enableQrCode is true, THE application SHALL display a QR code action button accessible from the app bar or a designated UI location
2. THE QR_Code_Screen SHALL provide tab-based navigation between "生成" (generate) and "スキャン" (scan) modes
3. WHILE in generate mode, THE QR_Code_Screen SHALL allow the user to select between group invite and event sharing options
4. THE QR_Code_Screen access point SHALL NOT modify the existing BottomNavigationBar structure (4 tabs remain unchanged)
