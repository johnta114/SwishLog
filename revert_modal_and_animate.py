import re

# ================================
# 1. games_screen.dart
# ================================
with open('lib/screens/games_screen.dart', 'r') as f:
    games_content = f.read()

# Restore _isSearching state
games_content = games_content.replace("  bool _isLoading = true;\n", "  bool _isLoading = true;\n  bool _isSearching = false;\n")

# Remove _showSearchModal function
modal_start = "  void _showSearchModal() {"
modal_end = "  @override\n  Widget build(BuildContext context) {"
games_content = re.sub(re.escape(modal_start) + r"[\s\S]*?" + r"(?=\s*@override\s+Widget build\(BuildContext context\) \{)", "", games_content)

# Update AppBar toggle
appbar_old = "actions: [ IconButton(icon: const Icon(Icons.search), onPressed: _showSearchModal), ],"
appbar_new = """actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchOpponent = '';
                  _searchPrefecture = '';
                  _searchDate = '';
                  _oppCtrl.clear();
                  _prefCtrl.clear();
                  _dateSearchCtrl.clear();
                }
              });
            },
          ),
        ],"""
games_content = games_content.replace(appbar_old, appbar_new)

# Insert AnimatedSize below AppBar
build_start = r"body: _isLoading\s*\?\s*const Center\(child: CircularProgressIndicator\(color: Colors\.deepOrange\)\)\s*:\s*Column\(\s*children: \[\s*Expanded\("
build_new = """body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
        : Column(
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: !_isSearching 
                  ? const SizedBox(width: double.infinity, height: 0)
                  : Container(
                      color: Colors.deepOrange,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  controller: _oppCtrl,
                                  decoration: InputDecoration(
                                    hintText: 'チーム名', hintStyle: const TextStyle(color: Colors.black54, fontSize: 13),
                                    isDense: true, filled: true, fillColor: Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                  ),
                                  onChanged: (val) => setState(() => _searchOpponent = val),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: _prefCtrl,
                                  decoration: InputDecoration(
                                    hintText: '都道府県', hintStyle: const TextStyle(color: Colors.black54, fontSize: 13),
                                    isDense: true, filled: true, fillColor: Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                  ),
                                  onChanged: (val) => setState(() => _searchPrefecture = val),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _dateSearchCtrl,
                            decoration: InputDecoration(
                              hintText: '試合日 (例: 2026-10)', hintStyle: const TextStyle(color: Colors.black54, fontSize: 13),
                              isDense: true, filled: true, fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_dateSearchCtrl.text.isNotEmpty) IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    onPressed: () {
                                      _dateSearchCtrl.clear();
                                      setState(() => _searchDate = '');
                                    }
                                  ),
                                  const Icon(Icons.calendar_today, size: 20, color: Colors.black54),
                                  const SizedBox(width: 12),
                                ]
                              ),
                            ),
                            onChanged: (val) => setState(() => _searchDate = val),
                          ),
                        ],
                      ),
                    ),
              ),
              Expanded("""
games_content = re.sub(build_start, build_new, games_content)

with open('lib/screens/games_screen.dart', 'w') as f:
    f.write(games_content)

# ================================
# 2. opponent_teams_screen.dart
# ================================
with open('lib/screens/opponent_teams_screen.dart', 'r') as f:
    opp_content = f.read()

# Restore _isSearching state
opp_content = opp_content.replace("  String _searchQuery = '';\n", "  bool _isSearching = false;\n  String _searchQuery = '';\n")

# Remove _showSearchModal function
opp_content = re.sub(re.escape(modal_start) + r"[\s\S]*?" + r"(?=\s*@override\s+Widget build\(BuildContext context\) \{)", "", opp_content)

# Update AppBar toggle
opp_appbar_old = """actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _showSearchModal),
        ],"""
opp_appbar_new = """actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchCtrl.clear();
                }
              });
            },
          ),
        ],"""
opp_content = opp_content.replace(opp_appbar_old, opp_appbar_new)

# Insert AnimatedSize below AppBar
opp_build_start = r"body: Column\(\s*children: \[\s*// リスト表示"
opp_build_new = """body: Column(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: !_isSearching 
              ? const SizedBox(width: double.infinity, height: 0)
              : Container(
                  color: Colors.deepOrange,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'チーム名・都道府県で検索', hintStyle: const TextStyle(color: Colors.black54), prefixIcon: const Icon(Icons.search, color: Colors.black54),
                      suffixIcon: _searchQuery.isNotEmpty 
                        ? IconButton(icon: const Icon(Icons.clear, color: Colors.black54), onPressed: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); })
                        : null,
                      filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(vertical: 0), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
          ),
          // リスト表示"""
opp_content = re.sub(opp_build_start, opp_build_new, opp_content)

with open('lib/screens/opponent_teams_screen.dart', 'w') as f:
    f.write(opp_content)

