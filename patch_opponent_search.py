import re

with open('lib/screens/opponent_teams_screen.dart', 'r') as f:
    content = f.read()

# Add _isSearching to state
state_old = "  String _searchQuery = '';"
state_new = "  bool _isSearching = false;\n  String _searchQuery = '';"
content = content.replace(state_old, state_new)

# Add actions to AppBar
appbar_old = """      appBar: AppBar(
        title: const Text('SwishLog', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),"""

appbar_new = """      appBar: AppBar(
        title: const Text('SwishLog', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchCtrl.clear();
                }
              });
            },
          ),
        ],
      ),"""
content = content.replace(appbar_old, appbar_new)

# Wrap Container with if (_isSearching)
container_old = """          // 検索バー
          Container(
            color: Colors.deepOrange,"""

container_new = """          // 検索バー
          if (_isSearching) Container(
            color: Colors.deepOrange,"""
content = content.replace(container_old, container_new)

with open('lib/screens/opponent_teams_screen.dart', 'w') as f:
    f.write(content)
