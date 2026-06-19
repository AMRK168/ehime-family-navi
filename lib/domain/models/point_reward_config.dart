import 'sponsor.dart';

/// ポイント付与設定（ランク別）
class PointRewardConfig {
  final Map<SponsorRank, int> pointsPerConversion;
  final Map<SponsorRank, int> maxDailyPoints;

  const PointRewardConfig({
    required this.pointsPerConversion,
    required this.maxDailyPoints,
  });

  /// デフォルト設定
  static const defaultConfig = PointRewardConfig(
    pointsPerConversion: {
      SponsorRank.gold: 100,
      SponsorRank.silver: 50,
      SponsorRank.bronze: 20,
    },
    maxDailyPoints: {
      SponsorRank.gold: 500,
      SponsorRank.silver: 300,
      SponsorRank.bronze: 100,
    },
  );
}
