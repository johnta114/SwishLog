import 'package:flutter/material.dart';
import 'screens/games_screen.dart'; 
import 'screens/season_roster_screen.dart';
import 'screens/opponent_teams_screen.dart'; // 追加
import 'screens/analytics_screen.dart'; 

void main() {
  runApp(const SwishLogApp());
}

class SwishLogApp extends StatelessWidget {
  const SwishLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SwishLog',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.light,
          surface: const Color(0xFFF8F9FA), 
          onSurface: const Color(0xFF333333), 
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

  // 各タブの画面（4つに拡張）
  final List<Widget> _screens = [
    const GamesScreen(),         // 1. 試合一覧
    const SeasonRosterScreen(),  // 2. チーム・名簿管理
    const OpponentTeamsScreen(), // 3. 対戦相手管理
    const AnalyticsScreen(),     // 4. 分析・振り返り画面
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed, // 4つ以上の場合はfixedにしないと見た目が崩れる
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_basketball),
            label: '試合',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'チーム管理',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield),
            label: '対戦相手',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '分析',
          ),
        ],
      ),
    );
  }
}
