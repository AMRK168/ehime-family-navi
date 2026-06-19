import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../data/providers/app_providers.dart';
import '../../domain/models/user_settings.dart';

// ─── QR URI パース ───────────────────────────────────────────

/// QRコードから読み取ったURIに基づくアクション
sealed class QrAction {
  const QrAction();
}

class JoinGroupAction extends QrAction {
  final String inviteCode;
  const JoinGroupAction(this.inviteCode);
}

class ViewEventAction extends QrAction {
  final String eventId;
  const ViewEventAction(this.eventId);
}

class CheckinAction extends QrAction {
  final String eventId;
  final String dailyToken;
  const CheckinAction(this.eventId, this.dailyToken);
}

class InvalidQrAction extends QrAction {
  const InvalidQrAction();
}

/// URI文字列からQrActionにパース
/// スキーム: ehime-navi://invite/{code}, ehime-navi://event/{id}, ehime-navi://checkin/{eventId}/{dailyToken}
QrAction parseQrUri(String rawValue) {
  final uri = Uri.tryParse(rawValue);
  if (uri == null || uri.scheme != 'ehime-navi') {
    return const InvalidQrAction();
  }
  if (uri.host == 'invite' && uri.pathSegments.isNotEmpty) {
    return JoinGroupAction(uri.pathSegments.first);
  }
  if (uri.host == 'event' && uri.pathSegments.isNotEmpty) {
    return ViewEventAction(uri.pathSegments.first);
  }
  if (uri.host == 'checkin' && uri.pathSegments.length >= 2) {
    return CheckinAction(uri.pathSegments[0], uri.pathSegments[1]);
  }
  return const InvalidQrAction();
}

/// チェックインURIの生成（日次トークン付き）
String buildCheckinUri(String eventId, String dailyToken) =>
    'ehime-navi://checkin/$eventId/$dailyToken';

// ─── QR画面 ─────────────────────────────────────────────────

/// チェックイン画面
/// 設定のデフォルト方式に応じてNFCタッチ or QR提示を表示。
/// ページ内で一時切り替え可能（デフォルト設定は変わらない）。
class QrScreen extends ConsumerWidget {
  const QrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMethod = ref.watch(currentCheckinMethodProvider);
    final userId = ref.watch(currentUserIdProvider);
    final dailyTokenService = ref.watch(dailyTokenServiceProvider);

    final now = DateTime.now();
    final token = dailyTokenService.generateToken(
      eventId: 'user_checkin_$userId',
      date: now,
    );
    final checkinUri = 'ehime-navi://checkin/user_checkin_$userId/$token';

    return Scaffold(
      appBar: AppBar(
        title: const Text('チェックイン'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ポイント残高表示（サーバー管理項目）
            _buildPointBalance(context, ref),
            const SizedBox(height: 24),

            // 方式切り替えボタン
            SegmentedButton<CheckinMethod>(
              segments: const [
                ButtonSegment(
                  value: CheckinMethod.nfcTouch,
                  icon: Icon(Icons.contactless),
                  label: Text('タッチ'),
                ),
                ButtonSegment(
                  value: CheckinMethod.qrPresent,
                  icon: Icon(Icons.qr_code),
                  label: Text('QR提示'),
                ),
              ],
              selected: {currentMethod},
              onSelectionChanged: (selection) {
                // 一時切り替えのみ（デフォルト設定は変更しない）
                ref.read(currentCheckinMethodProvider.notifier).state =
                    selection.first;
              },
            ),
            const SizedBox(height: 24),

            // 方式に応じた表示
            if (currentMethod == CheckinMethod.nfcTouch)
              _buildNfcTouchView(context)
            else
              _buildQrPresentView(context, checkinUri, userId, now),
          ],
        ),
      ),
    );
  }

  Widget _buildNfcTouchView(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.contactless,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'イベント受付の端末にタッチしてください',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // NFCアニメーション風の表示
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              width: 3,
            ),
          ),
          child: Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.5),
              ),
              child: Icon(
                Icons.smartphone,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                'NFCが有効になっていることを確認してください',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '端末の背面を受付端末に近づけてください',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '※ NFC非対応の場合はQR提示に切り替えてください',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildQrPresentView(
      BuildContext context, String checkinUri, String userId, DateTime now) {
    return Column(
      children: [
        Icon(
          Icons.qr_code_2,
          size: 48,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Text(
          'イベント受付でこのQRを提示してください',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // QRコード表示
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: QrImageView(
            data: checkinUri,
            version: QrVersions.auto,
            size: 220,
          ),
        ),
        const SizedBox(height: 24),

        // ユーザー情報
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'ユーザーID: $userId',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.today, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    '有効期限: ${now.year}/${now.month}/${now.day} のみ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '※ このQRコードは本日限り有効です\n※ 翌日には自動的に新しいコードに切り替わります',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPointBalance(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(pointBalanceProvider);
    final balance = balanceAsync.valueOrNull ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'ポイント残高',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$balance pt',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
