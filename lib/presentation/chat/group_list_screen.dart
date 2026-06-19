import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../data/providers/app_providers.dart';
import '../../domain/models/group.dart';
import '../qr/qr_screen.dart' show parseQrUri, JoinGroupAction;
import 'family_chat_screen.dart';
import 'general_group_screen.dart';

/// グループリスト画面
/// ファミリーグループと一般グループを切り替えて表示する。
class GroupListScreen extends ConsumerStatefulWidget {
  const GroupListScreen({super.key});

  @override
  ConsumerState<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends ConsumerState<GroupListScreen> {
  @override
  Widget build(BuildContext context) {
    final groupService = ref.watch(groupServiceProvider);
    final groups = groupService.allGroups;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('グループ'),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              tooltip: '招待QR読み取り',
              onPressed: () => _showGroupQrScanner(context, ref),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.family_restroom), text: 'ファミリー'),
              Tab(icon: Icon(Icons.groups), text: '一般グループ'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ファミリーグループタブ
            _GroupListView(
              groupType: GroupType.family,
              groups: groups.where((g) => g.type == GroupType.family).toList(),
              onTap: (group) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FamilyChatScreen(group: group),
                  ),
                );
              },
              onCreate: () => _showCreateGroupDialog(context, ref, GroupType.family),
            ),
            // 一般グループタブ
            _GroupListView(
              groupType: GroupType.general,
              groups: groups.where((g) => g.type == GroupType.general).toList(),
              onTap: (group) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GeneralGroupScreen(group: group),
                  ),
                );
              },
              onCreate: () => _showCreateGroupDialog(context, ref, GroupType.general),
              emptyMessage: '一般グループに参加していません',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showJoinGroupDialog(context, ref),
          child: const Icon(Icons.group_add),
        ),
      ),
    );
  }

  void _showJoinGroupDialog(BuildContext context, WidgetRef ref) {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('グループに参加'),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(
            labelText: '招待コード',
            hintText: '招待コードを入力',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () async {
              final code = codeController.text.trim();
              if (code.isNotEmpty) {
                final groupService = ref.read(groupServiceProvider);
                final userId = ref.read(currentUserIdProvider);
                await groupService.joinGroup(
                  userId: userId,
                  inviteCode: code,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  setState(() {}); // リスト再描画
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('グループに参加しました')),
                  );
                }
              }
            },
            child: const Text('参加'),
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog(
      BuildContext context, WidgetRef ref, GroupType type) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(type == GroupType.family
            ? 'ファミリーグループを作成'
            : '一般グループを作成'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'グループ名',
            hintText: 'グループ名を入力',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                final groupService = ref.read(groupServiceProvider);
                final userId = ref.read(currentUserIdProvider);
                await groupService.createGroup(
                  type: type,
                  name: name,
                  creatorId: userId,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  setState(() {}); // リスト再描画
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('「$name」を作成しました')),
                  );
                }
              }
            },
            child: const Text('作成'),
          ),
        ],
      ),
    );
  }

  void _showGroupQrScanner(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.6,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    '招待QR読み取り',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Expanded(
              child: MobileScanner(
                onDetect: (capture) {
                  final barcode = capture.barcodes.firstOrNull;
                  if (barcode == null || barcode.rawValue == null) return;
                  final action = parseQrUri(barcode.rawValue!);
                  if (action is JoinGroupAction) {
                    Navigator.pop(ctx);
                    final groupService = ref.read(groupServiceProvider);
                    final userId = ref.read(currentUserIdProvider);
                    groupService.joinGroup(
                      userId: userId,
                      inviteCode: action.inviteCode,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('グループに参加しました')),
                    );
                  } else {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('グループ招待用QRコードではありません')),
                    );
                  }
                },
                errorBuilder: (context, error, child) {
                  return Center(
                    child: Text(
                      'カメラへのアクセスが許可されていません',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// グループリスト表示ウィジェット
class _GroupListView extends StatelessWidget {
  final List<AppGroup> groups;
  final Function(AppGroup) onTap;
  final VoidCallback? onCreate;
  final String emptyMessage;
  final GroupType groupType;

  const _GroupListView({
    required this.groups,
    required this.onTap,
    this.onCreate,
    this.emptyMessage = 'グループがありません',
    this.groupType = GroupType.family,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // グループ作成ボタン
        if (onCreate != null)
          SizedBox(
            height: 48,
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('グループを作成'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        if (onCreate != null) const SizedBox(height: 12),
        if (onCreate != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'グループ名',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
            ),
          ),

        // グループリスト
        if (groups.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.group_off, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    emptyMessage,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          )
        else
          ...groups.map((group) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: group.type == GroupType.family
                        ? Colors.orange.shade100
                        : Colors.blue.shade100,
                    child: Icon(
                      group.type == GroupType.family
                          ? Icons.family_restroom
                          : Icons.groups,
                      color: group.type == GroupType.family
                          ? Colors.orange
                          : Colors.blue,
                    ),
                  ),
                  title: Text(group.name),
                  subtitle: Text('${group.memberIds.length}人のメンバー'),
                  trailing: group.status == GroupStatus.archived
                      ? const Chip(
                          label:
                              Text('アーカイブ', style: TextStyle(fontSize: 10)),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.qr_code, size: 20),
                              tooltip: 'QRで招待',
                              onPressed: () =>
                                  _showInviteQrDialog(context, group),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                  onTap: group.status == GroupStatus.active
                      ? () => onTap(group)
                      : null,
                ),
              )),
      ],
    );
  }

  void _showInviteQrDialog(BuildContext context, AppGroup group) {
    final inviteUri = 'ehime-navi://invite/${group.inviteCode}';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.qr_code, color: Color(0xFFFF8C00)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${group.name} に招待',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 250,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: QrImageView(
                    data: inviteUri,
                    version: QrVersions.auto,
                    size: 200,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '招待コード: ${group.inviteCode}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'このQRを読み取ってもらうと\nグループに参加できます',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}
