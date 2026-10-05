import re

with open('lib/screens/game_analytics_screen.dart', 'r') as f:
    content = f.read()

old_appbar = """    final appBar = AppBar(
      title: const Text('SwishLog', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      centerTitle: false,
      bottom: TabBar(
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: [
          const Tab(icon: Icon(Icons.pie_chart), text: "シュート分布"),
          const Tab(icon: Icon(Icons.person), text: "個人スタッツ"),
          if (isGameSpecific) const Tab(icon: Icon(Icons.history), text: "試合ログ"),
        ],
      ),
    );"""

new_appbar = """    final appBar = AppBar(
      title: const Text('SwishLog', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(72.0),
        child: Container(
          color: Colors.white,
          child: TabBar(
            indicatorColor: Colors.deepOrange,
            labelColor: Colors.deepOrange,
            unselectedLabelColor: Colors.grey,
            tabs: [
              const Tab(icon: Icon(Icons.pie_chart), text: "シュート分布"),
              const Tab(icon: Icon(Icons.person), text: "個人スタッツ"),
              if (isGameSpecific) const Tab(icon: Icon(Icons.history), text: "試合ログ"),
            ],
          ),
        ),
      ),
    );"""

content = content.replace(old_appbar, new_appbar)

with open('lib/screens/game_analytics_screen.dart', 'w') as f:
    f.write(content)

