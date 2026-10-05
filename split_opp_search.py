import re

with open('lib/screens/opponent_teams_screen.dart', 'r') as f:
    content = f.read()

# 1. Update State Variables
old_state = """  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();"""

new_state = """  bool _isSearching = false;
  String _searchName = '';
  String _searchPref = '';
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _prefCtrl = TextEditingController();"""
content = content.replace(old_state, new_state)

# 2. Update Filter Logic
old_filter = """    final filteredOpponents = _opponents.where((opp) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final name = (opp['name'] ?? '').toLowerCase();
      final pref = (opp['prefecture'] ?? '').toLowerCase();
      return name.contains(query) || pref.contains(query);
    }).toList();"""

new_filter = """    final filteredOpponents = _opponents.where((opp) {
      final matchName = _searchName.isEmpty || (opp['name'] ?? '').toLowerCase().contains(_searchName.toLowerCase());
      final matchPref = _searchPref.isEmpty || (opp['prefecture'] ?? '').toLowerCase().contains(_searchPref.toLowerCase());
      return matchName && matchPref;
    }).toList();"""
content = content.replace(old_filter, new_filter)

# 3. Replace the single TextField with the Row of two TextFields
old_textfield_block = r"TextField\(\s*controller: _searchCtrl,[\s\S]*?onChanged: \(val\) => setState\(\(\) => _searchQuery = val\),\s*\)"

new_textfield_block = """Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'チーム名',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) => setState(() => _searchName = val),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _prefCtrl,
                            decoration: const InputDecoration(
                              labelText: '都道府県',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) => setState(() => _searchPref = val),
                          ),
                        ),
                      ],
                    )"""
content = re.sub(old_textfield_block, new_textfield_block, content)

with open('lib/screens/opponent_teams_screen.dart', 'w') as f:
    f.write(content)

