/// 予約リクエスト
class ReservationRequest {
  final String eventId;
  final String userId;
  final int numberOfPeople;
  final DateTime preferredDate;

  const ReservationRequest({
    required this.eventId,
    required this.userId,
    required this.numberOfPeople,
    required this.preferredDate,
  });
}

/// 予約結果
class ReservationResult {
  final bool success;
  final String? confirmationCode;
  final String? errorMessage;

  const ReservationResult({
    required this.success,
    this.confirmationCode,
    this.errorMessage,
  });
}

/// 予約サービスの抽象インターフェース
/// TODO: 外部予約サイトとの連携時に実装を差し替える
abstract class ReservationService {
  Future<ReservationResult> createReservation(ReservationRequest request);
  Future<String> generateAutoFillUrl(ReservationRequest request);
}
