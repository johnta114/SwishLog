import 'package:flutter/material.dart';
import 'screens/stats_entry_screen.dart';

void main() {
  runApp(const SwishLogApp());
}

class SwishLogApp extends StatelessWidget {
  const SwishLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ライトテーマ ＋ 深みのあるオレンジ のカラー設定
    return MaterialApp(
      title: 'SwishLog',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange, // テーマカラー：深いオレンジ
          brightness: Brightness.light,
          surface: const Color(0xFFF8F9FA), // 背景色：薄いグレー
          onSurface: const Color(0xFF333333), // 文字色：目に優しいダークグレー
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 各タブの画面（現在はプレースホルダー）
  final List<Widget> _screens = [
    const StatsEntryScreen(), // モック画面をここに設定
    const PlayersScreenPlaceholder(),
    const StatsScreenPlaceholder(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.sports_basketball_outlined),
            selectedIcon: Icon(Icons.sports_basketball),
            label: '試合',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: '選手',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: '成績',
          ),
        ],
      ),
    );
  }
}

// ==========================================
// プレースホルダー画面（後ほど個別のファイルに切り出します）
// ==========================================

class GamesScreenPlaceholder extends StatelessWidget {
  const GamesScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('試合一覧')),
      body: const Center(
        child: Text('ここに試合の一覧と\n新規試合追加ボタンが並びます', textAlign: TextAlign.center),
      ),
    );
  }
}

class PlayersScreenPlaceholder extends StatelessWidget {
  const PlayersScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('選手管理')),
      body: const Center(
        child: Text('ここに選手一覧が並びます\n（※基本はコートネームで表示）', textAlign: TextAlign.center),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

class StatsScreenPlaceholder extends StatelessWidget {
  const StatsScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('通算成績・分析')),
      body: const Center(
        child: Text('ここにチームや個人の\n通算スタッツやグラフが表示されます', textAlign: TextAlign.center),
      ),
    );
  }
}
