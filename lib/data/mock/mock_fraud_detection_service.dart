import '../../domain/repositories/fraud_detection_service.dart';

/// 不正検知サービスのモック実装
/// インメモリでチェックイン状態を管理する
class MockFraudDetectionService implements FraudDetectionService {
  // 重複チェック用: key = '{userId}_{eventId}', value = 初回チェックイン日時
  final Map<String, DateTime> _checkinStatus = {};

  // 間隔制限用: key = userId, value = 最終成功チェックイン時刻
  final Map<String, DateTime> _lastCheckinTime = {};

  // チェックイン間隔（秒）
  static const int _intervalSeconds = 60;

  /// 重複判定: 初回チェックイン日時を返す（テスト用）
  DateTime? getFirstCheckinTime(String userId, String eventId) {
    return _checkinStatus['${userId}_$eventId'];
  }

  /// チェックイン状態を記録（performCheckin成功後に呼ばれる想定）
  Future<void> recordCheckin({
    required String userId,
    required String eventId,
    required DateTime timestamp,
  }) async {
    _checkinStatus['${userId}_$eventId'] = timestamp;
  }

  @override
  Future<bool> isDuplicate({
    required String userId,
    required String eventId,
  }) async {
    return _checkinStatus.containsKey('${userId}_$eventId');
  }

  @override
  bool isWithinTimeWindow({
    required DateTime now,
    required DateTime? eventStart,
    required DateTime? eventEnd,
  }) {
    // イベント時間が未設定の場合は検証スキップ
    if (eventStart == null || eventEnd == null) return true;
    return !now.isBefore(eventStart) && !now.isAfter(eventEnd);
  }

  @override
  Future<CheckinIntervalResult> checkInterval({
    required String userId,
    required DateTime now,
  }) async {
    final lastTime = _lastCheckinTime[userId];
    if (lastTime == null) {
      return const CheckinIntervalResult(isAllowed: true);
    }
    final elapsed = now.difference(lastTime).inSeconds;
    if (elapsed < _intervalSeconds) {
      return CheckinIntervalResult(
        isAllowed: false,
        remainingSeconds: _intervalSeconds - elapsed,
      );
    }
    return const CheckinIntervalResult(isAllowed: true);
  }

  @override
  Future<void> updateLastCheckinTime({
    required String userId,
    required DateTime timestamp,
  }) async {
    _lastCheckinTime[userId] = timestamp;
  }
}
