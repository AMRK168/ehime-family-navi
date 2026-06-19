/// ポイントサービスの抽象インターフェース
/// 【拡張意図】Phase 2でサーバー側ポイント管理に移行。
/// addPoints（加算）とdeductPoints（減算）の両方を定義することで、
/// 将来のポイント交換（クーポン・特典への変換）に対応する。
/// サーバー側で残高を管理し、加算・減算を行う。
/// TODO: ポイントシステムのバックエンド連携時に実装を差し替える
abstract class PointService {
  /// ユーザーの現在ポイント残高を取得（サーバーから取得）
  Future<int> getBalance(String userId);

  /// ポイント加算（チェックイン報酬等）
  Future<void> addPoints({
    required String userId,
    required int amount,
    required String reason,
  });

  /// ポイント減算（ポイント利用・交換等）
  /// 残高不足の場合はfalseを返す
  Future<bool> deductPoints({
    required String userId,
    required int amount,
    required String reason,
  });
}
