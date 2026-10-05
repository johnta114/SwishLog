import 'package:provider/provider.dart';
import 'providers/app_settings_provider.dart';
import 'package:flutter/material.dart';
import 'screens/games_screen.dart'; 
import 'screens/season_roster_screen.dart';
import 'screens/opponent_teams_screen.dart'; // 追加
import 'screens/home_screen.dart'; 

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
      ],
      child: const SwishLogApp(),
    ),
  );
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
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: MainScreen(),
    );
  }
}

final GlobalKey<MainScreenState> mainScreenKey = GlobalKey<MainScreenState>();

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key ?? mainScreenKey);

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  void goToHome() {
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
    }
  }
  int _currentIndex = 0;

  // 各タブの画面（4つに拡張）
  final List<Widget> _screens = [
    const HomeScreen(),     // 0. ホーム（旧 分析）
    const GamesScreen(),         // 1. 試合一覧
    const SeasonRosterScreen(),  // 2. チーム・名簿管理
    const OpponentTeamsScreen(), // 3. 対戦相手管理
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
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
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
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
        ],
      ),
      ),
    );
  }
}
