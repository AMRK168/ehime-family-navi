import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/group.dart';

/// ファミリーチャット画面
/// 家族間メッセージング。共有チェックボックスで気になるスポットを共有。
/// AIの存在はUIに明示しない。
class FamilyChatScreen extends ConsumerStatefulWidget {
  final AppGroup group;

  const FamilyChatScreen({super.key, required this.group});

  @override
  ConsumerState<FamilyChatScreen> createState() => _FamilyChatScreenState();
}

class _FamilyChatScreenState extends ConsumerState<FamilyChatScreen> {
  final _messageController = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _surpriseMode = false;

  @override
  void initState() {
    super.initState();
    // サンプルメッセージ（AIファシリテーションを自然に表現）
    _messages.addAll([
      _ChatMessage(
        sender: 'お母さん',
        text: '週末どこか行きたいね！',
        timestamp: DateTime(2026, 7, 10, 18, 30),
      ),
      _ChatMessage(
        sender: 'お父さん',
        text: 'とべ動物園はどう？太郎も喜ぶと思う',
        timestamp: DateTime(2026, 7, 10, 18, 35),
      ),
      _ChatMessage(
        sender: 'システム',
        text: '週末は晴れの予報です。アウトドアスポットが楽しめそうですね。',
        timestamp: DateTime(2026, 7, 10, 18, 36),
        isSystemMessage: true,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        actions: [
          // サプライズモード切り替え
          IconButton(
            icon: Icon(
              _surpriseMode ? Icons.visibility_off : Icons.visibility,
              color: _surpriseMode ? Colors.orange : null,
            ),
            tooltip: 'サプライズモード',
            onPressed: () {
              setState(() {
                _surpriseMode = !_surpriseMode;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _surpriseMode
                        ? 'サプライズモード ON（共有が一時的にオフ）'
                        : 'サプライズモード OFF',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // メッセージリスト
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          // 入力エリア
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'メッセージを入力...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg) {
    if (msg.isSystemMessage) {
      // AIファシリテーションメッセージ（存在を明示しない自然な提案）
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg.text,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final isMe = msg.sender == 'お父さん'; // モック: 現在のユーザー
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  msg.sender,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            Text(
              msg.text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(
        sender: 'お父さん',
        text: text,
        timestamp: DateTime.now(),
      ));
    });
    _messageController.clear();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

/// チャットメッセージモデル
class _ChatMessage {
  final String sender;
  final String text;
  final DateTime timestamp;
  final bool isSystemMessage;

  const _ChatMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
    this.isSystemMessage = false,
  });
}
