import re

with open('lib/screens/opponent_teams_screen.dart', 'r') as f:
    content = f.read()

# 1. Remove _isSearching from state
content = content.replace("  bool _isSearching = false;\n", "")

# 2. Add _showSearchModal
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
                  const Text('対戦相手の検索', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      labelText: 'チーム名・都道府県で検索', border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchCtrl.text.isNotEmpty 
                        ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                            setModalState((){});
                          })
                        : null,
                    ),
                    onChanged: (val) {
                      setState(() => _searchQuery = val);
                      setModalState((){});
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
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

# 3. Update build method
build_start = "    return Scaffold("
build_end = "          // リスト表示"

regex = re.escape(build_start) + r"[\s\S]*?" + re.escape(build_end)

correct_build = """    return Scaffold(
      appBar: AppBar(
        title: const Text('SwishLog', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _showSearchModal),
        ],
      ),
      body: Column(
        children: [
          // リスト表示"""

content = re.sub(regex, correct_build, content)

with open('lib/screens/opponent_teams_screen.dart', 'w') as f:
    f.write(content)

