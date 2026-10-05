import re

with open('lib/screens/season_roster_screen.dart', 'r') as f:
    content = f.read()

# Add imports
if "import 'package:provider/provider.dart';" not in content:
    content = "import 'package:provider/provider.dart';\nimport '../providers/app_settings_provider.dart';\nimport 'settings_screen.dart';\n" + content

# Add settings button
appbar_search = r"(actions: \[\s*IconButton\([\s\S]*?onPressed: \(\) \{\s*setState\(\(\) => _isSearching = !_isSearching\);\s*\},\s*\),)"
new_action = r"\1\n          IconButton(\n            icon: const Icon(Icons.settings),\n            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),\n          ),"
content = re.sub(appbar_search, new_action, content)

# Also update the active season logic
# Instead of `final latestSeason = seasons.isNotEmpty ? seasons.first['id'] : null;`
# we should fetch the provider's active season.
old_load_data = """  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final seasons = await _dbHelper.getSeasons();
    final latestSeason = seasons.isNotEmpty ? seasons.first['id'] : null;

    List<Map<String, dynamic>> roster = [];
    if (latestSeason != null) {
      roster = await _dbHelper.getRosterForSeason(latestSeason);
    }
"""

new_load_data = """  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final seasons = await _dbHelper.getSeasons();
    
    // fetch active season from provider without listening
    final settings = Provider.of<AppSettingsProvider>(context, listen: false);
    final latestSeason = settings.activeSeasonId ?? (seasons.isNotEmpty ? seasons.first['id'] : null);

    List<Map<String, dynamic>> roster = [];
    if (latestSeason != null) {
      roster = await _dbHelper.getRosterForSeason(latestSeason);
    }
"""
content = content.replace(old_load_data, new_load_data)

# To make it reactive, we should hook into didChangeDependencies.
# But just adding the listener is enough if they navigate back. Since they PUSH settings screen, when they pop, didChangeDependencies won't run again for SeasonRosterScreen!
# Wait, didChangeDependencies *does* run if the provider notifies listeners!
# So we need didChangeDependencies.
did_change = """
  String? _lastLoadedSeasonId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = Provider.of<AppSettingsProvider>(context);
    if (settings.isLoaded && _lastLoadedSeasonId != settings.activeSeasonId) {
      _lastLoadedSeasonId = settings.activeSeasonId;
      _loadData();
    }
  }

  Future<void> _loadData() async {
"""
content = content.replace("  Future<void> _loadData() async {", did_change)

with open('lib/screens/season_roster_screen.dart', 'w') as f:
    f.write(content)
