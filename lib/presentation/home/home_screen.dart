import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/app_providers.dart';
import '../../domain/models/event.dart';

/// メイン検索画面（ホーム）
/// 初期起動時はカテゴリキーワードのみ表示。
/// 選択後に家族構成に基づくフィルタリング結果を表示する。
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // カテゴリ一覧
  static const List<Map<String, dynamic>> _categories = [
    {'label': 'アウトドア', 'icon': Icons.park, 'color': Color(0xFF4CAF50)},
    {'label': 'インドア', 'icon': Icons.home, 'color': Color(0xFF2196F3)},
    {'label': '芸術', 'icon': Icons.palette, 'color': Color(0xFF9C27B0)},
    {'label': '体験イベント', 'icon': Icons.celebration, 'color': Color(0xFFFF9800)},
    {'label': 'アトラクション', 'icon': Icons.attractions, 'color': Color(0xFFE91E63)},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('えひめファミリーナビ'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // カテゴリ選択エリア
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'カテゴリから探す',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final isSelected = selectedCategory == cat['label'];
                      return ChoiceChip(
                        avatar: Icon(
                          cat['icon'] as IconData,
                          size: 18,
                          color: isSelected ? Colors.white : cat['color'] as Color,
                        ),
                        label: Text(cat['label'] as String),
                        selected: isSelected,
                        selectedColor: cat['color'] as Color,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                        onSelected: (selected) {
                          ref.read(selectedCategoryProvider.notifier).state =
                              selected ? cat['label'] as String : null;
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // イベントリスト
            Expanded(
              child: eventsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('エラー: $err')),
                data: (events) {
                  if (events.isEmpty) {
                    return const Center(
                      child: Text('該当するスポットがありません'),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return _EventCard(event: events[index]);
                    },
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

/// イベントカードウィジェット
class _EventCard extends StatelessWidget {
  final Event event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _categoryIcon(event.category),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (event.sponsorId != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ポイント付',
                      style: TextStyle(fontSize: 10, color: Colors.orange),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.location.address ?? '愛媛県',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.category, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  event.category,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const Spacer(),
                if (event.requiresReservation)
                  TextButton.icon(
                    onPressed: () {
                      // TODO: 外部予約サイトへ遷移
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('予約サイトへ遷移します')),
                      );
                    },
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('予約する', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryIcon(String category) {
    IconData icon;
    Color color;
    switch (category) {
      case 'アウトドア':
        icon = Icons.park;
        color = const Color(0xFF4CAF50);
        break;
      case 'インドア':
        icon = Icons.home;
        color = const Color(0xFF2196F3);
        break;
      case '芸術':
        icon = Icons.palette;
        color = const Color(0xFF9C27B0);
        break;
      case '体験イベント':
        icon = Icons.celebration;
        color = const Color(0xFFFF9800);
        break;
      case 'アトラクション':
        icon = Icons.attractions;
        color = const Color(0xFFE91E63);
        break;
      default:
        icon = Icons.place;
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}
