import re

with open('lib/screens/games_screen.dart', 'r') as f:
    content = f.read()

# I will find the entire `Widget build(BuildContext context) { ...` to the end of the file
# Since it's the last method in _GamesScreenState.
build_start = r"  @override\n  Widget build\(BuildContext context\) \{"
regex = build_start + r"[\s\S]*?$"

new_build = """  @override
  Widget build(BuildContext context) {
    final filteredGames = _games.where((g) {
      final matchOpp = _searchOpponent.isEmpty || (g['opponent'] ?? '').toLowerCase().contains(_searchOpponent.toLowerCase());
      final matchPref = _searchPrefecture.isEmpty || (g['prefecture'] ?? '').toLowerCase().contains(_searchPrefecture.toLowerCase());
      final matchDate = _searchDate.isEmpty || (g['date'] ?? '').toLowerCase().contains(_searchDate.toLowerCase());
      return matchOpp && matchPref && matchDate;
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
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
        : Stack(
            children: [
              // Base Layer (List)
              Column(
                children: [
                  Expanded(
                    child: filteredGames.isEmpty
                      ? const Center(child: Text('該当する試合が見つからないか、\\nまだ作成されていません。', textAlign: TextAlign.center))
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80, top: 8),
                          itemCount: filteredGames.length,
                          itemBuilder: (context, index) {
                            final game = filteredGames[index];
                            final myScore = game['my_score'] as int? ?? 0;
                            final oppScore = game['opp_score'] as int? ?? 0;
                            final isWin = myScore > oppScore;
                            final isDraw = myScore == oppScore;
                            
                            return Slidable(
                              key: ValueKey(game['id']),
                              endActionPane: ActionPane(
                                motion: const DrawerMotion(),
                                extentRatio: 0.5,
                                children: [
                                  CustomSlidableAction(
                                    onPressed: (context) => _showGameModal(game),
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.blue,
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Container(
                                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                                      child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.edit), SizedBox(height: 4), Text('編集', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))])),
                                    ),
                                  ),
                                  CustomSlidableAction(
                                    onPressed: (context) => _confirmDeleteGame(game['id'].toString(), game['opponent']),
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
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => StatsEntryScreen(gameId: game['id'].toString())));
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade200),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(game['date'], style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                                                if (game['is_u12'] == 1) ...[
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(color: Colors.orange.shade700, borderRadius: BorderRadius.circular(4)),
                                                    child: const Text('U12', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: game['status'] == 'completed' ? Colors.grey.shade100 : Colors.blue.shade50,
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: game['status'] == 'completed' ? Colors.grey.shade300 : Colors.blue.shade200),
                                              ),
                                              child: Text(
                                                game['status'] == 'completed' ? '試合終了' : '記録中',
                                                style: TextStyle(
                                                  color: game['status'] == 'completed' ? Colors.grey.shade700 : Colors.blue.shade700,
                                                  fontSize: 10, fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text("vs ${game['opponent']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on, size: 14, color: Colors.redAccent),
                                            const SizedBox(width: 4),
                                            Text(game['prefecture'] ?? '', style: const TextStyle(color: Colors.blueGrey, fontSize: 12, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Text('MY TEAM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                                            const SizedBox(width: 16),
                                            Text(
                                              myScore.toString(),
                                              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isWin ? Colors.deepOrange : (isDraw ? Colors.black87 : Colors.grey)),
                                            ),
                                            const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('-', style: TextStyle(fontSize: 24, color: Colors.grey))),
                                            Text(
                                              oppScore.toString(),
                                              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: !isWin && !isDraw ? Colors.black87 : Colors.grey),
                                            ),
                                            const SizedBox(width: 16),
                                            const Text('OPPONENT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                  ),
                ],
              ),
              // Overlay Layer (Animated Search Bar)
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
                                    IconButton(
                                      icon: const Icon(Icons.calendar_today, size: 20, color: Colors.deepOrange),
                                      onPressed: () async {
                                        final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                                        if (picked != null) {
                                          final d = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                                          _dateSearchCtrl.text = d;
                                          setState(() => _searchDate = d);
                                        }
                                      }
                                    ),
                                  ],
                                ),
                              ),
                              onChanged: (val) => setState(() => _searchDate = val),
                            ),
                          ],
                        ),
                      ),
                ),
              ),
            ],
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGameModal(),
        backgroundColor: Colors.deepOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('新規試合', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
"""

content = re.sub(regex, new_build, content)

with open('lib/screens/games_screen.dart', 'w') as f:
    f.write(content)
