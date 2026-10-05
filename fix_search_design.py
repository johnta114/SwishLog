import re

# ================================
# 1. games_screen.dart
# ================================
with open('lib/screens/games_screen.dart', 'r') as f:
    games_content = f.read()

# Remove the resetting of search conditions when closing
reset_logic = """                if (!_isSearching) {
                  _searchOpponent = '';
                  _searchPrefecture = '';
                  _searchDate = '';
                  _oppCtrl.clear();
                  _prefCtrl.clear();
                  _dateSearchCtrl.clear();
                }"""
games_content = games_content.replace(reset_logic, "")

# Update TextField decorations
# 1. Opponent Team field
old_opp_dec = """decoration: InputDecoration(
                                      hintText: 'チーム名', hintStyle: const TextStyle(color: Colors.black54, fontSize: 13),
                                      isDense: true, filled: true, fillColor: Colors.grey.shade100,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                    ),"""
new_opp_dec = """decoration: const InputDecoration(
                                      labelText: 'チーム名',
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                    ),"""
games_content = games_content.replace(old_opp_dec, new_opp_dec)

# 2. Prefecture field
old_pref_dec = """decoration: InputDecoration(
                                      hintText: '都道府県', hintStyle: const TextStyle(color: Colors.black54, fontSize: 13),
                                      isDense: true, filled: true, fillColor: Colors.grey.shade100,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                    ),"""
new_pref_dec = """decoration: const InputDecoration(
                                      labelText: '都道府県',
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                    ),"""
games_content = games_content.replace(old_pref_dec, new_pref_dec)

# 3. Date field
# The Date field has a complex suffixIcon, so we need to be careful.
# Let's find it with regex.
date_dec_regex = r"decoration: InputDecoration\(\s*hintText: '試合日 \(例: 2026-10\)', hintStyle: const TextStyle\(color: Colors\.black54, fontSize: 13\),\s*isDense: true, filled: true, fillColor: Colors\.grey\.shade100,\s*border: OutlineInputBorder\(borderRadius: BorderRadius\.circular\(8\), borderSide: BorderSide\.none\),\s*(suffixIcon: Row\([\s\S]*?\]\n\s*\),\s*\),)"
new_date_dec = r"decoration: InputDecoration(\n                                labelText: '試合日 (例: 2026-10)',\n                                isDense: true,\n                                border: const OutlineInputBorder(),\n                                \1"
games_content = re.sub(date_dec_regex, new_date_dec, games_content)

# Add spacing between fields to match modal if they look cramped?
# There is currently `const SizedBox(height: 8)` between row and date field. Modal has `SizedBox(height: 12)`.
# Let's change `height: 8` to `height: 12` inside the search bar.
games_content = games_content.replace("const SizedBox(height: 8),\n                            TextField(\n                              controller: _dateSearchCtrl,", "const SizedBox(height: 12),\n                            TextField(\n                              controller: _dateSearchCtrl,")

with open('lib/screens/games_screen.dart', 'w') as f:
    f.write(games_content)

# ================================
# 2. opponent_teams_screen.dart
# ================================
with open('lib/screens/opponent_teams_screen.dart', 'r') as f:
    opp_content = f.read()

# Remove the resetting of search conditions when closing
opp_reset_logic = """                if (!_isSearching) {
                  _searchQuery = '';
                  _searchCtrl.clear();
                }"""
opp_content = opp_content.replace(opp_reset_logic, "")

# Update TextField decoration
# Let's use regex to replace the decoration block
opp_dec_regex = r"decoration: InputDecoration\(\s*hintText: 'チーム名・都道府県で検索', hintStyle: const TextStyle\(color: Colors\.black54\), prefixIcon: const Icon\(Icons\.search, color: Colors\.black54\),\s*(suffixIcon: _searchQuery\.isNotEmpty[\s\S]*?null,)\s*filled: true, fillColor: Colors\.grey\.shade100, contentPadding: const EdgeInsets\.symmetric\(vertical: 0\), border: OutlineInputBorder\(borderRadius: BorderRadius\.circular\(8\), borderSide: BorderSide\.none\),\s*\),"
opp_new_dec = r"decoration: InputDecoration(\n                        labelText: 'チーム名・都道府県で検索',\n                        prefixIcon: const Icon(Icons.search),\n                        \1\n                        border: const OutlineInputBorder(),\n                      ),"

opp_content = re.sub(opp_dec_regex, opp_new_dec, opp_content)

# Increase padding inside the animated container so the floating labels don't get cut off at the top
# Currently: padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
# Change to: padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
opp_content = opp_content.replace("padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),", "padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),")

with open('lib/screens/opponent_teams_screen.dart', 'w') as f:
    f.write(opp_content)

