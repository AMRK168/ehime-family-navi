import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'config/feature_flags.dart';
import 'data/mock/mock_daily_token_service.dart';
import 'data/providers/app_providers.dart';
import 'domain/models/user_settings.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/schedule/schedule_screen.dart';
import 'presentation/chat/group_list_screen.dart';
import 'presentation/bulletin/bulletin_screen.dart';
import 'presentation/qr/qr_screen.dart';
import 'presentation/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja_JP', null);
  runApp(
    const ProviderScope(
      child: EhimeFamilyNaviApp(),
    ),
  );
}

/// えひめファミリーナビ メインアプリ
class EhimeFamilyNaviApp extends ConsumerWidget {
  const EhimeFamilyNaviApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(userSettingsProvider);
    final seedColor = Color(settings.colorTheme.colorValue);
    final brightness = settings.brightness == AppBrightness.dark
        ? Brightness.dark
        : Brightness.light;

    return MaterialApp(
      title: 'えひめファミリーナビ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: brightness,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      home: const MainNavigation(),
    );
  }
}

/// メインナビゲーション（BottomNavigationBar）
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  List<Widget> get _screens => [
        const HomeScreen(),
        const ScheduleScreen(),
        const GroupListScreen(),
        const BulletinScreen(),
        if (FeatureFlags.enableQrCode) const QrScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    final isQrTab = FeatureFlags.enableQrCode && _currentIndex == 4;

    return Scaffold(
      // QRタブ選択時はQrScreen自身がAppBarを持つため非表示
      appBar: isQrTab
          ? null
          : AppBar(
              title: GestureDetector(
                onLongPress: () => _showAdminCheckinQr(context),
                child: const Text('えひめファミリーナビ'),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: '設定',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search, color: Color(0xFFFF8C00)),
            label: '検索',
          ),
          const NavigationDestination(
            icon: Icon(Icons.calendar_month),
            selectedIcon: Icon(Icons.calendar_month, color: Color(0xFFFF8C00)),
            label: 'スケジュール',
          ),
          const NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble, color: Color(0xFFFF8C00)),
            label: 'グループ',
          ),
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: Color(0xFFFF8C00)),
            label: '掲示板',
          ),
          if (FeatureFlags.enableQrCode)
            const NavigationDestination(
              icon: Icon(Icons.check_circle_outline),
              selectedIcon:
                  Icon(Icons.check_circle, color: Color(0xFFFF8C00)),
              label: 'チェックイン',
            ),
        ],
      ),
    );
  }

  void _showAdminCheckinQr(BuildContext context) {
    final tokenService = MockDailyTokenService();
    final uri = tokenService.buildDailyCheckinUri(
      eventId: 'sp_001',
      date: DateTime.now(),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('管理者デモ', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '本日のチェックインQR',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: uri,
                version: QrVersions.auto,
                size: 200,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '⚠️ このQRは本日のみ有効\n翌日には自動で無効になります',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
