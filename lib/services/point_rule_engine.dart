import '../domain/models/sponsor.dart';
import '../domain/models/point_reward_config.dart';

/// ポイント付与ルールエンジン
/// スポンサーランクと協賛有無に基づきポイント付与量を算出する
class PointRuleEngine {
  final PointRewardConfig config;

  const PointRuleEngine({required this.config});

  /// コンバージョン時のポイント算出
  /// enablePointReward=falseの場合は常に0を返す
  /// dailyPointsは当日の既獲得ポイント
  int calculateConversionPoints({
    required SponsorRank rank,
    required bool enablePointReward,
    required int dailyPoints,
  }) {
    if (!enablePointReward) return 0;
    final maxDaily = config.maxDailyPoints[rank] ?? 0;
    if (dailyPoints >= maxDaily) return 0;
    return config.pointsPerConversion[rank] ?? 0;
  }
}
