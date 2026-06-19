import '../models/poll.dart';

/// 投票サービスの抽象インターフェース
abstract class PollService {
  Future<Poll> createPoll({
    required String groupId,
    required String creatorId,
    required String question,
    required List<String> eventIds,
    required DateTime deadline,
  });
  Future<void> vote({
    required String pollId,
    required String optionId,
    required String userId,
  });
  Future<Poll> getResults(String pollId);
  Future<void> closePoll(String pollId);
}
