/// ユーザー月次チェックイン実績
class MonthlyCheckinSummary {
  final String userId;
  final int year;
  final int month;
  final int checkinCount; // 月間チェックイン回数
  final int totalPoints; // 月間獲得ポイント合計

  const MonthlyCheckinSummary({
    required this.userId,
    required this.year,
    required this.month,
    required this.checkinCount,
    required this.totalPoints,
  });

  /// 空の実績（該当月のデータ無し）
  static MonthlyCheckinSummary empty({
    required String userId,
    required int year,
    required int month,
  }) =>
      MonthlyCheckinSummary(
        userId: userId,
        year: year,
        month: month,
        checkinCount: 0,
        totalPoints: 0,
      );
}
