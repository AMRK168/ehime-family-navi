/// 家族メンバー
class FamilyMember {
  final String name;
  final int age;
  final String role; // parent, child, partner

  const FamilyMember({
    required this.name,
    required this.age,
    required this.role,
  });
}

/// 家族プロフィール
/// 家族単位でデータを管理し、カテゴリの好みを保持する。
class FamilyProfile {
  final String familyId;
  final List<FamilyMember> members;
  final List<String> preferredCategories;

  const FamilyProfile({
    required this.familyId,
    required this.members,
    required this.preferredCategories,
  });

  FamilyProfile copyWith({
    String? familyId,
    List<FamilyMember>? members,
    List<String>? preferredCategories,
  }) {
    return FamilyProfile(
      familyId: familyId ?? this.familyId,
      members: members ?? this.members,
      preferredCategories: preferredCategories ?? this.preferredCategories,
    );
  }
}
