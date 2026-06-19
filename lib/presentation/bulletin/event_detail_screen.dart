import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../domain/models/event.dart';

/// イベント詳細画面
/// 掲示板のイベントカードをタップすると表示される。
/// 画面下部にイベント共有用QRコードを表示（DBから取得する前提）。
class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    // DBから取得する前提のQR URI（実際にはAPIから返却される）
    final eventQrUri = 'ehime-navi://event/${event.id}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('イベント詳細'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // イベントタイトル
            Text(
              event.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            // カテゴリ
            Chip(
              label: Text(event.category),
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
            ),
            const SizedBox(height: 16),

            // 日時
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  '${event.dateTime.year}年${event.dateTime.month}月${event.dateTime.day}日',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 場所
            Row(
              children: [
                Icon(Icons.location_on, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.location.address ?? '愛媛県内',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 予約ボタン（予約が必要な場合）
            if (event.requiresReservation)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('予約サイトへ遷移します')),
                    );
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('予約する'),
                ),
              ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            // QRコード共有セクション
            Center(
              child: Column(
                children: [
                  Text(
                    'イベント共有QRコード',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'このQRを読み取ってもらうとイベント情報を共有できます',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: eventQrUri,
                      version: QrVersions.auto,
                      size: 200,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '※ サーバーから取得されたQRコード',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
