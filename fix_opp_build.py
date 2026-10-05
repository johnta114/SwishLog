import re

with open('lib/screens/opponent_teams_screen.dart', 'r') as f:
    content = f.read()

# Replace the entire build method
build_start = r"  @override\n  Widget build\(BuildContext context\) \{"
regex = build_start + r"[\s\S]*?$"

new_build = """  @override
  Widget build(BuildContext context) {
    final filteredOpponents = _opponents.where((opp) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final name = (opp['name'] ?? '').toLowerCase();
      final pref = (opp['prefecture'] ?? '').toLowerCase();
      return name.contains(query) || pref.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SwishLog', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
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
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
                    : filteredOpponents.isEmpty
                        ? const Center(child: Text('対戦相手が登録されていません。\\n右下のボタンから追加してください。', textAlign: TextAlign.center))
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80, top: 8),
                            itemCount: filteredOpponents.length,
                            itemBuilder: (context, index) {
                              final opp = filteredOpponents[index];
                              return Slidable(
                                key: ValueKey(opp['id']),
                                endActionPane: ActionPane(
                                  motion: const DrawerMotion(),
                                  extentRatio: 0.5,
                                  children: [
                                    CustomSlidableAction(
                                      onPressed: (context) => _showOpponentModal(opp),
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.blue,
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Container(
                                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                                        child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.edit), SizedBox(height: 4), Text('編集', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))])),
                                      ),
                                    ),
                                    CustomSlidableAction(
                                      onPressed: (context) => _confirmDelete(opp['id'].toString(), opp['name']),
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.red,
                                      padding: const EdgeInsets.only(left: 8, right: 16),
                                      child: Container(
                                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                                        child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.delete), SizedBox(height: 4), Text('削除', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))])),
                                      ),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade200),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.blueGrey.shade100,
                                          child: const Icon(Icons.shield, color: Colors.blueGrey),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(opp['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(Icons.location_on, size: 14, color: Colors.redAccent),
                                                  const SizedBox(width: 4),
                                                  Text(opp['prefecture'] ?? '未設定', style: const TextStyle(color: Colors.blueGrey, fontSize: 12, fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: !_isSearching 
                ? const SizedBox(width: double.infinity, height: 0)
                : Container(
                    decoration: const BoxDecoration(
                      color: Colors.deepOrange,
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
                    ),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showOpponentModal(),
        backgroundColor: Colors.deepOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('チーム追加', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
"""

content = re.sub(regex, new_build, content)

with open('lib/screens/opponent_teams_screen.dart', 'w') as f:
    f.write(content)
