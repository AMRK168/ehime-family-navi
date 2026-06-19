import '../models/event.dart';

/// 協賛イベント
class SponsorEvent {
  final String eventId;
  final String sponsorName;
  final int pointReward;
  final Event event;

  const SponsorEvent({
    required this.eventId,
    required this.sponsorName,
    required this.pointReward,
    required this.event,
  });
}

/// スポンサーサービスの抽象インターフェース
/// TODO: 企業連携API接続時に実装を差し替える
abstract class SponsorService {
  Future<List<SponsorEvent>> fetchSponsorEvents();
  Future<void> reportConversion({
    required String eventId,
    required String userId,
  });
}
