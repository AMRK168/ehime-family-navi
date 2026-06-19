import '../models/event.dart';
import '../models/family_profile.dart';

/// イベント取得の抽象インターフェース
/// 将来のAPI連携時にモック実装から差し替え可能。
abstract class EventProvider {
  Future<List<Event>> fetchEvents({required FamilyProfile profile});
  Future<EventDetail> getEventDetail(String eventId);
}
