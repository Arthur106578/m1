// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:counter_deep/main.dart';

void main() {
  testWidgets('默认步长为 2，点击一次计数 +2', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('0'), findsOneWidget);
    expect(find.text('当前步长：+2'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('切换步长为 5 后，点击一次计数 +5', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('步长 2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('步长 5'));
    await tester.pumpAndSettle();

    expect(find.text('当前步长：+5'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('5'), findsOneWidget);
  });
}
