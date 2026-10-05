import re

with open('lib/screens/games_screen.dart', 'r') as f:
    content = f.read()

# Add imports
if "import 'package:provider/provider.dart';" not in content:
    content = "import 'package:provider/provider.dart';\nimport '../providers/app_settings_provider.dart';\n" + content

# Add didChangeDependencies and modify _loadData
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

  // SQLiteからデータを読み込む
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    final games = await DatabaseHelper.instance.getAllGames();
    final opponents = await DatabaseHelper.instance.getOpponentTeams();
    final seasons = await DatabaseHelper.instance.getSeasons();
    
    final settings = Provider.of<AppSettingsProvider>(context, listen: false);
    String? activeSeason = settings.activeSeasonId ?? (seasons.isNotEmpty ? seasons.first['id'] : null);

    List<Map<String, dynamic>> roster = [];
    if (activeSeason != null) {
      roster = await DatabaseHelper.instance.getRosterForSeason(activeSeason);
    }
"""

content = re.sub(
    r"  // SQLiteからデータを読み込む\s*Future<void> _loadData\(\) async \{\s*setState\(\(\) => _isLoading = true\);\s*final games = await DatabaseHelper\.instance\.getAllGames\(\);\s*final opponents = await DatabaseHelper\.instance\.getOpponentTeams\(\);\s*final seasons = await DatabaseHelper\.instance\.getSeasons\(\);\s*String\? activeSeason;\s*List<Map<String, dynamic>> roster = \[\];\s*if \(seasons\.isNotEmpty\) \{\s*activeSeason = seasons\.first\['id'\]; // 最新のシーズンをアクティブとする\s*roster = await DatabaseHelper\.instance\.getRosterForSeason\(activeSeason!\);\s*\}",
    did_change,
    content
)

with open('lib/screens/games_screen.dart', 'w') as f:
    f.write(content)

