import 'package:uuid/uuid.dart';

import '../../domain/models/group.dart';
import '../../domain/models/user_account.dart';
import '../../domain/repositories/group_service.dart';

/// モックグループサービス
class MockGroupService implements GroupService {
  final _uuid = const Uuid();
  final List<AppGroup> _groups = [];
  final List<UserAccount> _users = [
    UserAccount(userId: 'user_001', displayName: 'お父さん', groupIds: ['grp_001']),
    UserAccount(userId: 'user_002', displayName: 'お母さん', groupIds: ['grp_001']),
    UserAccount(userId: 'user_003', displayName: '太郎', groupIds: ['grp_001']),
  ];

  MockGroupService() {
    // 初期データ: サンプルファミリーグループ
    _groups.add(AppGroup(
      groupId: 'grp_001',
      type: GroupType.family,
      name: '田中ファミリー',
      memberIds: ['user_001', 'user_002', 'user_003'],
      inviteCode: 'FAM123',
      status: GroupStatus.active,
      createdAt: DateTime(2026, 1, 1),
    ));
  }

  @override
  Future<AppGroup> createGroup({
    required GroupType type,
    required String name,
    required String creatorId,
  }) async {
    final group = AppGroup(
      groupId: _uuid.v4(),
      type: type,
      name: name,
      memberIds: [creatorId],
      adminId: type == GroupType.general ? creatorId : null,
      inviteCode: _uuid.v4().substring(0, 6).toUpperCase(),
      status: GroupStatus.active,
      createdAt: DateTime.now(),
    );
    _groups.add(group);
    return group;
  }

  @override
  Future<String> generateInviteCode(String groupId) async {
    return _uuid.v4().substring(0, 6).toUpperCase();
  }

  @override
  Future<void> joinGroup({
    required String userId,
    required String inviteCode,
  }) async {
    final groupIndex = _groups.indexWhere((g) => g.inviteCode == inviteCode);
    if (groupIndex != -1) {
      final group = _groups[groupIndex];
      if (!group.memberIds.contains(userId)) {
        _groups[groupIndex] = group.copyWith(
          memberIds: [...group.memberIds, userId],
        );
      }
    }
  }

  @override
  Future<void> leaveGroup({
    required String userId,
    required String groupId,
  }) async {
    final groupIndex = _groups.indexWhere((g) => g.groupId == groupId);
    if (groupIndex != -1) {
      final group = _groups[groupIndex];
      _groups[groupIndex] = group.copyWith(
        memberIds: group.memberIds.where((id) => id != userId).toList(),
      );
    }
  }

  @override
  Future<List<UserAccount>> getMembers(String groupId) async {
    final group = _groups.firstWhere(
      (g) => g.groupId == groupId,
      orElse: () => _groups.first,
    );
    return _users
        .where((u) => group.memberIds.contains(u.userId))
        .toList();
  }

  @override
  Future<void> archiveGroup(String groupId) async {
    final groupIndex = _groups.indexWhere((g) => g.groupId == groupId);
    if (groupIndex != -1) {
      _groups[groupIndex] = _groups[groupIndex].copyWith(
        status: GroupStatus.archived,
      );
    }
  }

  @override
  Future<void> reactivateGroup(String groupId) async {
    final groupIndex = _groups.indexWhere((g) => g.groupId == groupId);
    if (groupIndex != -1) {
      _groups[groupIndex] = _groups[groupIndex].copyWith(
        status: GroupStatus.active,
      );
    }
  }

  /// 全グループを取得（UI用）
  List<AppGroup> get allGroups => List.unmodifiable(_groups);
}
