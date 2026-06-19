import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/group.dart';
import '../../domain/models/group_role.dart';

/// 一般グループ画面
/// 管理者が行き先候補やスケジュールを投稿し、
/// メンバーがリアクション・投票で参加する。
class GeneralGroupScreen extends ConsumerStatefulWidget {
  final AppGroup group;

  const GeneralGroupScreen({super.key, required this.group});

  @override
  ConsumerState<GeneralGroupScreen> createState() => _GeneralGroupScreenState();
}

class _GeneralGroupScreenState extends ConsumerState<GeneralGroupScreen> {
  // モック: 投票データ
  final List<_PollItem> _polls = [
    _PollItem(
      question: '夏のレクリエーション行き先',
      options: [
        _PollOptionItem(label: 'しまなみ海道サイクリング', votes: 5),
        _PollOptionItem(label: '道後温泉', votes: 3),
        _PollOptionItem(label: 'とべ動物園', votes: 7),
      ],
      isOpen: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'グループ設定',
            onPressed: () => _showGroupSettings(context),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'archive') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('グループをアーカイブしました')),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'members',
                child: Text('メンバー管理'),
              ),
              const PopupMenuItem(
                value: 'archive',
                child: Text('アーカイブ'),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // グループ情報
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.groups, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        widget.group.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '招待コード: ${widget.group.inviteCode}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  Text(
                    'メンバー: ${widget.group.memberIds.length}人',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 投票セクション
          Text(
            '投票',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ..._polls.map((poll) => _buildPollCard(poll)),
          const SizedBox(height: 16),
          // 新しい投票を作成
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('投票作成機能（プロトタイプ）')),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('新しい投票を作成'),
          ),
        ],
      ),
    );
  }

  void _showGroupSettings(BuildContext context) {
    // 現在のユーザーの権限（モック: owner=5として扱う）
    const myRole = GroupMemberRole(
      userId: 'user_001',
      groupId: 'grp_001',
      rank: GroupRank.owner,
    );

    // モックメンバー一覧
    final members = [
      const GroupMemberRole(
          userId: 'user_001', groupId: 'grp_001', rank: GroupRank.owner),
      const GroupMemberRole(
          userId: 'user_002', groupId: 'grp_001', rank: GroupRank.member),
      const GroupMemberRole(
          userId: 'user_003', groupId: 'grp_001', rank: GroupRank.restricted),
    ];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _GroupSettingsPage(
          group: widget.group,
          myRole: myRole,
          members: members,
        ),
      ),
    );
  }

  Widget _buildPollCard(_PollItem poll) {
    final totalVotes = poll.options.fold<int>(0, (sum, opt) => sum + opt.votes);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.how_to_vote,
                  color: poll.isOpen ? Colors.green : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    poll.question,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (poll.isOpen)
                  const Chip(
                    label: Text('投票中', style: TextStyle(fontSize: 10)),
                    backgroundColor: Color(0xFFE8F5E9),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ...poll.options.map((option) {
              final percentage =
                  totalVotes > 0 ? (option.votes / totalVotes * 100) : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(option.label, style: const TextStyle(fontSize: 13)),
                        Text(
                          '${option.votes}票 (${percentage.toStringAsFixed(0)}%)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ],
                ),
              );
            }),
            if (poll.isOpen)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('投票しました！')),
                    );
                  },
                  child: const Text('投票する'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PollItem {
  final String question;
  final List<_PollOptionItem> options;
  final bool isOpen;

  const _PollItem({
    required this.question,
    required this.options,
    required this.isOpen,
  });
}

class _PollOptionItem {
  final String label;
  final int votes;

  const _PollOptionItem({required this.label, required this.votes});
}

/// グループ設定ページ
/// 全員が閲覧可能だが、権限がない項目は操作不可。
/// 階級一覧の閲覧は階級4・5のみ。
class _GroupSettingsPage extends StatelessWidget {
  final AppGroup group;
  final GroupMemberRole myRole;
  final List<GroupMemberRole> members;

  const _GroupSettingsPage({
    required this.group,
    required this.myRole,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('グループ設定'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 自分の権限表示
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.shield,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('あなたの階級',
                          style: TextStyle(fontSize: 12)),
                      Text(
                        '${myRole.rank.label}（Lv.${myRole.rank.level}）',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // グループ情報
          _buildSettingTile(
            context,
            icon: Icons.edit,
            title: 'グループ名変更',
            enabled: myRole.rank.level >= 5,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('グループ名変更（プロトタイプ）')),
            ),
          ),
          _buildSettingTile(
            context,
            icon: Icons.person_add,
            title: '招待',
            subtitle: '新しいメンバーを招待',
            enabled: myRole.canInvite,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('招待機能（プロトタイプ）')),
            ),
          ),
          _buildSettingTile(
            context,
            icon: Icons.person_remove,
            title: 'メンバー退会',
            subtitle: 'メンバーをグループから退会させる',
            enabled: myRole.canKickMember,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('メンバー退会機能（プロトタイプ）')),
            ),
          ),
          _buildSettingTile(
            context,
            icon: Icons.admin_panel_settings,
            title: 'デフォルト階級設定',
            subtitle: '新規メンバーの初期階級を設定',
            enabled: myRole.canSetDefaultRank,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('デフォルト階級設定（プロトタイプ）')),
            ),
          ),
          _buildSettingTile(
            context,
            icon: Icons.swap_horiz,
            title: '権限譲渡',
            subtitle: 'グループ作成者権限を他のメンバーに譲渡',
            enabled: myRole.canTransferOwnership,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('権限譲渡（プロトタイプ）')),
            ),
          ),

          const Divider(height: 32),

          // メンバー一覧（階級4以上のみ閲覧可能）
          if (myRole.canViewMemberRanks) ...[
            Text(
              'メンバー階級一覧',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...members.map((member) => Card(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _rankColor(member.rank),
                      child: Text(
                        '${member.rank.level}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(member.userId),
                    subtitle: Text(member.rank.label),
                    trailing: myRole.canModifyRankOf(member)
                        ? IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('階級変更（プロトタイプ）')),
                              );
                            },
                          )
                        : null,
                  ),
                )),
          ] else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.lock, color: Colors.grey.shade400),
                    const SizedBox(width: 8),
                    Text(
                      'メンバー階級一覧は上位権限者のみ閲覧可能です',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: enabled ? null : Colors.grey.shade400),
      title: Text(
        title,
        style: TextStyle(color: enabled ? null : Colors.grey.shade400),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                  color: enabled ? Colors.grey.shade600 : Colors.grey.shade300),
            )
          : null,
      trailing: enabled
          ? const Icon(Icons.chevron_right)
          : Icon(Icons.lock, size: 16, color: Colors.grey.shade400),
      onTap: enabled ? onTap : null,
    );
  }

  Color _rankColor(GroupRank rank) {
    switch (rank) {
      case GroupRank.owner:
        return Colors.amber.shade700;
      case GroupRank.admin:
        return Colors.blue.shade600;
      case GroupRank.member:
        return Colors.green.shade600;
      case GroupRank.restricted:
        return Colors.orange.shade600;
      case GroupRank.viewer:
        return Colors.grey.shade600;
    }
  }
}
