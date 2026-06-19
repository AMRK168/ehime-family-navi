---
inclusion: auto
---

# えひめファミリーナビ — Flutter 実装ガイド

このドキュメントはプロジェクト全体の実装指針です。すべてのコード生成・修正時にこの内容に従ってください。

---

## プロジェクト概要

家族構成に合わせたお出かけスポット・イベントを提案するモバイルアプリ。
選択の手間を極限まで削りつつ、主導権はユーザーに握らせる設計。
将来的な行政・企業連携を見据え、API拡張ポイントをあらかじめ組み込む。

---

## 技術スタック

- フレームワーク: Flutter (Dart)
- 状態管理: Riverpod
- ローカルDB: Hive または drift
- 通知: flutter_local_notifications
- カレンダー連携: device_calendar または table_calendar
- アーキテクチャ: クリーンアーキテクチャ（Repository パターン）

---

## フォルダ構成

```
lib/
├── config/
│   └── feature_flags.dart
├── domain/
│   ├── models/
│   │   ├── user_account.dart
│   │   ├── group.dart
│   │   ├── family_profile.dart
│   │   ├── event.dart
│   │   ├── shared_item.dart
│   │   └── poll.dart
│   └── repositories/
│       ├── event_provider.dart
│       ├── reservation_service.dart
│       ├── point_service.dart
│       ├── sponsor_service.dart
│       ├── group_service.dart
│       ├── sharing_service.dart
│       └── poll_service.dart
├── data/
│   ├── mock/
│   └── providers/
├── presentation/
│   ├── home/
│   ├── schedule/
│   ├── chat/
│   │   ├── family_chat_screen.dart
│   │   ├── general_group_screen.dart
│   │   └── group_list_screen.dart
│   └── bulletin/
├── services/
│   └── notification_service.dart
└── main.dart
```

---

## 画面構成（BottomNavigationBar）

### 1. メイン検索画面（ホーム）
- 初期起動時: カテゴリキーワードのみ表示（アウトドア／インドア／芸術／体験イベント／アトラクション）
- 登録済み家族構成に基づくフィルタリング結果を表示
- AIオススメ枠: 近隣スポットを1件だけ表示
- イベント情報: 専用リストボックスに格納（ポップアップ禁止）
- 予約ボタン押下 → 外部サイトへ遷移（可能な限りフォーム自動入力）

### 2. スケジュール画面
- カレンダー形式の予定表示
- 予約内容の自動記入
- リマインド通知: 1週間前 + 前日
- 通知制御: 毎月半ばの2週間のみ通知を許可
- 家族への自動共有（サプライズモード切り替え付き）

### 3. チャット画面（グループコミュニティ）
- 2種類のグループに対応（ファミリー / 一般）
- 家族間メッセージング
- 共有チェックボックス: 気になるスポットにチェック → グループメンバーに閲覧共有
- AI議事進行: 会話を自然にファシリテート（UIにAIの存在を明示しない）

### 4. 掲示板画面（イベント情報）
- 地域イベント・協賛企業イベントのリスト表示
- ポイント付与の仕組み（ページ遷移→予約完了でポイント加算）
- 協賛企業なし→提案のみ、協賛企業あり→ポイント還元

---

## グループ機能

### ファミリーグループ
- 想定: 家族でのお出かけ計画（2〜6人）
- 権限モデル: 全員平等（管理者なし）
- 誰でも招待・脱退可能
- 閲覧履歴は共有しない（プライバシー保護）
- 共有は能動的アクションのみ（チェック・送信・スケジュール登録で初めて見える）
- サプライズモード: 共有を一時的にオフにするトグル

### 一般グループ
- 想定: 企業の福利厚生旅行、学校の遠足・クラス活動、友人旅行（〜50人）
- 権限モデル: 管理者＋メンバー
- 管理者が招待・除外を管理
- 管理者が行き先候補やスケジュールを投稿
- メンバーはリアクション・投票で参加
- 投票機能: 行き先候補に対して多数決で決定
- グループの存続: 管理者が「継続」か「アーカイブ」を選択可能（年間利用に対応）
- アーカイブ後もデータは残り、再開可能

### アカウント連携
- 参加方法: QRコード読み取り or 招待コード入力
- アカウント構造: 個人アカウント（認証単位）＋ グループ（共有単位）の2層構造
- 1人が複数のファミリー/一般グループに所属可能
- グループごとに「何を共有するか」を個別設定可能

---

## データモデル

