# counter_deep 改造报告

## 步骤二：步长与主题

### 改造前我的预测（先猜，再看方案）

| # | 猜测要改的位置 | 具体猜测 |
| --- | --- | --- |
| 1 | `MyApp.build` 的 `ThemeData` | `seedColor` 从 `Colors.deepPurple` 改为 `Colors.teal` |
| 2 | `_MyHomePageState` 字段 | 新增 `int _step`，`_counter++` 改成 `_counter += _step` |
| 3 | 步长选择 UI | 猜在 `body` 的 `Column` 里加一个 `DropdownButton<int>` |
| 4 | `FloatingActionButton` | 图标可能需要换成 `Icons.add` 之外的样式 |
| 5 | `test/widget_test.dart` | 默认断言 `0 → 1` 会失败，需要改成 `0 → 2` |

### AI 给出的对照方案（实际改动）

| # | 实际改动 | 与预测的差异 |
| --- | --- | --- |
| 1 | `ColorScheme.fromSeed(seedColor: Colors.teal)` | 与预测一致 |
| 2 | `int _step = 2;` + `setState(() => _counter += _step)` | 与预测一致 |
| 3 | 步长选择放在 `AppBar.actions` 的 `PopupMenuButton<int>`（1/2/5），默认 2，按钮上显示 `+2` | **位置不同**：AppBar 而非 body；**控件不同**：弹层菜单而非下拉框。放在 AppBar 不挤占正文，也和"计数器"这一主内容分离得更清楚 |
| 4 | FAB 仍是 `Icon(Icons.add)`，只把 `tooltip` 改成动态的 `增加 $_step` | 图标不需要动，动态 tooltip 更贴合语义 |
| 5 | 测试改为断言 `0 → 2`，并补一个"切到步长 5 后 2 → 7"的用例 | 预测只想到改数字，没想到要覆盖步长切换路径 |

### 差异带来的结论

- 步长属于"页面级配置"，放 AppBar 比放 body 更符合 Material 的层级习惯，正文只留计数结果。
- `PopupMenuButton` 的 `value` 直接复用 `_step` 的类型（`int`），省掉了字符串和数字之间的转换，这是比 `DropdownButton` 更省事的地方。
- 凡是改动默认模板的交互，测试必须同步改，否则 `flutter test` 会红。

## 步骤三：生命周期日志与资源

### 生命周期钩子（每个一行 `debugPrint`）

| 钩子 | 触发时机 | 本工程中的表现 |
| --- | --- | --- |
| `initState` | State 首次插入树，只执行一次 | 启动时打印一次，此时可以安全初始化字段 |
| `didChangeDependencies` | 依赖的 InheritedWidget（Theme / MediaQuery）变化 | 启动时紧随 `initState`，主题切换时再次触发 |
| `build` | 每次需要重建时 | 每次 `setState` 后都打印，`_counter` 与 `_step` 一并输出 |
| `didUpdateWidget` | 父级用新配置重建本 Widget | 本次 `MyHomePage` 是 `const`，正常操作不会触发；日志保留用于观察 |
| `deactivate` | 从树中暂时移除 | 页面被替换/热重载时出现 |
| `reassemble` | 热重载 r 时对现有 Element 树调用 | 不重建 State，`_counter` 保留 |
| `dispose` | State 永久销毁 | 退出页面时出现，此后不能再调用 `setState` |

### r / R 行为对照记录

真实启动日志（`flutter run -d windows`）：

```
[lifecycle] initState：State 首次插入树，_counter=0
[lifecycle] didChangeDependencies：Theme/MediaQuery 等依赖变化
[lifecycle] build：重建，_counter=0，_step=2
```

命令行无法注入按键，因此 r / R 用 widget test 在 `reassembleApplication()` 与卸载/重新挂载上复现，日志如下：

