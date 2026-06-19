import '../../domain/models/monthly_checkin_summary.dart';
import '../../domain/repositories/checkin_count_service.dart';

/// チェックインカウントサービスのモック実装
/// インメモリでイベント別カウントとユーザー月次実績を管理する
class MockCheckinCountService implements CheckinCountService {
  // イベント別累計カウント: key = eventId, value = カウント
  final Map<String, int> _eventCounts = {};

  // ユーザー月次実績: key = '{userId}_{year}_{month}', value = MonthlyCheckinSummary
  final Map<String, MonthlyCheckinSummary> _monthlySummaries = {};

  @override
  Future<int> getEventCheckinCount(String eventId) async {
    return _eventCounts[eventId] ?? 0;
  }

  @override
  Future<void> incrementEventCount(String eventId) async {
    _eventCounts[eventId] = (_eventCounts[eventId] ?? 0) + 1;
  }

  @override
  Future<MonthlyCheckinSummary> getMonthlySummary({
    required String userId,
    required int year,
    required int month,
  }) async {
    final key = '${userId}_${year}_$month';
    return _monthlySummaries[key] ??
        MonthlyCheckinSummary.empty(
          userId: userId,
          year: year,
          month: month,
        );
  }

  @override
  Future<void> updateMonthlySummary({
    required String userId,
    required int points,
    required DateTime timestamp,
  }) async {
    final year = timestamp.year;
    final month = timestamp.month;
    final key = '${userId}_${year}_$month';
    final current = _monthlySummaries[key] ??
        MonthlyCheckinSummary.empty(
          userId: userId,
          year: year,
          month: month,
        );
    _monthlySummaries[key] = MonthlyCheckinSummary(
      userId: userId,
      year: year,
      month: month,
      checkinCount: current.checkinCount + 1,
      totalPoints: current.totalPoints + points,
    );
  }
}
