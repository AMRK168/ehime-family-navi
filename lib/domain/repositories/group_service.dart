import '../models/group.dart';
import '../models/user_account.dart';

/// グループサービスの抽象インターフェース
abstract class GroupService {
  Future<AppGroup> createGroup({
    required GroupType type,
    required String name,
    required String creatorId,
  });
  Future<String> generateInviteCode(String groupId);
  Future<void> joinGroup({
    required String userId,
    required String inviteCode,
  });
  Future<void> leaveGroup({
    required String userId,
    required String groupId,
  });
  Future<List<UserAccount>> getMembers(String groupId);
  Future<void> archiveGroup(String groupId);
  Future<void> reactivateGroup(String groupId);
}
