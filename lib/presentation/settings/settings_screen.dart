import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/app_providers.dart';
import '../../domain/models/user_settings.dart';

/// 設定画面
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(userSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── 外観 ───
          _buildSectionHeader(context, '外観'),
          _buildColorThemeTile(context, ref, settings),
          _buildBrightnessTile(context, ref, settings),
          const Divider(height: 32),

          // ─── チェックイン ───
          _buildSectionHeader(context, 'チェックイン'),
          _buildCheckinMethodTile(context, ref, settings),
          const Divider(height: 32),

          // ─── ユーザー情報 ───
          _buildSectionHeader(context, 'ユーザー情報'),
          _buildNicknameTile(context, ref, settings),
          _buildRegionTile(context, ref, settings),
          _buildFamilyTile(context, ref),
          _buildWelfareTile(context, settings),
          const Divider(height: 32),

          // ─── アプリ情報 ───
          _buildSectionHeader(context, 'アプリ情報'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('バージョン'),
            trailing: Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('ライセンス'),
            onTap: () => showLicensePage(context: context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildColorThemeTile(
      BuildContext context, WidgetRef ref, UserSettings settings) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Color(settings.colorTheme.colorValue),
        radius: 16,
      ),
      title: const Text('カラーテーマ'),
      subtitle: Text(settings.colorTheme.label),
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => SimpleDialog(
            title: const Text('カラーテーマ'),
            children: AppColorTheme.values.map((theme) {
              return SimpleDialogOption(
                onPressed: () {
                  ref.read(userSettingsProvider.notifier).state =
                      settings.copyWith(colorTheme: theme);
                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(theme.colorValue),
                      radius: 12,
                    ),
                    const SizedBox(width: 12),
                    Text(theme.label),
                    if (theme == settings.colorTheme)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(Icons.check, size: 18),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildBrightnessTile(
      BuildContext context, WidgetRef ref, UserSettings settings) {
    return SwitchListTile(
      secondary: Icon(settings.brightness == AppBrightness.dark
          ? Icons.dark_mode
          : Icons.light_mode),
      title: const Text('ダークモード'),
      value: settings.brightness == AppBrightness.dark,
      onChanged: (value) {
        ref.read(userSettingsProvider.notifier).state = settings.copyWith(
          brightness: value ? AppBrightness.dark : AppBrightness.light,
        );
      },
    );
  }

  Widget _buildCheckinMethodTile(
      BuildContext context, WidgetRef ref, UserSettings settings) {
    return ListTile(
      leading: Icon(settings.defaultCheckinMethod == CheckinMethod.nfcTouch
          ? Icons.contactless
          : Icons.qr_code),
      title: const Text('デフォルトチェックイン方式'),
      subtitle: Text(
        settings.defaultCheckinMethod == CheckinMethod.nfcTouch
            ? 'NFCタッチ'
            : 'QR提示',
      ),
      trailing: SegmentedButton<CheckinMethod>(
        segments: const [
          ButtonSegment(
            value: CheckinMethod.nfcTouch,
            icon: Icon(Icons.contactless),
            label: Text('タッチ'),
          ),
          ButtonSegment(
            value: CheckinMethod.qrPresent,
            icon: Icon(Icons.qr_code),
            label: Text('QR'),
          ),
        ],
        selected: {settings.defaultCheckinMethod},
        onSelectionChanged: (selection) {
          ref.read(userSettingsProvider.notifier).state =
              settings.copyWith(defaultCheckinMethod: selection.first);
          // デフォルト変更時は一時切り替えもリセット
          ref.read(currentCheckinMethodProvider.notifier).state =
              selection.first;
        },
      ),
    );
  }

  Widget _buildNicknameTile(
      BuildContext context, WidgetRef ref, UserSettings settings) {
    return ListTile(
      leading: const Icon(Icons.person),
      title: const Text('ニックネーム'),
      subtitle: Text(
          settings.nickname.isEmpty ? '未設定' : settings.nickname),
      onTap: () {
        final controller = TextEditingController(text: settings.nickname);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('ニックネーム'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'ニックネームを入力',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
              FilledButton(
                onPressed: () {
                  ref.read(userSettingsProvider.notifier).state =
                      settings.copyWith(nickname: controller.text.trim());
                  Navigator.pop(context);
                },
                child: const Text('保存'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRegionTile(
      BuildContext context, WidgetRef ref, UserSettings settings) {
    const regions = ['松山市', '今治市', '新居浜市', '宇和島市', '西条市', '四国中央市', 'その他'];
    return ListTile(
      leading: const Icon(Icons.location_on),
      title: const Text('地域'),
      subtitle: Text(settings.region.isEmpty ? '未設定' : settings.region),
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => SimpleDialog(
            title: const Text('地域を選択'),
            children: regions.map((region) {
              return SimpleDialogOption(
                onPressed: () {
                  ref.read(userSettingsProvider.notifier).state =
                      settings.copyWith(region: region);
                  Navigator.pop(context);
                },
                child: Text(region),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildFamilyTile(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(familyProfileProvider);
    return ListTile(
      leading: const Icon(Icons.family_restroom),
      title: const Text('家族構成'),
      subtitle: Text('${profile.members.length}人'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('家族構成編集画面（将来実装）')),
        );
      },
    );
  }

  Widget _buildWelfareTile(BuildContext context, UserSettings settings) {
    final partner = settings.welfarePartner;
    return ListTile(
      leading: Icon(
        Icons.business,
        color: partner != null && partner.isActive
            ? Colors.green
            : Colors.grey,
      ),
      title: const Text('連携福利厚生会社'),
      subtitle: Text(
        partner != null && partner.isActive
            ? '${partner.companyName}（${partner.planName}）'
            : '連携なし',
      ),
      trailing: partner != null && partner.isActive
          ? Chip(
              label: const Text('連携中',
                  style: TextStyle(fontSize: 11, color: Colors.white)),
              backgroundColor: Colors.green,
            )
          : null,
    );
  }
}
