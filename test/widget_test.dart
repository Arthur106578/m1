import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:profile_card/main.dart';

Future<void> pumpAt(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const ProfileCardApp());
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('profile card shows skeleton sections', (WidgetTester tester) async {
    await tester.pumpWidget(const ProfileCardApp());

    expect(find.text('Arthur'), findsOneWidget);
    expect(find.text('作品'), findsOneWidget);
    expect(find.text('关注'), findsOneWidget);
    expect(find.text('粉丝'), findsOneWidget);
    expect(find.text('Flutter'), findsOneWidget);
  });

  testWidgets('no overflow at common phone sizes', (WidgetTester tester) async {
    for (final size in const [Size(390, 844), Size(360, 640), Size(320, 568)]) {
      await pumpAt(tester, size);
      expect(tester.takeException(), isNull, reason: 'overflow at $size');
    }
  });

  testWidgets('three stat blocks share the row equally', (WidgetTester tester) async {
    await pumpAt(tester, const Size(390, 844));

    final rects = ['128', '2.4k', '86']
        .map((v) => tester.getRect(
            find.ancestor(of: find.text(v), matching: find.byType(Column)).first))
        .toList();

    expect(rects[0].width, rects[1].width);
    expect(rects[1].width, rects[2].width);
    // Expanded 生效时三块首尾相接，铺满整行
    expect(rects[1].left, rects[0].right);
    expect(rects[2].left, rects[1].right);
  });
}
