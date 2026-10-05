import re

with open('lib/screens/home_screen.dart', 'r') as f:
    content = f.read()

# Add import
if "import '../widgets/player_stats_table.dart';" not in content:
    content = content.replace("import '../database/database_helper.dart';", "import '../database/database_helper.dart';\nimport '../widgets/player_stats_table.dart';")

# Find the DataTable section
# We can look for the container holding the DataTable or the Row containing the two DataTables.
start_str = """                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          color: Colors.white,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: ["""
end_str = """                          ),
                        ),
                      ),"""

# Using regex to find the whole Row block
# Actually, the Row contains both DataTables. Let's find exactly the block.
start_idx = content.find(start_str)
end_idx = content.find("                          ),", start_idx)
# Let's find the closing of the Row
end_idx = content.find("                        ],", start_idx)
end_idx = content.find("                      ),", end_idx) + len("                      ),")

if start_idx != -1 and end_idx != -1:
    new_method = "                      PlayerStatsTable(stats: _playerStats),"
    content = content[:start_idx] + new_method + content[end_idx:]

with open('lib/screens/home_screen.dart', 'w') as f:
    f.write(content)

