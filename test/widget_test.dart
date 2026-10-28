import 'package:flutter_test/flutter_test.dart';

import 'package:profile_card/main.dart';

void main() {
  testWidgets('profile card shows skeleton sections', (WidgetTester tester) async {
    await tester.pumpWidget(const ProfileCardApp());

    expect(find.text('Arthur'), findsOneWidget);
    expect(find.text('作品'), findsOneWidget);
    expect(find.text('关注'), findsOneWidget);
    expect(find.text('粉丝'), findsOneWidget);
    expect(find.text('Flutter'), findsOneWidget);
  });
}
