import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/event.dart';
import '../../domain/models/family_profile.dart';
import '../../domain/models/point_reward_config.dart';
import '../../domain/models/user_settings.dart';
import '../../domain/repositories/checkin_service.dart';
import '../../domain/repositories/checkin_count_service.dart';
import '../../domain/repositories/daily_token_service.dart';
import '../../domain/repositories/event_provider.dart';
import '../../domain/repositories/fraud_detection_service.dart';
import '../../domain/repositories/location_validator.dart';
import '../../domain/repositories/sharing_service.dart';
import '../../domain/repositories/poll_service.dart';
import '../../domain/repositories/sponsor_service.dart';
import '../../domain/repositories/point_service.dart';
import '../../domain/repositories/welfare_auth_service.dart';
import '../../services/point_rule_engine.dart';
import '../mock/mock_checkin_service.dart';
import '../mock/mock_checkin_count_service.dart';
import '../mock/mock_daily_token_service.dart';
import '../mock/mock_event_provider.dart';
import '../mock/mock_fraud_detection_service.dart';
import '../mock/mock_group_service.dart';
import '../mock/mock_sharing_service.dart';
import '../mock/mock_poll_service.dart';
import '../mock/mock_sponsor_service.dart';
import '../mock/mock_point_service.dart';
import '../mock/mock_welfare_auth_service.dart';

/// イベントプロバイダー（モック差し替え可能）
final eventProviderInstance = Provider<EventProvider>((ref) {
  return MockEventProvider();
});

/// グループサービス
final groupServiceProvider = Provider<MockGroupService>((ref) {
  return MockGroupService();
});

/// 共有サービス
final sharingServiceProvider = Provider<SharingService>((ref) {
  return MockSharingService();
});

/// 投票サービス
final pollServiceProvider = Provider<PollService>((ref) {
  return MockPollService();
});

/// スポンサーサービス
final sponsorServiceProvider = Provider<SponsorService>((ref) {
  return MockSponsorService();
});

/// ポイントサービス
final pointServiceProvider = Provider<PointService>((ref) {
  return MockPointService();
});

/// PointRuleEngineプロバイダー
final pointRuleEngineProvider = Provider<PointRuleEngine>((ref) {
  return const PointRuleEngine(config: PointRewardConfig.defaultConfig);
});

/// 不正検知サービスプロバイダー
final fraudDetectionServiceProvider = Provider<FraudDetectionService>((ref) {
  return MockFraudDetectionService();
});

/// チェックインカウントサービスプロバイダー
final checkinCountServiceProvider = Provider<CheckinCountService>((ref) {
  return MockCheckinCountService();
});

/// 位置検証プロバイダー（nullableで将来拡張対応）
final locationValidatorProvider = Provider<LocationValidator?>((ref) {
  return const PassThroughLocationValidator();
});

/// 日次トークンサービスプロバイダー
final dailyTokenServiceProvider = Provider<DailyTokenService>((ref) {
  return MockDailyTokenService();
});

/// 福利厚生会社認証サービスプロバイダー
final welfareAuthServiceProvider = Provider<WelfareAuthService>((ref) {
  return MockWelfareAuthService();
});

/// チェックインサービスプロバイダー
final checkinServiceProvider = Provider<CheckinService>((ref) {
  return MockCheckinService(
    fraudDetectionService: ref.watch(fraudDetectionServiceProvider),
    locationValidator: ref.watch(locationValidatorProvider),
    pointRuleEngine: ref.watch(pointRuleEngineProvider),
    pointService: ref.watch(pointServiceProvider),
    checkinCountService: ref.watch(checkinCountServiceProvider),
  );
});

/// スポンサーイベント一覧
final sponsorEventsProvider = FutureProvider<List<SponsorEvent>>((ref) async {
  final sponsorService = ref.watch(sponsorServiceProvider);
  return sponsorService.fetchSponsorEvents();
});

/// ポイント残高
final pointBalanceProvider = FutureProvider<int>((ref) async {
  final pointService = ref.watch(pointServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  return pointService.getBalance(userId);
});

/// 現在のユーザーID（認証モック）
final currentUserIdProvider = StateProvider<String>((ref) => 'user_001');

/// 家族プロフィール
final familyProfileProvider = StateProvider<FamilyProfile>((ref) {
  return FamilyProfile(
    familyId: 'fam_001',
    members: [
      FamilyMember(name: 'お父さん', age: 40, role: 'parent'),
      FamilyMember(name: 'お母さん', age: 38, role: 'parent'),
      FamilyMember(name: '太郎', age: 10, role: 'child'),
    ],
    preferredCategories: [],
  );
});

/// 選択されたカテゴリ
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

/// イベント一覧取得
final eventsProvider = FutureProvider<List<Event>>((ref) async {
  final eventService = ref.watch(eventProviderInstance);
  final profile = ref.watch(familyProfileProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  // カテゴリ選択時はそのカテゴリでフィルタ
  final targetProfile = selectedCategory != null
      ? profile.copyWith(preferredCategories: [selectedCategory])
      : profile;

  return eventService.fetchEvents(profile: targetProfile);
});

/// チェックイン済みイベントIDセット
final checkedInEventIdsProvider = FutureProvider<Set<String>>((ref) async {
  final checkinService = ref.watch(checkinServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  final history = await checkinService.getCheckinHistory(userId);
  return history.map((record) => record.eventId).toSet();
});

/// ユーザー設定（永続化: デフォルトチェックイン方式など）
final userSettingsProvider = StateProvider<UserSettings>((ref) {
  return const UserSettings(
    colorTheme: AppColorTheme.mikan,
    brightness: AppBrightness.light,
    defaultCheckinMethod: CheckinMethod.nfcTouch,
    nickname: '',
    region: '',
    welfarePartner: null, // 連携なし
  );
});

/// チェックインページ内での一時的な方式切り替え（再ログインでリセット）
final currentCheckinMethodProvider = StateProvider<CheckinMethod>((ref) {
  final settings = ref.watch(userSettingsProvider);
  return settings.defaultCheckinMethod;
});
