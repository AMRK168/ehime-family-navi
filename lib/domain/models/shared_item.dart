/// 選択共有アイテム
/// ユーザーが能動的に共有したスポット/イベント情報。
class SharedItem {
  final String itemId;
  final String sharedByUserId;
  final String targetGroupId;
  final String eventId;
  final DateTime sharedAt;
  final bool isSurpriseHidden;

  const SharedItem({
    required this.itemId,
    required this.sharedByUserId,
    required this.targetGroupId,
    required this.eventId,
    required this.sharedAt,
    required this.isSurpriseHidden,
  });
}
