import re

with open('lib/screens/game_analytics_screen.dart', 'r') as f:
    content = f.read()

# Add import
if "import '../widgets/player_stats_table.dart';" not in content:
    content = content.replace("import '../utils/stat_actions.dart';", "import '../utils/stat_actions.dart';\nimport '../widgets/player_stats_table.dart';")

# Find the start of _buildPlayerStatsTab
start_idx = content.find("  Widget _buildPlayerStatsTab() {")
# Find the start of the next method _confirmDeleteStat
end_idx = content.find("  void _confirmDeleteStat(Map<String, dynamic> stat) {")

if start_idx != -1 and end_idx != -1:
    new_method = """  Widget _buildPlayerStatsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('個人スタッツ一覧', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            PlayerStatsTable(stats: _aggregatedPlayerStats),
            const SizedBox(height: 80),
          ],
        ),
      )
    );
  }

"""
    content = content[:start_idx] + new_method + content[end_idx:]

with open('lib/screens/game_analytics_screen.dart', 'w') as f:
    f.write(content)

