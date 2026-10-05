import re

with open('lib/screens/home_screen.dart', 'r') as f:
    content = f.read()

# Add import
if "import '../widgets/player_stats_table.dart';" not in content:
    content = content.replace("import '../database/database_helper.dart';", "import '../database/database_helper.dart';\nimport '../widgets/player_stats_table.dart';")


start_str = """                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            color: Colors.white,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: ["""

start_idx = content.find(start_str)

if start_idx != -1:
    end_marker = "const SizedBox(height: 80),"
    end_idx = content.find(end_marker, start_idx)
    
    if end_idx != -1:
        new_method = """                        PlayerStatsTable(stats: _playerStats),
                        """
        content = content[:start_idx] + new_method + content[end_idx:]

with open('lib/screens/home_screen.dart', 'w') as f:
    f.write(content)

