/// フィーチャーフラグ
/// 【拡張意図】各機能を1行のtrue/falseで段階的に有効化する。
/// Phase 2でFirebase Remote Config等に移行すれば、デプロイなしにリモートで切り替え可能。
/// バグ発生時は即座にfalseにして影響を封じ込める安全弁としても機能する。
/// 横展開時は自治体ごとに異なるフラグ設定を持たせることで機能の差別化が可能。
class FeatureFlags {
  static const bool enableSponsorApi = false;          // スポンサーAPI連携（Phase 2で有効化）
  static const bool enablePointSystem = false;         // ポイントシステムUI表示（Phase 2で有効化）
  static const bool enableExternalReservation = false; // 外部予約サイト連携（Phase 2で有効化）
  static const bool enableAiFacilitation = true;       // AIファシリテーション（Amazon Bedrock）
  static const bool enableGeneralGroups = true;        // 一般グループ機能
  static const bool enableQrCode = true;               // QR関連機能全体
  static const bool enableCheckinSystem = true;        // チェックイン機能全体
  static const bool enableFraudDetection = true;       // 不正検知（開発・テスト時にfalseで無効化可）
}
