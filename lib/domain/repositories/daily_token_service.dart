/// 日次トークンサービスの抽象インターフェース
/// 【拡張意図】チェックインQRコードの不正利用防止。
/// トークンは日付ごとに変わるため、昨日のQRは翌日使えない。
/// Phase 2ではAPIサーバーがHMAC-SHA256で暗号学的に安全なトークンを生成する。
/// 現段階はハッシュコードベースの簡易実装（デモ用途には十分）。
/// TODO: バックエンドAPI連携時に実装を差し替える
abstract class DailyTokenService {
  /// 指定イベント・日付の日次トークンを生成
  String generateToken({
    required String eventId,
    required DateTime date,
  });

  /// トークンが指定イベントに対して当日有効か検証
  bool validateToken({
    required String eventId,
    required String token,
    required DateTime now,
  });

  /// 指定イベントの当日チェックインURIを生成
  String buildDailyCheckinUri({
    required String eventId,
    required DateTime date,
  });
}
