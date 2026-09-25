import 'package:flutter/material.dart';
import 'stats_entry_screen.dart';
import 'analytics_screen.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  // 個別検索用のステート
  String _searchOpponent = '';
  String _searchPrefecture = '';
  String _searchDate = '';

  final TextEditingController _oppCtrl = TextEditingController();
  final TextEditingController _prefCtrl = TextEditingController();
  final TextEditingController _dateSearchCtrl = TextEditingController();

  final List<Map<String, dynamic>> _games = [
    {'opponent': '〇〇高校', 'prefecture': '東京都', 'date': '2026-10-01', 'is_u12': false, 'my_score': 68, 'opp_score': 60, 'status': 'completed'},
    {'opponent': '□□クラブ', 'prefecture': '神奈川県', 'date': '2026-10-03', 'is_u12': false, 'my_score': 35, 'opp_score': 32, 'status': 'in_progress'},
    {'opponent': '△△クラブ (練習試合)', 'prefecture': '埼玉県', 'date': '2026-10-05', 'is_u12': true, 'my_score': 0, 'opp_score': 0, 'status': 'not_started'},
  ];

  final List<String> _seasonRoster = [
    'タロウ', 'ジロウ', 'ケン', 'リョウ', 'ショウ', 'シロー', 'ゴロウ', 'ハチロー', 'キュウ', 'ジュウ'
  ];

  // モックデータ：登録済みの対戦相手
  final List<Map<String, String>> _knownOpponents = [
    {'name': '〇〇高校', 'prefecture': '東京都'},
    {'name': '□□クラブ', 'prefecture': '神奈川県'},
    {'name': '△△クラブ (練習試合)', 'prefecture': '埼玉県'},
  ];

  void _showStarterSelectionModal(Map<String, dynamic> game) {
    List<String> selectedStarters = [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('スタメン選択 (5名)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('現在 \${selectedStarters.length} 名選択中', style: TextStyle(color: selectedStarters.length == 5 ? Colors.deepOrange : Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _seasonRoster.map((player) {
                        final isSelected = selectedStarters.contains(player);
                        return FilterChip(
                          label: Text(player), selected: isSelected, selectedColor: Colors.deepOrange.shade100, checkmarkColor: Colors.deepOrange,
                          onSelected: (bool selected) {
                            setModalState(() {
                              if (selected) {
                                if (selectedStarters.length < 5) selectedStarters.add(player);
                              } else {
                                selectedStarters.remove(player);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: selectedStarters.length == 5 ? () {
                        Navigator.pop(context);
                        final bench = _seasonRoster.where((p) => !selectedStarters.contains(p)).toList();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => StatsEntryScreen(opponentName: game['opponent'], starters: selectedStarters, bench: bench)));
                      } : null,
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), backgroundColor: Colors.deepOrange),
                      child: const Text('試合開始（記録へ）', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  void _showAddGameModal() {
    bool isNewOpponent = false;
    String? selectedOpponentName;
    final newOpponentCtrl = TextEditingController();
    final prefCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: DateTime.now().toString().split(' ')[0]);
    bool isU12 = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('新規試合の作成', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // 既存 vs 新規の切り替えトグル
                  Container(
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => isNewOpponent = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(color: !isNewOpponent ? Colors.deepOrange : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                              child: Center(child: Text('過去の対戦相手から選ぶ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: !isNewOpponent ? Colors.white : Colors.black54))),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => isNewOpponent = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(color: isNewOpponent ? Colors.deepOrange : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                              child: Center(child: Text('新しくチームを入力', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isNewOpponent ? Colors.white : Colors.black54))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (!isNewOpponent) ...[
                    // ★ 検索機能付きのDropdownMenuを使用
                    DropdownMenu<String>(
                      width: MediaQuery.of(context).size.width - 48,
                      enableFilter: true, // 入力による絞り込みを有効化
                      requestFocusOnTap: true,
                      label: const Text('チーム名や都道府県を入力して検索'),
                      dropdownMenuEntries: _knownOpponents.map((opp) {
                        return DropdownMenuEntry<String>(
                          value: opp['name']!,
                          label: '${opp['name']} (📍 ${opp['prefecture']})',
                        );
                      }).toList(),
                      onSelected: (val) => setModalState(() => selectedOpponentName = val),
                    ),
                  ] else ...[
                    TextField(controller: newOpponentCtrl, decoration: const InputDecoration(labelText: '対戦相手チーム名 *', border: OutlineInputBorder()), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 12),
                    TextField(controller: prefCtrl, decoration: const InputDecoration(labelText: '都道府県 (任意)', border: OutlineInputBorder())),
                  ],
                  
                  const SizedBox(height: 16),
                  TextField(
                    controller: dateCtrl, readOnly: true,
                    decoration: const InputDecoration(labelText: '試合日', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                      if (picked != null) dateCtrl.text = "\${picked.year}-\${picked.month.toString().padLeft(2, '0')}-\${picked.day.toString().padLeft(2, '0')}";
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(color: Colors.deepOrange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.deepOrange.shade200)),
                    child: CheckboxListTile(
                      title: const Text('U12ルールを適用する', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      value: isU12, activeColor: Colors.deepOrange,
                      onChanged: (bool? value) => setModalState(() => isU12 = value ?? false),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      String targetOpponent = '';
                      String targetPref = '';

                      if (isNewOpponent) {
                        if (newOpponentCtrl.text.isEmpty) return;
                        targetOpponent = newOpponentCtrl.text;
                        targetPref = prefCtrl.text.isEmpty ? '未設定' : prefCtrl.text;
                      } else {
                        if (selectedOpponentName == null) return;
                        targetOpponent = selectedOpponentName!;
                        targetPref = _knownOpponents.firstWhere((o) => o['name'] == targetOpponent)['prefecture'] ?? '未設定';
                      }

                      setState(() {
                        _games.insert(0, {
                          'opponent': targetOpponent, 'prefecture': targetPref, 'date': dateCtrl.text, 'is_u12': isU12, 'my_score': 0, 'opp_score': 0, 'status': 'not_started',
                        });
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('作成する', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  @override
  Widget build(BuildContext context) {
    // 3つの項目すべてでAND検索する
    final filteredGames = _games.where((g) {
      final matchOpp = _searchOpponent.isEmpty || (g['opponent'] ?? '').toLowerCase().contains(_searchOpponent.toLowerCase());
      final matchPref = _searchPrefecture.isEmpty || (g['prefecture'] ?? '').toLowerCase().contains(_searchPrefecture.toLowerCase());
      final matchDate = _searchDate.isEmpty || (g['date'] ?? '').toLowerCase().contains(_searchDate.toLowerCase());
      return matchOpp && matchPref && matchDate;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('SwishLog - 試合一覧', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), centerTitle: false),
      body: Column(
        children: [
          // ★ 個別入力欄に分かれた検索バー
          Container(
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
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today, size: 20, color: Colors.deepOrange),
                      onPressed: () async {
                        final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                        if (picked != null) {
                          final d = "\${picked.year}-\${picked.month.toString().padLeft(2, '0')}-\${picked.day.toString().padLeft(2, '0')}";
                          _dateSearchCtrl.text = d;
                          setState(() => _searchDate = d);
                        }
                      }
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchDate = val),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: filteredGames.isEmpty
              ? const Center(child: Text('該当する試合が見つかりません。', textAlign: TextAlign.center))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80, top: 8),
                  itemCount: filteredGames.length,
                  itemBuilder: (context, index) {
                    final game = filteredGames[index];
                    final String status = game['status'] ?? 'not_started';

                    Color badgeBgColor; Color badgeBorderColor; Color badgeTextColor; String badgeText;
                    if (status == 'completed') {
                      badgeBgColor = Colors.grey.shade200; badgeBorderColor = Colors.grey.shade400; badgeTextColor = Colors.black54; badgeText = '試合終了';
                    } else if (status == 'in_progress') {
                      badgeBgColor = Colors.blue.shade50; badgeBorderColor = Colors.blue.shade300; badgeTextColor = Colors.blue.shade700; badgeText = '記録中';
                    } else {
                      badgeBgColor = Colors.deepOrange.shade50; badgeBorderColor = Colors.deepOrange.shade300; badgeTextColor = Colors.deepOrange; badgeText = '試合前';
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          if (status == 'completed') {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AnalyticsScreen(gameTitle: game['opponent'])));
                          } else if (status == 'in_progress') {
                            final starters = _seasonRoster.take(5).toList();
                            final bench = _seasonRoster.skip(5).toList();
                            Navigator.push(context, MaterialPageRoute(builder: (context) => StatsEntryScreen(opponentName: game['opponent'], starters: starters, bench: bench)));
                          } else {
                            _showStarterSelectionModal(game);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(game['date'], style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 8),
                                      if (game['is_u12']) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)), child: const Text('U12', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))
                                    ],
                                  ),
                                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: badgeBgColor, borderRadius: BorderRadius.circular(6), border: Border.all(color: badgeBorderColor)), child: Text(badgeText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeTextColor)))
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('vs ${game['opponent']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87)),
                              if (game['prefecture'] != null && game['prefecture'].toString().isNotEmpty && game['prefecture'] != '未設定')
                                Padding(padding: const EdgeInsets.only(top: 4), child: Text('📍 ${game['prefecture']}', style: const TextStyle(color: Colors.blueGrey, fontSize: 12, fontWeight: FontWeight.bold))),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('MY TEAM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), const SizedBox(width: 16),
                                  Text('${game['my_score']}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepOrange)), const Padding(padding: EdgeInsets.symmetric(horizontal: 12.0), child: Text('-', style: TextStyle(fontSize: 24, color: Colors.grey))),
                                  Text('${game['opp_score']}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)), const SizedBox(width: 16),
                                  const Text('OPPONENT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGameModal,
        backgroundColor: Colors.deepOrange, icon: const Icon(Icons.add, color: Colors.white), label: const Text('新規試合', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
