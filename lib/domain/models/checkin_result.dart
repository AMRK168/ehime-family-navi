import 'checkin_record.dart';

/// チェックイン処理結果（sealed class）
sealed class CheckinResult {
  const CheckinResult();
}

/// 成功
class CheckinSuccess extends CheckinResult {
  final CheckinRecord record;
  final int pointsAwarded;
  final String eventName;

  const CheckinSuccess({
    required this.record,
    required this.pointsAwarded,
    required this.eventName,
  });
}

/// 重複エラー
class CheckinDuplicateError extends CheckinResult {
  final DateTime firstCheckinAt; // 初回チェックイン日時

  const CheckinDuplicateError({required this.firstCheckinAt});
}

/// 時間外エラー
class CheckinTimeWindowError extends CheckinResult {
  final DateTime eventStart;
  final DateTime eventEnd;

  const CheckinTimeWindowError({
    required this.eventStart,
    required this.eventEnd,
  });
}

/// 間隔不足エラー
class CheckinIntervalError extends CheckinResult {
  final int remainingSeconds; // 次回チェックイン可能までの残り秒数

  const CheckinIntervalError({required this.remainingSeconds});
}

/// 位置検証失敗エラー
class CheckinLocationError extends CheckinResult {
  const CheckinLocationError();
}

/// システムエラー（DB障害等）
class CheckinSystemError extends CheckinResult {
  final String message;

  const CheckinSystemError({required this.message});
}
