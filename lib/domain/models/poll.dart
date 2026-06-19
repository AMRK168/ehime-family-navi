/// 投票オプション
class PollOption {
  final String optionId;
  final String eventId;
  final String label;
  final List<String> voterIds;

  const PollOption({
    required this.optionId,
    required this.eventId,
    required this.label,
    required this.voterIds,
  });
}

/// 投票モデル
/// 一般グループでの行き先候補に対する多数決に使用。
class Poll {
  final String pollId;
  final String groupId;
  final String createdByUserId;
  final String question;
  final List<PollOption> options;
  final DateTime deadline;
  final bool isClosed;

  const Poll({
    required this.pollId,
    required this.groupId,
    required this.createdByUserId,
    required this.question,
    required this.options,
    required this.deadline,
    required this.isClosed,
  });
}
