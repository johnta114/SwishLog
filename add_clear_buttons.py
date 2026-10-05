import re

# ================================
# 1. games_screen.dart
# ================================
with open('lib/screens/games_screen.dart', 'r') as f:
    games_content = f.read()

# Replace Opponent TextField
opp_old = """                                  child: TextField(
                                    controller: _oppCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'チーム名',
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (val) => setState(() => _searchOpponent = val),
                                  ),"""
opp_new = """                                  child: TextField(
                                    controller: _oppCtrl,
                                    decoration: InputDecoration(
                                      labelText: 'チーム名',
                                      isDense: true,
                                      border: const OutlineInputBorder(),
                                      suffixIcon: _searchOpponent.isNotEmpty 
                                        ? IconButton(
                                            icon: const Icon(Icons.clear, size: 18),
                                            onPressed: () {
                                              _oppCtrl.clear();
                                              setState(() => _searchOpponent = '');
                                            },
                                          )
                                        : null,
                                    ),
                                    onChanged: (val) => setState(() => _searchOpponent = val),
                                  ),"""
games_content = games_content.replace(opp_old, opp_new)

# Replace Prefecture TextField
pref_old = """                                  child: TextField(
                                    controller: _prefCtrl,
                                    decoration: const InputDecoration(
                                      labelText: '都道府県',
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (val) => setState(() => _searchPrefecture = val),
                                  ),"""
pref_new = """                                  child: TextField(
                                    controller: _prefCtrl,
                                    decoration: InputDecoration(
                                      labelText: '都道府県',
                                      isDense: true,
                                      border: const OutlineInputBorder(),
                                      suffixIcon: _searchPrefecture.isNotEmpty 
                                        ? IconButton(
                                            icon: const Icon(Icons.clear, size: 18),
                                            onPressed: () {
                                              _prefCtrl.clear();
                                              setState(() => _searchPrefecture = '');
                                            },
                                          )
                                        : null,
                                    ),
                                    onChanged: (val) => setState(() => _searchPrefecture = val),
                                  ),"""
games_content = games_content.replace(pref_old, pref_new)

with open('lib/screens/games_screen.dart', 'w') as f:
    f.write(games_content)

# ================================
# 2. opponent_teams_screen.dart
# ================================
with open('lib/screens/opponent_teams_screen.dart', 'r') as f:
    opp_content = f.read()

# Replace Name TextField
opp_name_old = """                          child: TextField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'チーム名',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) => setState(() => _searchName = val),
                          ),"""
opp_name_new = """                          child: TextField(
                            controller: _nameCtrl,
                            decoration: InputDecoration(
                              labelText: 'チーム名',
                              isDense: true,
                              border: const OutlineInputBorder(),
                              suffixIcon: _searchName.isNotEmpty 
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _nameCtrl.clear();
                                      setState(() => _searchName = '');
                                    },
                                  )
                                : null,
                            ),
                            onChanged: (val) => setState(() => _searchName = val),
                          ),"""
opp_content = opp_content.replace(opp_name_old, opp_name_new)

# Replace Prefecture TextField
opp_pref_old = """                          child: TextField(
                            controller: _prefCtrl,
                            decoration: const InputDecoration(
                              labelText: '都道府県',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) => setState(() => _searchPref = val),
                          ),"""
opp_pref_new = """                          child: TextField(
                            controller: _prefCtrl,
                            decoration: InputDecoration(
                              labelText: '都道府県',
                              isDense: true,
                              border: const OutlineInputBorder(),
                              suffixIcon: _searchPref.isNotEmpty 
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _prefCtrl.clear();
                                      setState(() => _searchPref = '');
                                    },
                                  )
                                : null,
                            ),
                            onChanged: (val) => setState(() => _searchPref = val),
                          ),"""
opp_content = opp_content.replace(opp_pref_old, opp_pref_new)

with open('lib/screens/opponent_teams_screen.dart', 'w') as f:
    f.write(opp_content)

