import 'sponsor.dart';

/// チェックイン記録データモデル
class CheckinRecord {
  final String id; // UUID
  final String userId;
  final String eventId;
  final DateTime checkinAt; // チェックイン実行日時
  final int pointsAwarded; // 付与ポイント数（0の場合もあり）
  final SponsorRank? sponsorRank; // スポンサーランク（スポンサー無しの場合null）

  const CheckinRecord({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.checkinAt,
    required this.pointsAwarded,
    this.sponsorRank,
  });
}
