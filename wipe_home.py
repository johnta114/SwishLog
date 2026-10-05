import os

# 1. Create home_screen.dart
home_content = """import 'package:flutter/material.dart';
import '../main.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            mainScreenKey.currentState?.goToHome();
          },
          child: const Text('SwishLog', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        centerTitle: false,
      ),
      body: const SizedBox.shrink(),
    );
  }
}
"""
with open('lib/screens/home_screen.dart', 'w') as f:
    f.write(home_content)

# 2. Update main.dart
with open('lib/main.dart', 'r') as f:
    main_content = f.read()

main_content = main_content.replace("import 'screens/analytics_screen.dart';", "import 'screens/home_screen.dart';")
main_content = main_content.replace("const AnalyticsScreen(),", "const HomeScreen(),")

with open('lib/main.dart', 'w') as f:
    f.write(main_content)

# 3. Clean up games_screen.dart
with open('lib/screens/games_screen.dart', 'r') as f:
    games_content = f.read()

games_content = games_content.replace("import 'analytics_screen.dart';\n", "")

with open('lib/screens/games_screen.dart', 'w') as f:
    f.write(games_content)

# 4. Remove analytics_screen.dart
if os.path.exists('lib/screens/analytics_screen.dart'):
    os.remove('lib/screens/analytics_screen.dart')

