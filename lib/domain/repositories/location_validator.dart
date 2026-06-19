/// 位置検証の抽象インターフェース
/// 【拡張意図】Phase 2でGPS位置検証を導入する際にこのインターフェースを実装する。
/// ユーザーがイベント会場から離れた場所でチェックインすることを防ぐ。
/// 現段階はPassThroughLocationValidator（常にtrue）で無効化している。
/// TODO: GPS位置検証ロジック実装時に差し替える
abstract class LocationValidator {
  /// イベント会場の位置と許容半径に対し、ユーザー位置が範囲内か検証
  Future<bool> validate({
    required double eventLatitude,
    required double eventLongitude,
    required double radiusMeters,
    required double userLatitude,
    required double userLongitude,
  });
}

/// デフォルト実装: 常にtrueを返す（位置検証スキップ）
class PassThroughLocationValidator implements LocationValidator {
  const PassThroughLocationValidator();

  @override
  Future<bool> validate({
    required double eventLatitude,
    required double eventLongitude,
    required double radiusMeters,
    required double userLatitude,
    required double userLongitude,
  }) async =>
      true;
}
