import re

with open('lib/screens/games_screen.dart', 'r') as f:
    content = f.read()

# Add _isSearching to state
state_old = "  bool _isLoading = true;"
state_new = "  bool _isLoading = true;\n  bool _isSearching = false;"
content = content.replace(state_old, state_new)

# Add actions to AppBar
appbar_old = "appBar: AppBar(title: const Text('SwishLog', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), centerTitle: false),"
appbar_new = """appBar: AppBar(
        title: const Text('SwishLog', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), 
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchOpponent = '';
                  _searchPrefecture = '';
                  _searchDate = '';
                  _oppCtrl.clear();
                  _prefCtrl.clear();
                  _dateSearchCtrl.clear();
                }
              });
            },
          ),
        ],
      ),"""
content = content.replace(appbar_old, appbar_new)

# Wrap Container with if (_isSearching)
# The container starts at: Container(\n                color: Colors.deepOrange, 
container_regex = r'(Container\(\s*color: Colors\.deepOrange,\s*padding: const EdgeInsets\.fromLTRB\(16, 0, 16, 12\),)'
content = re.sub(container_regex, r'if (_isSearching) \1', content)

with open('lib/screens/games_screen.dart', 'w') as f:
    f.write(content)
