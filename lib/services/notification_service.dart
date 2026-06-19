/// 通知サービス
/// 通知制御: 毎月半ばの2週間のみ通知を許可。
/// リマインド: 1週間前 + 前日。
class NotificationService {
  /// 通知が許可されている期間かどうかを判定
  /// 毎月10日〜24日のみ通知を送信する
  static bool isNotificationAllowed() {
    final now = DateTime.now();
    return now.day >= 10 && now.day <= 24;
  }

  /// リマインド通知をスケジュール
  /// イベント日の1週間前と前日に通知を設定する
  Future<void> scheduleReminder({
    required String eventId,
    required String title,
    required DateTime eventDate,
  }) async {
    if (!isNotificationAllowed()) return;

    final oneWeekBefore = eventDate.subtract(const Duration(days: 7));
    final oneDayBefore = eventDate.subtract(const Duration(days: 1));

    // TODO: flutter_local_notifications で実際の通知をスケジュール
    // 1週間前のリマインド
    if (oneWeekBefore.isAfter(DateTime.now())) {
      _scheduleNotification(
        id: eventId.hashCode,
        title: 'リマインド',
        body: '1週間後: $title',
        scheduledDate: oneWeekBefore,
      );
    }

    // 前日のリマインド
    if (oneDayBefore.isAfter(DateTime.now())) {
      _scheduleNotification(
        id: eventId.hashCode + 1,
        title: 'リマインド',
        body: '明日: $title',
        scheduledDate: oneDayBefore,
      );
    }
  }

  void _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) {
    // TODO: flutter_local_notifications プラグインで実装
    // プロトタイプではログ出力のみ
    // ignore: avoid_print
    print('通知スケジュール: $title - $body at $scheduledDate');
  }
}
