import '../models/shared_item.dart';

/// 共有サービスの抽象インターフェース
/// 共有は選択式 — 閲覧履歴を自動共有しない。
abstract class SharingService {
  Future<void> shareToGroup({
    required String userId,
    required String groupId,
    required String eventId,
  });
  Future<List<SharedItem>> getSharedItems(String groupId);
  Future<void> toggleSurpriseMode({
    required String userId,
    required String groupId,
    required bool enabled,
  });
}