```
# 点击 FAB 一次（+2）
[lifecycle] build：重建，_counter=2，_step=2

# r —— 热重载
[lifecycle] reassemble：热重载 r 触发，State 保留，_counter=2
[lifecycle] build：重建，_counter=2，_step=2

# R —— 热重启
[lifecycle] deactivate：State 暂时从树中移除
[lifecycle] dispose：State 永久销毁，之后禁止 setState
[lifecycle] initState：State 首次插入树，_counter=0
[lifecycle] didChangeDependencies：Theme/MediaQuery 等依赖变化
[lifecycle] build：重建，_counter=0，_step=2
```

| 操作 | 触发路径 | `initState` | `reassemble` | `build` | `dispose` | 计数 |
| --- | --- | --- | --- | --- | --- | --- |
| 首次启动 | 挂载 | 执行 1 次 | 否 | 执行 | 否 | 0 |
| r 热重载 | Element 树 reassemble | **不执行** | 执行 | 执行 | 否 | **保留** |
| R 热重启 | 重跑 main，整树重建 | **执行 1 次** | 否 | 执行 | 执行 | **归零** |

结论：r 只替换代码并重建 Widget，State 与字段活在内存里；R 等于重启进程，State 全部丢弃。所以改 `_counter` 初值要用 R 才能看到效果。

### Theme.of 取用（种子色方案）

`ColorScheme.fromSeed(seedColor: Colors.teal)` 生成整套色板，页面里所有颜色都从 `Theme.of(context).colorScheme` 取，不写死颜色：

| 位置 | 取用方式 | 效果 |
| --- | --- | --- |
| 计数数字 | `colorScheme.primary` | 数字跟随种子色（teal 主色） |
| 步长胶囊背景 | `colorScheme.primaryContainer` | 浅色容器色，仍是同一色板派生 |
| 步长胶囊文字 | `colorScheme.onPrimaryContainer` | 与容器色配套的前景色，保证对比度 |
| 数字/胶囊字体 | `textTheme.displayMedium` / `labelMedium` | Typography 同样来自 Theme |

### 资源图片

- 文件：`assets/images/appbar_bg.jpg`（自定义 teal 渐变波浪横幅）
- 声明：`pubspec.yaml` 的 `flutter.assets` 加入该目录
- 用法：作为 `AppBar.flexibleSpace` 背景，并叠加一层半透明黑色渐变保证白色标题可读
- 验证：`flutter test` 通过（测试环境同样走 asset bundle），`flutter run` 重启后可见

### 点 FAB 之后发生了什么（口头版）

1. `onPressed` 调用 `_incrementCounter()`
2. `setState` 把 `_counter` 改成 `_counter + _step`，并把当前 `State` 标记为 dirty
3. 框架在下一帧调度 `build()`，重建 `Scaffold` 子树
4. Element 树做 diff，只有显示 `$_counter` 的 `Text` 真正更新，其余 Widget 复用
5. 整个过程不重建 `MyApp`，因为它是 `const` 的 `StatelessWidget`，配置没有变化

## 6.2 四项要求对照

| # | 要求 | 证据 |
| --- | --- | --- |
| 1 | Widget 树绘图：完整层级 + 两类 Widget 标注 | `docs/widget_tree.svg`（配色区分 Stateless / Stateful / State）与 `docs/widget_tree.md`（含 Mermaid 与易混点表） |
| 2 | 生命周期日志：钩子顺序 + r/R 行为对照 | 代码中 7 个钩子各一行 `debugPrint`；上表为真实启动日志与 r/R 复现日志；`test/widget_test.dart` 第三个用例可重复执行 |
| 3 | 主题定制：种子色方案 + 至少两处 `Theme.of` | `ColorScheme.fromSeed(seedColor: Colors.teal)`；数字取 `colorScheme.primary`，胶囊取 `primaryContainer` / `onPrimaryContainer`，字体取 `textTheme` |
| 4 | 资源替换：新增图片资源并显示成功 | `assets/images/appbar_bg.jpg` 已在 `pubspec.yaml` 声明，作为 `AppBar.flexibleSpace` 显示；`flutter build web` 打包出该资源，浏览器实测可见 |
