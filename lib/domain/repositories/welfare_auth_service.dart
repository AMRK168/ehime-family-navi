/// 福利厚生会社認証サービスの抽象インターフェース
/// 【拡張意図】福利厚生会社のOAuth2/OpenID Connect連携時に実装を差し替える。
/// 設計方針: 個人情報（氏名・住所・社員番号等）は一切受け取らない。
/// 受け取るのは「承認トークン」と「プランID」のみ。
/// これによりプライバシーリスクをゼロにしつつ、
/// ユーザーが福利厚生会社の会員であることだけを確認できる。
/// TODO: 福利厚生会社のOAuth2/OpenID Connect実装時に差し替える
abstract class WelfareAuthService {
  /// 福利厚生会社の認証ページURLを取得（外部ブラウザで開く）
  Future<String> getAuthorizationUrl();

  /// コールバックで受け取った認可コードからトークンを取得
  /// 返却: 承認トークン（個人情報は含まない）
  Future<WelfareAuthToken?> exchangeCode(String authorizationCode);

  /// トークンの有効性を検証（期限切れチェック）
  Future<bool> validateToken(WelfareAuthToken token);

  /// 連携解除（トークン無効化）
  Future<void> revokeToken(WelfareAuthToken token);
}

/// 承認トークン（個人情報を含まない）
class WelfareAuthToken {
  final String accessToken;
  final String planId;
  final DateTime expiresAt;

  const WelfareAuthToken({
    required this.accessToken,
    required this.planId,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
