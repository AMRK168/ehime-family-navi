/// 位置情報
class GeoLocation {
  final double latitude;
  final double longitude;
  final String? address;

  const GeoLocation({
    required this.latitude,
    required this.longitude,
    this.address,
  });
}

/// イベント詳細（API取得用）
class EventDetail {
  final String id;
  final String title;
  final String description;
  final String category;
  final String? sponsorId;
  final bool requiresReservation;
  final DateTime dateTime;
  final GeoLocation location;
  final String? imageUrl;
  final String? reservationUrl;

  const EventDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.sponsorId,
    required this.requiresReservation,
    required this.dateTime,
    required this.location,
    this.imageUrl,
    this.reservationUrl,
  });
}

/// イベントモデル
class Event {
  final String id;
  final String title;
  final String category;
  final String? sponsorId;
  final bool requiresReservation;
  final DateTime dateTime;
  final GeoLocation location;

  const Event({
    required this.id,
    required this.title,
    required this.category,
    this.sponsorId,
    required this.requiresReservation,
    required this.dateTime,
    required this.location,
  });
}
