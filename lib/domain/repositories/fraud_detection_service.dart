/// 不正検知サービスの抽象インターフェース
/// 【拡張意図】Phase 2でサーバーサイド不正検知に移行する際に差し替える。
/// 現段階はローカルDB（インメモリ）で検証するが、本番ではAPIサーバーが
/// 全ユーザーのチェックイン履歴を一元管理し、より高精度な不正検知を行う。
/// TODO: バックエンドAPI連携時に実装を差し替える
abstract class FraudDetectionService {
  /// 重複チェックイン検知
  Future<bool> isDuplicate({
    required String userId,
    required String eventId,
  });

  /// イベント時間内かどうか検証
  /// eventStart/eventEnd が null の場合は検証スキップ（true返却）
  bool isWithinTimeWindow({
    required DateTime now,
    required DateTime? eventStart,
    required DateTime? eventEnd,
  });

  /// チェックイン間隔検証（前回から60秒以上経過しているか）
  Future<CheckinIntervalResult> checkInterval({
    required String userId,
    required DateTime now,
  });

  /// 最終成功チェックイン時刻の更新
  Future<void> updateLastCheckinTime({
    required String userId,
    required DateTime timestamp,
  });
}

/// 間隔検証結果
class CheckinIntervalResult {
  final bool isAllowed;
  final int? remainingSeconds; // 拒否時: 残り秒数

  const CheckinIntervalResult({
    required this.isAllowed,
    this.remainingSeconds,
  });
}
