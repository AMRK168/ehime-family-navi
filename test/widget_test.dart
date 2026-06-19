import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ehime_family_navi/main.dart';

void main() {
  testWidgets('アプリが起動してBottomNavigationBarが表示される', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: EhimeFamilyNaviApp()),
    );

    // BottomNavigationBarのラベルが表示されていることを確認
    expect(find.text('検索'), findsOneWidget);
    expect(find.text('スケジュール'), findsOneWidget);
    expect(find.text('グループ'), findsOneWidget);
    expect(find.text('掲示板'), findsOneWidget);
  });
}
