/// グループ種別
enum GroupType { family, general }

/// グループステータス
enum GroupStatus { active, archived }

/// グループモデル
/// ファミリーグループと一般グループの両方を表現する。
/// ファミリーグループではadminIdはnull（全員平等）。
class AppGroup {
  final String groupId;
  final GroupType type;
  final String name;
  final List<String> memberIds;
  final String? adminId; // familyの場合はnull
  final String inviteCode;
  final GroupStatus status;
  final DateTime createdAt;

  const AppGroup({
    required this.groupId,
    required this.type,
    required this.name,
    required this.memberIds,
    this.adminId,
    required this.inviteCode,
    required this.status,
    required this.createdAt,
  });

  AppGroup copyWith({
    String? groupId,
    GroupType? type,
    String? name,
    List<String>? memberIds,
    String? adminId,
    String? inviteCode,
    GroupStatus? status,
    DateTime? createdAt,
  }) {
    return AppGroup(
      groupId: groupId ?? this.groupId,
      type: type ?? this.type,
      name: name ?? this.name,
      memberIds: memberIds ?? this.memberIds,
      adminId: adminId ?? this.adminId,
      inviteCode: inviteCode ?? this.inviteCode,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
