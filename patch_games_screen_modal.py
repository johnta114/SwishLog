import re

with open('lib/screens/games_screen.dart', 'r') as f:
    content = f.read()

# 1. Remove _isSearching from state
content = content.replace("  bool _isSearching = false;\n", "")

# 2. Add _showSearchModal method
modal_code = """  void _showSearchModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('試合の検索', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _oppCtrl,
                          decoration: const InputDecoration(labelText: 'チーム名', border: OutlineInputBorder()),
                          onChanged: (val) => setState(() => _searchOpponent = val),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _prefCtrl,
                          decoration: const InputDecoration(labelText: '都道府県', border: OutlineInputBorder()),
                          onChanged: (val) => setState(() => _searchPrefecture = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _dateSearchCtrl,
                    decoration: InputDecoration(
                      labelText: '試合日 (例: 2026-10)', border: const OutlineInputBorder(),
                      suffixIcon: _dateSearchCtrl.text.isNotEmpty 
                        ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                            _dateSearchCtrl.clear();
                            setState(() => _searchDate = '');
                            setModalState((){});
                          }) 
                        : null,
                    ),
                    onChanged: (val) {
                      setState(() => _searchDate = val);
                      setModalState((){});
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _oppCtrl.clear();
                            _prefCtrl.clear();
                            _dateSearchCtrl.clear();
                            setState(() {
                              _searchOpponent = '';
                              _searchPrefecture = '';
                              _searchDate = '';
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('クリア', style: TextStyle(color: Colors.black87)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('完了', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      }
    );
  }

  @override"""

content = content.replace("  @override\n  Widget build(BuildContext context) {", modal_code + "\n  Widget build(BuildContext context) {")

# 3. Update AppBar actions
appbar_old_regex = r"actions: \[\s*IconButton\(\s*icon: Icon\(_isSearching \? Icons.close : Icons.search\),\s*onPressed: \(\) \{[\s\S]*?\}\s*\),\s*\],"
appbar_new = "actions: [ IconButton(icon: const Icon(Icons.search), onPressed: _showSearchModal), ],"
content = re.sub(appbar_old_regex, appbar_new, content)

# 4. Remove the inline search container block
container_regex = r"if \(_isSearching\) Container\([\s\S]*?const Divider\(height: 1, color: Colors\.deepOrange\),\s*"
content = re.sub(container_regex, "", content)

# Wait, check if there is a Divider
with open('lib/screens/games_screen.dart', 'w') as f:
    f.write(content)

