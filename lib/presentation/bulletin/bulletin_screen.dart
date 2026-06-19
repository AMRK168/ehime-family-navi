import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../config/feature_flags.dart';
import '../../data/providers/app_providers.dart';
import '../../domain/models/event.dart';
import '../../domain/repositories/sponsor_service.dart';
import '../qr/qr_screen.dart' show parseQrUri, ViewEventAction;
import 'event_detail_screen.dart';

// ─── AdSlot interleave ロジック ──────────────────────────────

/// イベントリストにスポンサーカードを挿入する
/// 5件の通常イベントごとに1件のスポンサーイベントを挿入
List<dynamic> interleaveWithAdSlots({
  required List<Event> events,
  required List<SponsorEvent> sponsorEvents,
}) {
  final result = <dynamic>[];
  int sponsorIndex = 0;
  for (int i = 0; i < events.length; i++) {
    result.add(events[i]);
    if ((i + 1) % 5 == 0 && sponsorIndex < sponsorEvents.length) {
      result.add(sponsorEvents[sponsorIndex]);
      sponsorIndex++;
    }
  }
  return result;
}

// ─── 掲示板画面 ─────────────────────────────────────────────

/// 掲示板画面（イベント情報）
/// 地域イベント・協賛企業イベントのリスト表示。
/// ポイント付与の仕組み: ページ遷移→予約完了でポイント加算。
class BulletinScreen extends ConsumerWidget {
  const BulletinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    final sponsorEventsAsync = FeatureFlags.enableSponsorApi
        ? ref.watch(sponsorEventsProvider)
        : null;
    final checkedInIds = FeatureFlags.enableCheckinSystem
        ? (ref.watch(checkedInEventIdsProvider).valueOrNull ?? <String>{})
        : <String>{};

    return Scaffold(
      appBar: AppBar(
        title: const Text('掲示板'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'イベントQR読み取り',
            onPressed: () => _showEventQrScanner(context),
          ),
        ],
      ),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラーが発生しました: $e')),
        data: (events) {
          // スポンサーイベント取得
          List<SponsorEvent> sponsorEvents = [];
          if (sponsorEventsAsync != null) {
            sponsorEvents = sponsorEventsAsync.valueOrNull ?? [];
          }

          // AdSlot統合
          final displayItems = FeatureFlags.enableSponsorApi &&
                  sponsorEvents.isNotEmpty
              ? interleaveWithAdSlots(
                  events: events, sponsorEvents: sponsorEvents)
              : events.map((e) => e as dynamic).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: displayItems.length +
                (FeatureFlags.enablePointSystem ? 1 : 0) +
                1, // +1 for header
            itemBuilder: (context, index) {
              // ポイントカード
              if (FeatureFlags.enablePointSystem && index == 0) {
                return _buildPointCard(context, ref);
              }
              final offset = FeatureFlags.enablePointSystem ? 1 : 0;

              // セクションヘッダー
              if (index == offset) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '地域イベント',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                );
              }

              final itemIndex = index - offset - 1;
              if (itemIndex >= displayItems.length) return const SizedBox();

              final item = displayItems[itemIndex];
              if (item is SponsorEvent) {
                return _buildSponsorEventCard(context, item);
              } else if (item is Event) {
                return _buildEventCard(context, item,
                    isCheckedIn: checkedInIds.contains(item.id));
              }
              return const SizedBox();
            },
          );
        },
      ),
    );
  }

  Widget _buildPointCard(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(pointBalanceProvider);
    final balance = balanceAsync.valueOrNull ?? 0;

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.stars,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ポイント残高',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '$balance pt',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Event event,
      {bool isCheckedIn = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EventDetailScreen(event: event),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (FeatureFlags.enableCheckinSystem && isCheckedIn)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle,
                              size: 12, color: Colors.green.shade700),
                          const SizedBox(width: 2),
                          Text(
                            'チェックイン済',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(event.dateTime),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                event.category,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSponsorEventCard(BuildContext context, SponsorEvent sponsor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${sponsor.event.title} の詳細を表示')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      sponsor.event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  // スポンサーラベル
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: const Text(
                      'スポンサー',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(sponsor.event.dateTime),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                sponsor.event.category,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.business, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    '協賛: ${sponsor.sponsorName}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                  const Spacer(),
                  if (FeatureFlags.enablePointSystem)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '+${sponsor.pointReward}pt',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}年${dt.month}月${dt.day}日';
  }

  void _showEventQrScanner(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'イベントQR読み取り',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
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
                  if (action is ViewEventAction) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('イベント表示: ${action.eventId}')),
                    );
                  } else {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('イベント用QRコードではありません')),
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
