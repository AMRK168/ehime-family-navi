import '../models/checkin_record.dart';
import '../models/checkin_result.dart';

/// チェックインサービスの抽象インターフェース
/// 【拡張意図】Phase 2でAWSバックエンド（DynamoDB + Lambda）に接続する際に差し替える。
/// モック実装はインメモリだが、本番実装はAPI経由でサーバーにデータを永続化する。
/// TODO: バックエンドAPI連携時に実装を差し替える
abstract class CheckinService {
  /// チェックイン実行
  Future<CheckinResult> performCheckin({
    required String userId,
    required String eventId,
    required DateTime timestamp,
  });

  /// ユーザーの特定イベントへのチェックイン済み判定
  Future<bool> isCheckedIn({
    required String userId,
    required String eventId,
  });

  /// ユーザーのチェックイン履歴取得（日時降順）
  Future<List<CheckinRecord>> getCheckinHistory(String userId);
}
