import 'package:uuid/uuid.dart';

import '../../domain/models/poll.dart';
import '../../domain/repositories/poll_service.dart';

/// モック投票サービス
class MockPollService implements PollService {
  final _uuid = const Uuid();
  final List<Poll> _polls = [];

  @override
  Future<Poll> createPoll({
    required String groupId,
    required String creatorId,
    required String question,
    required List<String> eventIds,
    required DateTime deadline,
  }) async {
    final poll = Poll(
      pollId: _uuid.v4(),
      groupId: groupId,
      createdByUserId: creatorId,
      question: question,
      options: eventIds
          .map((eventId) => PollOption(
                optionId: _uuid.v4(),
                eventId: eventId,
                label: eventId,
                voterIds: [],
              ))
          .toList(),
      deadline: deadline,
      isClosed: false,
    );
    _polls.add(poll);
    return poll;
  }

  @override
  Future<void> vote({
    required String pollId,
    required String optionId,
    required String userId,
  }) async {
    // モック: 投票を記録（簡易実装）
  }

  @override
  Future<Poll> getResults(String pollId) async {
    return _polls.firstWhere((p) => p.pollId == pollId);
  }

  @override
  Future<void> closePoll(String pollId) async {
    // モック: 投票を締め切る
  }
}
