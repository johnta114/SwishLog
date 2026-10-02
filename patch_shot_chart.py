import re

with open('lib/screens/analytics_screen.dart', 'r') as f:
    content = f.read()

# 1. Add state variable
if "String? _selectedPlayerForChart;" not in content:
    content = content.replace(
        "String? _youtubeUrl;",
        "String? _youtubeUrl;\n  String? _selectedPlayerForChart;"
    )

# 2. Modify _buildStatsTab to filter shots
shots_old = "final shots = _rawStats.where((s) => (s['stat_type'] == '2P' || s['stat_type'] == '3P' || s['stat_type'] == 'FG') && s['pos_x'] != null).toList();"
shots_new = """var shots = _rawStats.where((s) => (s['stat_type'] == '2P' || s['stat_type'] == '3P' || s['stat_type'] == 'FG') && s['pos_x'] != null).toList();
    if (_selectedPlayerForChart != null) {
      shots = shots.where((s) => s['player_id'].toString() == _selectedPlayerForChart).toList();
    }"""
content = content.replace(shots_old, shots_new)

# 3. Add Dropdown before the court layout
court_section_old = """                const Text("シュート分布 (FG/3P)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Row("""
court_section_new = """                const Text("シュート分布 (FG/3P)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _selectedPlayerForChart,
                      hint: const Text("全員"),
                      items: [
                        const DropdownMenuItem<String?>(value: null, child: Text("全員")),
                        ..._roster.map((p) => DropdownMenuItem<String?>(
                          value: p['player_id'].toString(),
                          child: Text(p['court_name'] ?? p['last_name'] ?? 'Unknown'),
                        ))
                      ],
                      onChanged: (val) {
                        setState(() => _selectedPlayerForChart = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row("""
content = content.replace(court_section_old, court_section_new)

with open('lib/screens/analytics_screen.dart', 'w') as f:
    f.write(content)
