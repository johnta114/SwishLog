import re

with open('lib/screens/home_screen.dart', 'r') as f:
    content = f.read()

# Add imports
if "import 'package:provider/provider.dart';" not in content:
    content = "import 'package:provider/provider.dart';\nimport '../providers/app_settings_provider.dart';\nimport 'settings_screen.dart';\n" + content

# Add didChangeDependencies
did_change = """
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = Provider.of<AppSettingsProvider>(context);
    if (settings.isLoaded) {
      if (_activeSeason == null || _activeSeason!['id'] != settings.activeSeasonId) {
        _loadData(settings.activeSeasonId);
      }
    }
  }

  Future<void> _loadData([String? seasonId]) async {
"""
content = re.sub(r"  Future<void> _loadData\(\) async \{", did_change, content)

# Remove the hardcoded active season fetching
old_active_fetch = """    final seasons = await DatabaseHelper.instance.getSeasons();
    if (seasons.isEmpty) {
      if (mounted) {
        setState(() {
          _activeSeason = null;
          _isLoading = false;
        });
      }
      return;
    }

    final activeSeason = seasons.first;"""

new_active_fetch = """    if (seasonId == null) {
      if (mounted) setState(() { _isLoading = false; _activeSeason = null; });
      return;
    }
    final seasons = await DatabaseHelper.instance.getSeasons();
    final activeSeason = seasons.firstWhere((s) => s['id'] == seasonId, orElse: () => <String, dynamic>{});
    if (activeSeason.isEmpty) {
      if (mounted) setState(() { _isLoading = false; _activeSeason = null; });
      return;
    }"""
content = content.replace(old_active_fetch, new_active_fetch)

# Add settings button
old_appbar = """      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            mainScreenKey.currentState?.goToHome();
          },
          child: const Text('SwishLog', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        centerTitle: false,
      ),"""

new_appbar = """      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            mainScreenKey.currentState?.goToHome();
          },
          child: const Text('SwishLog', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),"""
content = content.replace(old_appbar, new_appbar)

with open('lib/screens/home_screen.dart', 'w') as f:
    f.write(content)
