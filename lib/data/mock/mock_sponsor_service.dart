import '../../domain/models/event.dart';
import '../../domain/repositories/sponsor_service.dart';

/// スポンサーサービスのモック実装
/// Gold/Silver/Bronze の協賛イベントを返し、コンバージョンをインメモリ記録する
class MockSponsorService implements SponsorService {
  final List<Map<String, String>> _conversionLog = [];

  /// コンバージョンログの取得（テスト用）
  List<Map<String, String>> get conversionLog =>
      List.unmodifiable(_conversionLog);

  @override
  Future<List<SponsorEvent>> fetchSponsorEvents() async {
    // ネットワーク遅延のシミュレーション
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      SponsorEvent(
        eventId: 'sp_001',
        sponsorName: '今治タオル工業組合',
        pointReward: 50,
        event: Event(
          id: 'sp_001',
          title: '今治タオルフェスティバル',
          category: 'ワークショップ',
          sponsorId: 'sponsor_gold_001',
          requiresReservation: false,
          dateTime: DateTime(2026, 8, 20),
          location: const GeoLocation(
            latitude: 34.0660,
            longitude: 132.9978,
            address: '今治市朝倉 タオル美術館',
          ),
        ),
      ),
      SponsorEvent(
        eventId: 'sp_002',
        sponsorName: 'しまなみ観光協会',
        pointReward: 100,
        event: Event(
          id: 'sp_002',
          title: 'しまなみアドベンチャーフェス',
          category: 'アウトドア',
          sponsorId: 'sponsor_silver_001',
          requiresReservation: true,
          dateTime: DateTime(2026, 9, 1),
          location: const GeoLocation(
            latitude: 34.1260,
            longitude: 133.0800,
            address: 'しまなみ海道 来島海峡SA',
          ),
        ),
      ),
      SponsorEvent(
        eventId: 'sp_003',
        sponsorName: '松山市観光課',
        pointReward: 30,
        event: Event(
          id: 'sp_003',
          title: '道後アートフェスティバル',
          category: 'アート',
          sponsorId: 'sponsor_bronze_001',
          requiresReservation: false,
          dateTime: DateTime(2026, 9, 15),
          location: const GeoLocation(
            latitude: 33.8498,
            longitude: 132.7856,
            address: '松山市道後湯之町 道後温泉本館周辺',
          ),
        ),
      ),
    ];
  }

  @override
  Future<void> reportConversion({
    required String eventId,
    required String userId,
  }) async {
    _conversionLog.add({
      'eventId': eventId,
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