```dart
// --- アカウント・グループ ---

enum GroupType { family, general }
enum GroupStatus { active, archived }

class UserAccount {
  final String userId;
  final String displayName;
  final List<String> groupIds;
}

class AppGroup {
  final String groupId;
  final GroupType type;
  final String name;
  final List<String> memberIds;
  final String? adminId;        // familyの場合はnull
  final String inviteCode;
  final GroupStatus status;
  final DateTime createdAt;
}

// --- 家族プロフィール ---

class FamilyProfile {
  final String familyId;
  final List<FamilyMember> members;
  final List<String> preferredCategories;
}

class FamilyMember {
  final String name;
  final int age;
  final String role; // parent, child, partner
}

// --- イベント ---

class Event {
  final String id;
  final String title;
  final String category;
  final String? sponsorId;
  final bool requiresReservation;
  final DateTime dateTime;
  final GeoLocation location;
}

// --- 選択共有 ---

class SharedItem {
  final String itemId;
  final String sharedByUserId;
  final String targetGroupId;
  final String eventId;
  final DateTime sharedAt;
  final bool isSurpriseHidden;
}

// --- 投票 ---

class Poll {
  final String pollId;
  final String groupId;
  final String createdByUserId;
  final String question;
  final List<PollOption> options;
  final DateTime deadline;
  final bool isClosed;
}

class PollOption {
  final String optionId;
  final String eventId;
  final String label;
  final List<String> voterIds;
}
```

---

## 抽象インターフェース（将来のAPI連携用）

```dart
abstract class EventProvider {
  Future<List<Event>> fetchEvents({required FamilyProfile profile});
  Future<EventDetail> getEventDetail(String eventId);
}

abstract class ReservationService {
  Future<ReservationResult> createReservation(ReservationRequest request);
  Future<String> generateAutoFillUrl(ReservationRequest request);
}

abstract class PointService {
  Future<int> getBalance(String userId);
  Future<void> addPoints({required String userId, required int amount, required String reason});
}

abstract class SponsorService {
  Future<List<SponsorEvent>> fetchSponsorEvents();
  Future<void> reportConversion({required String eventId, required String userId});
}

abstract class GroupService {
  Future<AppGroup> createGroup({required GroupType type, required String name, required String creatorId});
  Future<String> generateInviteCode(String groupId);
  Future<void> joinGroup({required String userId, required String inviteCode});
  Future<void> leaveGroup({required String userId, required String groupId});
  Future<List<UserAccount>> getMembers(String groupId);
  Future<void> archiveGroup(String groupId);
  Future<void> reactivateGroup(String groupId);
}

abstract class SharingService {
  Future<void> shareToGroup({required String userId, required String groupId, required String eventId});
  Future<List<SharedItem>> getSharedItems(String groupId);
  Future<void> toggleSurpriseMode({required String userId, required String groupId, required bool enabled});
}

abstract class PollService {
  Future<Poll> createPoll({required String groupId, required String creatorId, required String question, required List<String> eventIds, required DateTime deadline});
  Future<void> vote({required String pollId, required String optionId, required String userId});
  Future<Poll> getResults(String pollId);
  Future<void> closePoll(String pollId);
}
```

---

## Feature Flags

```dart
class FeatureFlags {
  static const bool enableSponsorApi = false;
  static const bool enablePointSystem = false;
  static const bool enableExternalReservation = false;
  static const bool enableAiFacilitation = true;
  static const bool enableGeneralGroups = true;
}
```

---

## 設計原則（すべてのコードで守ること）

1. ポップアップ・広告バナーは一切使わない
2. 情報の大量表示をしない（初期表示はカテゴリのみ）
3. 家族主体の設計 — 個人ではなく家族単位でデータを管理
4. AIの存在を明示しない — ファシリテーションは自然な提案として表示
5. 通知は最小限（月2週間のみ、1週間前+前日のリマインドのみ）
6. 将来の企業連携部分はインターフェースで抽象化し、モック差し替え可能に
7. ファミリーグループは全員平等 — 権限差を設けない
8. 共有は選択式 — 閲覧履歴を自動共有しない。能動的アクションでのみ共有
9. 一般グループは管理者制 — 継続利用もアーカイブも管理者が選択可能
10. 拡張ポイントにはTODOコメントを残す

---

## 実装順序

1. プロジェクト初期設定 + フォルダ構成作成
2. データモデル + 抽象インターフェース定義
3. モック実装 + FeatureFlags
4. アカウント・グループ機能（ファミリーリンク + 一般グループ）
5. メイン検索画面（ホーム）
6. スケジュール画面
7. チャット画面（グループ切り替え + 選択共有 + 投票機能）
8. 掲示板画面
9. 通知システム
10. UI調整・テスト
