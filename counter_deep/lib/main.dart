import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  /// 每次点击 FAB 的增量，可选 1 / 2 / 5，默认 2。
  int _step = 2;

  @override
  void initState() {
    super.initState();
    debugPrint('[lifecycle] initState：State 首次插入树，_counter=$_counter');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('[lifecycle] didChangeDependencies：Theme/MediaQuery 等依赖变化');
  }

  @override
  void didUpdateWidget(covariant MyHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint(
      '[lifecycle] didUpdateWidget：title "${oldWidget.title}" → "${widget.title}"',
    );
  }

  @override
  void deactivate() {
    debugPrint('[lifecycle] deactivate：State 暂时从树中移除');
    super.deactivate();
  }

  @override
  void reassemble() {
    // 热重载（r）时框架会对现有 Element 树调用 reassemble，State 不重建。
    super.reassemble();
    debugPrint('[lifecycle] reassemble：热重载 r 触发，State 保留，_counter=$_counter');
  }

  @override
  void dispose() {
    debugPrint('[lifecycle] dispose：State 永久销毁，之后禁止 setState');
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      // 把当前步长加进去；setState 会标记本 State 为 dirty，下一帧重跑 build。
      _counter += _step;
    });
  }

  void _changeStep(int step) {
    setState(() {
      _step = step;
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[lifecycle] build：重建，_counter=$_counter，_step=$_step');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        flexibleSpace: Stack(
          fit: StackFit.expand,
          children: [
            // 自定义图片作为 AppBar 背景。
            Image.asset('assets/images/appbar_bg.jpg', fit: BoxFit.cover),
            // 从透明到半黑的渐变，保证白色标题在浅色图片上依然清晰。
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
          ],
        ),
        title: Text(widget.title),
        actions: [
          PopupMenuButton<int>(
            tooltip: '选择步长',
            initialValue: _step,
            onSelected: _changeStep,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 1, child: Text('步长 1')),
              PopupMenuItem(value: 2, child: Text('步长 2')),
              PopupMenuItem(value: 5, child: Text('步长 5')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text('步长 $_step'),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '当前步长：+$_step',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: '增加 $_step',
        child: const Icon(Icons.add),
      ),
    );
  }
}
