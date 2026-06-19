/// ユーザーアカウント
/// 個人認証の単位。1人が複数グループに所属可能。
class UserAccount {
  final String userId;
  final String displayName;
  final List<String> groupIds;

  const UserAccount({
    required this.userId,
    required this.displayName,
    required this.groupIds,
  });

  UserAccount copyWith({
    String? userId,
    String? displayName,
    List<String>? groupIds,
  }) {
    return UserAccount(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      groupIds: groupIds ?? this.groupIds,
    );
  }
}
