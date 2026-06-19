import '../../domain/repositories/point_service.dart';

/// ポイントサービスのモック実装
/// インメモリでポイント残高を管理する（初期値250pt）
class MockPointService implements PointService {
  final Map<String, int> _balances = {};
  final List<Map<String, dynamic>> _history = [];

  static const int _defaultBalance = 250;

  /// ポイント履歴の取得（テスト用）
  List<Map<String, dynamic>> get history => List.unmodifiable(_history);

  @override
  Future<int> getBalance(String userId) async {
    return _balances[userId] ?? _defaultBalance;
  }

  @override
  Future<void> addPoints({
    required String userId,
    required int amount,
    required String reason,
  }) async {
    final current = _balances[userId] ?? _defaultBalance;
    _balances[userId] = current + amount;
    _history.add({
      'userId': userId,
      'amount': amount,
      'type': 'add',
      'reason': reason,
      'balance': _balances[userId],
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<bool> deductPoints({
    required String userId,
    required int amount,
    required String reason,
  }) async {
    final current = _balances[userId] ?? _defaultBalance;
    if (current < amount) return false; // 残高不足
    _balances[userId] = current - amount;
    _history.add({
      'userId': userId,
      'amount': -amount,
      'type': 'deduct',
      'reason': reason,
      'balance': _balances[userId],
      'timestamp': DateTime.now().toIso8601String(),
    });
    return true;
  }
}
