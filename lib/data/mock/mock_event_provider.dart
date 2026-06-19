import '../../domain/models/event.dart';
import '../../domain/models/family_profile.dart';
import '../../domain/repositories/event_provider.dart';

/// モックイベントプロバイダー
/// 愛媛県内のサンプルスポットデータを返す。
class MockEventProvider implements EventProvider {
  // モックデータ: 愛媛県のお出かけスポット
  final List<Event> _mockEvents = [
    Event(
      id: 'evt_001',
      title: '道後温泉本館',
      category: 'インドア',
      dateTime: DateTime(2026, 7, 15, 10, 0),
      requiresReservation: false,
      location: GeoLocation(
        latitude: 33.8514,
        longitude: 132.7856,
        address: '愛媛県松山市道後湯之町5-6',
      ),
    ),
    Event(
      id: 'evt_002',
      title: '松山城',
      category: 'アウトドア',
      dateTime: DateTime(2026, 7, 20, 9, 0),
      requiresReservation: false,
      location: GeoLocation(
        latitude: 33.8456,
        longitude: 132.7654,
        address: '愛媛県松山市丸之内1',
      ),
    ),
    Event(
      id: 'evt_003',
      title: '愛媛県美術館 夏の特別展',
      category: '芸術',
      dateTime: DateTime(2026, 8, 1, 10, 0),
      requiresReservation: true,
      location: GeoLocation(
        latitude: 33.8389,
        longitude: 132.7617,
        address: '愛媛県松山市堀之内',
      ),
    ),
    Event(
      id: 'evt_004',
      title: 'しまなみ海道サイクリング体験',
      category: '体験イベント',
      dateTime: DateTime(2026, 7, 25, 8, 0),
      requiresReservation: true,
      location: GeoLocation(
        latitude: 34.1164,
        longitude: 133.0015,
        address: '愛媛県今治市',
      ),
    ),
    Event(
      id: 'evt_005',
      title: 'とべ動物園',
      category: 'アウトドア',
      dateTime: DateTime(2026, 7, 18, 9, 30),
      requiresReservation: false,
      location: GeoLocation(
        latitude: 33.7889,
        longitude: 132.7239,
        address: '愛媛県伊予郡砥部町上原町240',
      ),
    ),
    Event(
      id: 'evt_006',
      title: 'えひめこどもの城',
      category: 'アトラクション',
      dateTime: DateTime(2026, 7, 22, 10, 0),
      requiresReservation: false,
      location: GeoLocation(
        latitude: 33.7890,
        longitude: 132.7100,
        address: '愛媛県松山市西野町乙108-1',
      ),
    ),
    Event(
      id: 'evt_007',
      title: 'タオル美術館 ワークショップ',
      category: '体験イベント',
      dateTime: DateTime(2026, 8, 5, 13, 0),
      requiresReservation: true,
      location: GeoLocation(
        latitude: 33.9208,
        longitude: 133.0472,
        address: '愛媛県今治市朝倉上甲2930',
      ),
    ),
    Event(
      id: 'evt_008',
      title: '宇和島城下町夏祭り',
      category: '体験イベント',
      sponsorId: 'sponsor_001',
      dateTime: DateTime(2026, 8, 10, 17, 0),
      requiresReservation: false,
      location: GeoLocation(
        latitude: 33.2214,
        longitude: 132.5600,
        address: '愛媛県宇和島市丸之内',
      ),
    ),
  ];

  @override
  Future<List<Event>> fetchEvents({required FamilyProfile profile}) async {
    // 遅延をシミュレーション
    await Future.delayed(const Duration(milliseconds: 500));

    // カテゴリでフィルタリング
    if (profile.preferredCategories.isEmpty) {
      return _mockEvents;
    }

    return _mockEvents
        .where((event) => profile.preferredCategories.contains(event.category))
        .toList();
  }

  @override
  Future<EventDetail> getEventDetail(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final event = _mockEvents.firstWhere(
      (e) => e.id == eventId,
      orElse: () => _mockEvents.first,
    );

    return EventDetail(
      id: event.id,
      title: event.title,
      description: '${event.title}の詳細情報です。家族で楽しめるスポットです。',
      category: event.category,
      sponsorId: event.sponsorId,
      requiresReservation: event.requiresReservation,
      dateTime: event.dateTime,
      location: event.location,
      reservationUrl: event.requiresReservation
          ? 'https://example.com/reserve/${event.id}'
          : null,
    );
  }
}
