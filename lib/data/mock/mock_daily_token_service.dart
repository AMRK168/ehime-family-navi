import '../../domain/repositories/daily_token_service.dart';

/// 日次トークンサービスのモック実装
/// 日付 + eventId から決定論的にトークンを生成し、当日のみ有効とする
class MockDailyTokenService implements DailyTokenService {
  // モック用シークレット（実際のAPIでは秘密鍵を使用）
  static const String _mockSecret = 'ehime_navi_secret_2026';

  @override
  String generateToken({
    required String eventId,
    required DateTime date,
  }) {
    // 日付文字列 (yyyyMMdd) + eventId + secret からハッシュ風トークンを生成
    final dateStr = _formatDate(date);
    final raw = '${dateStr}_${eventId}_$_mockSecret';
    // 簡易ハッシュ: 実際にはHMAC-SHA256等を使用
    final hash = raw.hashCode.toUnsigned(32).toRadixString(16).padLeft(8, '0');
    return '${dateStr}_$hash';
  }

  @override
  bool validateToken({
    required String eventId,
    required String token,
    required DateTime now,
  }) {
    // トークンから日付部分を抽出
    if (token.length < 9 || token[8] != '_') return false;
    final tokenDateStr = token.substring(0, 8);
    final todayStr = _formatDate(now);

    // 日付が当日でなければ無効
    if (tokenDateStr != todayStr) return false;

    // トークン全体が当日の正しいトークンと一致するか検証
    final expectedToken = generateToken(eventId: eventId, date: now);
    return token == expectedToken;
  }

  @override
  String buildDailyCheckinUri({
    required String eventId,
    required DateTime date,
  }) {
    final token = generateToken(eventId: eventId, date: date);
    return 'ehime-navi://checkin/$eventId/$token';
  }

  /// 日付を yyyyMMdd 形式にフォーマット
  String _formatDate(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y$m$d';
  }
}
