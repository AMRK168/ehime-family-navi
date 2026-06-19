/// チェックイン方式
enum CheckinMethod { nfcTouch, qrPresent }

/// カラーテーマ
enum AppColorTheme {
  mikan(0xFFFF8C00, 'みかん'),
  blue(0xFF2196F3, 'ブルー'),
  green(0xFF4CAF50, 'グリーン'),
  purple(0xFF9C27B0, 'パープル');

  final int colorValue;
  final String label;
  const AppColorTheme(this.colorValue, this.label);
}

/// 表示モード
enum AppBrightness { light, dark }

/// 連携福利厚生会社情報
class WelfarePartner {
  final String companyName;
  final String planName;
  final bool isActive;

  const WelfarePartner({
    required this.companyName,
    required this.planName,
    required this.isActive,
  });
}

/// ユーザー設定モデル
class UserSettings {
  final AppColorTheme colorTheme;
  final AppBrightness brightness;
  final CheckinMethod defaultCheckinMethod;
  final String nickname;
  final String region;
  final WelfarePartner? welfarePartner;

  const UserSettings({
    this.colorTheme = AppColorTheme.mikan,
    this.brightness = AppBrightness.light,
    this.defaultCheckinMethod = CheckinMethod.nfcTouch,
    this.nickname = '',
    this.region = '',
    this.welfarePartner,
  });

  UserSettings copyWith({
    AppColorTheme? colorTheme,
    AppBrightness? brightness,
    CheckinMethod? defaultCheckinMethod,
    String? nickname,
    String? region,
    WelfarePartner? welfarePartner,
  }) {
    return UserSettings(
      colorTheme: colorTheme ?? this.colorTheme,
      brightness: brightness ?? this.brightness,
      defaultCheckinMethod: defaultCheckinMethod ?? this.defaultCheckinMethod,
      nickname: nickname ?? this.nickname,
      region: region ?? this.region,
      welfarePartner: welfarePartner ?? this.welfarePartner,
    );
  }
}
