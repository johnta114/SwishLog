import re

with open('lib/main.dart', 'r') as f:
    content = f.read()

# Fix 1: home: const MainScreen() -> home: MainScreen()
content = content.replace("home: const MainScreen(),", "home: MainScreen(),")

# Fix 2: _MainScreenState -> MainScreenState
content = content.replace("_MainScreenState", "MainScreenState")

with open('lib/main.dart', 'w') as f:
    f.write(content)

