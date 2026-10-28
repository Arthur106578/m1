import 'package:flutter/material.dart';

void main() {
  runApp(const ProfileCardApp());
}

class ProfileCardApp extends StatelessWidget {
  const ProfileCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '个人名片',
      home: const ProfileCardPage(),
    );
  }
}

class ProfileCardPage extends StatelessWidget {
  const ProfileCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人名片'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 头像区
                  const CircleAvatar(
                    radius: 48,
                    child: Text('A'),
                  ),
                  const SizedBox(height: 16),

                  // 姓名与签名
                  const Text(
                    'Arthur',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '记录学习与生活的每一步',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  // 统计条
                  const Row(
                    children: [
                      _StatBlock(value: '128', label: '作品'),
                      _StatBlock(value: '2.4k', label: '关注'),
                      _StatBlock(value: '86', label: '粉丝'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 标签云
                  const Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Tag(text: 'Flutter'),
                      _Tag(text: 'Dart'),
                      _Tag(text: 'UI 设计'),
                      _Tag(text: '运动'),
                      _Tag(text: '阅读'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 统计条中的单个数字块
class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// 标签云中的单个标签
class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
