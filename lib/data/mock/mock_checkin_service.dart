import 'package:uuid/uuid.dart';

import '../../config/feature_flags.dart';
import '../../domain/models/checkin_record.dart';
import '../../domain/models/checkin_result.dart';
import '../../domain/models/sponsor.dart';
import '../../domain/repositories/checkin_service.dart';
import '../../domain/repositories/checkin_count_service.dart';
import '../../domain/repositories/fraud_detection_service.dart';
import '../../domain/repositories/location_validator.dart';
import '../../domain/repositories/point_service.dart';
import '../../services/point_rule_engine.dart';
import 'mock_fraud_detection_service.dart';

/// チェックインサービスのモック実装
/// インメモリでCheckinRecordを管理する
class MockCheckinService implements CheckinService {
  final FraudDetectionService fraudDetectionService;
  final LocationValidator? locationValidator;
  final PointRuleEngine pointRuleEngine;
  final PointService pointService;
  final CheckinCountService checkinCountService;

  final List<CheckinRecord> _records = [];
  static const _uuid = Uuid();

  // モックイベントデータ（イベントIDからスポンサーランクとフラグを引くため）
  // 実際のアプリではEventProviderからイベント情報を取得する
  static final Map<String, _MockEventInfo> _mockEventInfo = {
    'sp_001': _MockEventInfo(
      name: '今治タオルフェスティバル',
      rank: SponsorRank.gold,
      enablePointReward: true,
      start: DateTime(2026, 8, 20, 9, 0),
      end: DateTime(2026, 8, 20, 18, 0),
    ),
    'sp_002': _MockEventInfo(
      name: 'しまなみアドベンチャーフェス',
      rank: SponsorRank.silver,
      enablePointReward: true,
      start: DateTime(2026, 9, 1, 8, 0),
      end: DateTime(2026, 9, 1, 17, 0),
    ),
    'sp_003': _MockEventInfo(
      name: '道後アートフェスティバル',
      rank: SponsorRank.bronze,
      enablePointReward: true,
      start: DateTime(2026, 9, 15, 10, 0),
      end: DateTime(2026, 9, 15, 20, 0),
    ),
    'evt_001': _MockEventInfo(
      name: 'コミュニティイベント',
      rank: null,
      enablePointReward: false,
      start: null,
      end: null,
    ),
  };

  MockCheckinService({
    required this.fraudDetectionService,
    this.locationValidator,
    required this.pointRuleEngine,
    required this.pointService,
    required this.checkinCountService,
  });

  @override
  Future<CheckinResult> performCheckin({
    required String userId,
    required String eventId,
    required DateTime timestamp,
  }) async {
    final eventInfo = _mockEventInfo[eventId];
    final eventName = eventInfo?.name ?? 'イベント';

    // Step 1: 不正検知チェック（FeatureFlags.enableFraudDetection制御）
    if (FeatureFlags.enableFraudDetection) {
      // 重複チェック
      final isDuplicate = await fraudDetectionService.isDuplicate(
        userId: userId,
        eventId: eventId,
      );
      if (isDuplicate) {
        final firstTime = (fraudDetectionService as MockFraudDetectionService)
            .getFirstCheckinTime(userId, eventId);
        return CheckinDuplicateError(
          firstCheckinAt: firstTime ?? timestamp,
        );
      }

      // 時間ウィンドウ検証
      final isInWindow = fraudDetectionService.isWithinTimeWindow(
        now: timestamp,
        eventStart: eventInfo?.start,
        eventEnd: eventInfo?.end,
      );
      if (!isInWindow) {
        return CheckinTimeWindowError(
          eventStart: eventInfo?.start ?? timestamp,
          eventEnd: eventInfo?.end ?? timestamp,
        );
      }

      // 間隔チェック
      final intervalResult = await fraudDetectionService.checkInterval(
        userId: userId,
        now: timestamp,
      );
      if (!intervalResult.isAllowed) {
        return CheckinIntervalError(
          remainingSeconds: intervalResult.remainingSeconds ?? 0,
        );
      }
    }

    // Step 2: 位置検証（オプショナル）
    if (locationValidator != null) {
      // モックでは固定値を使用（実装時はイベントの位置情報を使用）
      final isLocationValid = await locationValidator!.validate(
        eventLatitude: 33.84,
        eventLongitude: 132.76,
        radiusMeters: 500,
        userLatitude: 33.84,
        userLongitude: 132.76,
      );
      if (!isLocationValid) {
        return const CheckinLocationError();
      }
    }

    // Step 3: ポイント算出
    final rank = eventInfo?.rank;
    final enableReward = eventInfo?.enablePointReward ?? false;
    int points = 0;
    if (rank != null) {
      // 簡易版: dailyPointsは0とする（実際にはユーザーの日次獲得ポイントを取得）
      points = pointRuleEngine.calculateConversionPoints(
        rank: rank,
        enablePointReward: enableReward,
        dailyPoints: 0,
      );
    }

    // Step 4: CheckinRecord作成・永続化
    final record = CheckinRecord(
      id: _uuid.v4(),
      userId: userId,
      eventId: eventId,
      checkinAt: timestamp,
      pointsAwarded: points,
      sponsorRank: rank,
    );

    try {
      _records.add(record);

      // Step 5: ポイント付与
      if (points > 0) {
        await pointService.addPoints(
          userId: userId,
          amount: points,
          reason: 'チェックイン: $eventName',
        );
      }

      // Step 6: カウント更新
      await checkinCountService.incrementEventCount(eventId);

      // Step 7: 月次実績更新
      await checkinCountService.updateMonthlySummary(
        userId: userId,
        points: points,
        timestamp: timestamp,
      );

      // Step 8: 最終チェックイン時刻更新 & 重複記録
      await fraudDetectionService.updateLastCheckinTime(
        userId: userId,
        timestamp: timestamp,
      );
      if (fraudDetectionService is MockFraudDetectionService) {
        await (fraudDetectionService as MockFraudDetectionService).recordCheckin(
          userId: userId,
          eventId: eventId,
          timestamp: timestamp,
        );
      }

      return CheckinSuccess(
        record: record,
        pointsAwarded: points,
        eventName: eventName,
      );
    } catch (e) {
      // ロールバック: Record削除
      _records.removeWhere((r) => r.id == record.id);
      return CheckinSystemError(message: e.toString());
    }
  }

  @override
  Future<bool> isCheckedIn({
    required String userId,
    required String eventId,
  }) async {
    return _records.any((r) => r.userId == userId && r.eventId == eventId);
  }

  @override
  Future<List<CheckinRecord>> getCheckinHistory(String userId) async {
    final userRecords = _records.where((r) => r.userId == userId).toList();
    userRecords.sort((a, b) => b.checkinAt.compareTo(a.checkinAt));
    return userRecords;
  }
}

/// モック用イベント情報
class _MockEventInfo {
  final String name;
  final SponsorRank? rank;
  final bool enablePointReward;
  final DateTime? start;
  final DateTime? end;

  const _MockEventInfo({
    required this.name,
    required this.rank,
    required this.enablePointReward,
    this.start,
    this.end,
  });
}
