import 'package:uuid/uuid.dart';

import '../../domain/models/shared_item.dart';
import '../../domain/repositories/sharing_service.dart';

/// モック共有サービス
class MockSharingService implements SharingService {
  final _uuid = const Uuid();
  final List<SharedItem> _sharedItems = [];
  final Map<String, bool> _surpriseMode = {};

  @override
  Future<void> shareToGroup({
    required String userId,
    required String groupId,
    required String eventId,
  }) async {
    final isSurprise = _surpriseMode['${userId}_$groupId'] ?? false;
    _sharedItems.add(SharedItem(
      itemId: _uuid.v4(),
      sharedByUserId: userId,
      targetGroupId: groupId,
      eventId: eventId,
      sharedAt: DateTime.now(),
      isSurpriseHidden: isSurprise,
    ));
  }

  @override
  Future<List<SharedItem>> getSharedItems(String groupId) async {
    return _sharedItems
        .where((item) => item.targetGroupId == groupId && !item.isSurpriseHidden)
        .toList();
  }

  @override
  Future<void> toggleSurpriseMode({
    required String userId,
    required String groupId,
    required bool enabled,
  }) async {
    _surpriseMode['${userId}_$groupId'] = enabled;
  }
}
