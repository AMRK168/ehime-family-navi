import 'package:uuid/uuid.dart';

import '../../domain/repositories/welfare_auth_service.dart';

/// 福利厚生会社認証のモック実装
/// 実際のOAuth連携なし。即座にダミートークンを発行する。
class MockWelfareAuthService implements WelfareAuthService {
  static const _uuid = Uuid();

  @override
  Future<String> getAuthorizationUrl() async {
    // 本番: 福利厚生会社のOAuth認証ページURL
    return 'https://welfare-partner.example.com/oauth/authorize?client_id=ehime_navi';
  }

  @override
  Future<WelfareAuthToken?> exchangeCode(String authorizationCode) async {
    // 本番: 認可コードをトークンに交換
    // モック: 即座にダミートークンを返す
    return WelfareAuthToken(
      accessToken: _uuid.v4(),
      planId: 'plan_ehime_standard',
      expiresAt: DateTime.now().add(const Duration(days: 365)),
    );
  }

  @override
  Future<bool> validateToken(WelfareAuthToken token) async {
    return !token.isExpired;
  }

  @override
  Future<void> revokeToken(WelfareAuthToken token) async {
    // 本番: サーバーにトークン無効化を通知
  }
}
