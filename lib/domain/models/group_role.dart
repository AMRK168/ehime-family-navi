/// グループ内の階級（一般グループのみ適用）
enum GroupRank {
  /// 階級5: グループ作成者
  owner(5, 'グループ作成者'),

  /// 階級4: 上位権限者
  admin(4, '上位権限者'),

  /// 階級3: 中間権限者（デフォルト）
  member(3, '中間権限者'),

  /// 階級2: 低層権限者
  restricted(2, '低層権限者'),

  /// 階級1: 最下層権限者
  viewer(1, '最下層権限者');

  final int level;
  final String label;
  const GroupRank(this.level, this.label);
}

/// グループメンバーの権限情報
class GroupMemberRole {
  final String userId;
  final String groupId;
  final GroupRank rank;

  const GroupMemberRole({
    required this.userId,
    required this.groupId,
    required this.rank,
  });

  // ─── 権限チェック ───

  /// 退会処理が可能か（階級5のみ）
  bool get canKickMember => rank.level >= 5;

  /// 招待が可能か（階級4以上）
  bool get canInvite => rank.level >= 4;

  /// ユーザー情報閲覧が可能か（階級3以上）
  bool get canViewUserInfo => rank.level >= 3;

  /// 発言が可能か（階級2以上）
  bool get canSendMessage => rank.level >= 2;

  /// メッセージ閲覧が可能か（全員）
  bool get canReadMessages => rank.level >= 1;

  /// 階級変更が可能か（階級4以上、自分より下のみ）
  bool get canChangeRank => rank.level >= 4;

  /// 階級譲渡が可能か（階級5のみ）
  bool get canTransferOwnership => rank.level >= 5;

  /// デフォルト階級設定が可能か（階級5のみ）
  bool get canSetDefaultRank => rank.level >= 5;

  /// メンバー一覧（階級含む）の閲覧が可能か（階級4以上）
  bool get canViewMemberRanks => rank.level >= 4;

  /// 対象メンバーの階級を変更できるか
  bool canModifyRankOf(GroupMemberRole target) {
    if (!canChangeRank) return false;
    if (target.rank.level >= rank.level) return false; // 自分以上は変更不可
    return true;
  }
}
