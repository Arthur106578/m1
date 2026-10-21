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

  testWidgets('r 触发 reassemble 保留 State，R 重建 State', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);

    // 相当于热重载 r：Element 树 reassemble，State 与 _counter 保留。
    tester.binding.reassembleApplication();
    await tester.pump();
    expect(find.text('2'), findsOneWidget);

    // 相当于热重启 R：整棵树卸载后重新挂载，initState 再执行一次，计数归零。
    // 注意直接 pumpWidget(const MyApp()) 会因为是同一个 const 实例而不重建，
    // 所以先卸载再挂载，模拟 R 重新跑 main() 的效果。
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
  });
}
