import re

with open('lib/screens/analytics_screen.dart', 'r') as f:
    content = f.read()

# 1. Remove from _buildStatsTab
dropdown_code = """                Container(
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
"""

content = content.replace(dropdown_code, "")

# 2. Add to _buildHeaderFilters
filters_end = """                _buildFilterChip("4Q", 4),
              ],
            ),
          ),"""

filters_end_new = """                _buildFilterChip("4Q", 4),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text("選手絞り込み (分布図用):", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _selectedPlayerForChart,
                      isExpanded: true,
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
              ),
            ],
          ),"""

content = content.replace(filters_end, filters_end_new)

with open('lib/screens/analytics_screen.dart', 'w') as f:
    f.write(content)

