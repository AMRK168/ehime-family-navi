/// スポンサーランク
enum SponsorRank { gold, silver, bronze }

/// スポンサー情報モデル
class Sponsor {
  final String id;
  final String companyName;
  final SponsorRank rank;
  final bool enablePointReward;
  final bool isActive;
  final String regionId;

  const Sponsor({
    required this.id,
    required this.companyName,
    required this.rank,
    required this.enablePointReward,
    required this.isActive,
    required this.regionId,
  });
}
