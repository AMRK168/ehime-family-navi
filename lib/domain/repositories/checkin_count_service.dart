import '../models/monthly_checkin_summary.dart';

/// チェックインカウントサービスの抽象インターフェース
/// TODO: バックエンドAPI連携時に実装を差し替える
abstract class CheckinCountService {
  /// イベントの累計チェックイン回数取得
  Future<int> getEventCheckinCount(String eventId);

  /// イベントのチェックイン回数を1増加
  Future<void> incrementEventCount(String eventId);

  /// ユーザーの月次実績取得
  Future<MonthlyCheckinSummary> getMonthlySummary({
    required String userId,
    required int year,
    required int month,
  });

  /// ユーザーの月次実績更新
  Future<void> updateMonthlySummary({
    required String userId,
    required int points,
    required DateTime timestamp,
  });
}
