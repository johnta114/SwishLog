import re

with open('lib/main.dart', 'r') as f:
    content = f.read()

# Add GlobalKey
key_decl = "final GlobalKey<_MainScreenState> mainScreenKey = GlobalKey<_MainScreenState>();\n\nclass MainScreen"
content = content.replace("class MainScreen", key_decl)

# Update MainScreen constructor to use the key
old_main = "class MainScreen extends StatefulWidget {\n  const MainScreen({super.key});"
new_main = "class MainScreen extends StatefulWidget {\n  MainScreen({Key? key}) : super(key: key ?? mainScreenKey);"
content = content.replace(old_main, new_main)

# Add goToHome method
state_decl = "class _MainScreenState extends State<MainScreen> {"
new_state = """class _MainScreenState extends State<MainScreen> {
  void goToHome() {
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
    }
  }"""
content = content.replace(state_decl, new_state)

# Move AnalyticsScreen to index 0, Games to 1, etc.
old_screens = """  final List<Widget> _screens = [
    const GamesScreen(),         // 1. 試合一覧
    const SeasonRosterScreen(),  // 2. チーム・名簿管理
    const OpponentTeamsScreen(), // 3. 対戦相手管理
    const AnalyticsScreen(),     // 4. 分析・振り返り画面
  ];"""
new_screens = """  final List<Widget> _screens = [
    const AnalyticsScreen(),     // 0. ホーム（旧 分析）
    const GamesScreen(),         // 1. 試合一覧
    const SeasonRosterScreen(),  // 2. チーム・名簿管理
    const OpponentTeamsScreen(), // 3. 対戦相手管理
  ];"""
content = content.replace(old_screens, new_screens)

# Update BottomNavigationBar items
old_items = """        items: const [
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
        ],"""
new_items = """        items: const [
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
        ],"""
content = content.replace(old_items, new_items)

with open('lib/main.dart', 'w') as f:
    f.write(content)

