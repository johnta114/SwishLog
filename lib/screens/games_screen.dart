import 'package:flutter/material.dart';
import 'stats_entry_screen.dart';
import 'analytics_screen.dart';
import '../database/database_helper.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  // DBから取得するデータ群
  List<Map<String, dynamic>> _games = [];
  List<Map<String, dynamic>> _knownOpponents = [];
  String? _activeSeasonId;
  List<Map<String, dynamic>> _activeRoster = [];
  bool _isLoading = true;

  // 検索用
  String _searchOpponent = '';
  String _searchPrefecture = '';
  String _searchDate = '';

  final TextEditingController _oppCtrl = TextEditingController();
  final TextEditingController _prefCtrl = TextEditingController();
  final TextEditingController _dateSearchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // SQLiteからデータを読み込む
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final games = await DatabaseHelper.instance.getAllGames();
    final opponents = await DatabaseHelper.instance.getOpponentTeams();
    final seasons = await DatabaseHelper.instance.getSeasons();
    
    String? activeSeason;
    List<Map<String, dynamic>> roster = [];
    if (seasons.isNotEmpty) {
      activeSeason = seasons.first['id']; // 最新のシーズンをアクティブとする
      roster = await DatabaseHelper.instance.getRosterForSeason(activeSeason!);
    }

    setState(() {
      _games = games;
      _knownOpponents = opponents;
      _activeSeasonId = activeSeason;
      _activeRoster = roster;
      _isLoading = false;
    });
  }

  void _showStarterSelectionModal(Map<String, dynamic> game) {
    List<Map<String, dynamic>> selectedStarters = [];

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
                    Text("現在 ${selectedStarters.length} 名選択中", style: TextStyle(color: selectedStarters.length == 5 ? Colors.deepOrange : Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _activeRoster.isEmpty 
                      ? const Padding(padding: EdgeInsets.all(16), child: Text('このシーズンの登録選手がいません。\nチーム管理から追加してください。', textAlign: TextAlign.center))
                      : Wrap(
                          spacing: 12, runSpacing: 12,
                          children: _activeRoster.map((player) {
                            final isSelected = selectedStarters.any((p) => p['player_id'] == player['player_id']);
                            final name = (player['court_name'] ?? player['last_name']) as String;
                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  if (isSelected) {
                                    selectedStarters.removeWhere((p) => p['player_id'] == player['player_id']);
                                  } else {
                                    if (selectedStarters.length < 5) selectedStarters.add(player);
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.deepOrange : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: isSelected ? Colors.deepOrange : Colors.grey.shade400, width: 2),
                                  boxShadow: isSelected ? [BoxShadow(color: Colors.deepOrange.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))] : [],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isSelected) const Icon(Icons.check_circle, color: Colors.white, size: 18),
                                    if (isSelected) const SizedBox(width: 6),
                                    Text(
                                      name,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black87,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: selectedStarters.length == 5 ? () async {
                        Navigator.pop(context);
                        
                        // ステータスを「記録中」に更新
                        await DatabaseHelper.instance.updateGameStatus(game['id'].toString(), 'in_progress');
                        await _loadData();

                        final bench = _activeRoster.where((p) => !selectedStarters.contains(p)).toList();
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => StatsEntryScreen(gameId: game['id'].toString(), opponentName: game['opponent'], starters: selectedStarters, bench: bench)));
                        _loadData();
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
    if (_activeSeasonId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('先に「チーム管理」からシーズンを作成してください')));
      return;
    }

    bool isNewOpponent = false;
    String? selectedOpponentId;
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
                    DropdownMenu<String>(
                      width: MediaQuery.of(context).size.width - 48,
                      enableFilter: true,
                      requestFocusOnTap: true,
                      label: const Text('チーム名や都道府県を入力して検索'),
                      dropdownMenuEntries: _knownOpponents.map((opp) {
                        return DropdownMenuEntry<String>(
                          value: opp['id'].toString(),
                          label: "${opp['name']} (📍 ${opp['prefecture']})",
                        );
                      }).toList(),
                      onSelected: (val) => setModalState(() => selectedOpponentId = val),
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
                      if (picked != null) setModalState(() => dateCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}");
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
                    onPressed: () async {
                      String targetOpponentId = '';

                      if (isNewOpponent) {
                        if (newOpponentCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('対戦相手のチーム名を入力してください')));
                          return;
                        }
                        // SQLiteに対戦相手を新規登録
                        targetOpponentId = await DatabaseHelper.instance.insertOpponentTeam({
                          'name': newOpponentCtrl.text,
                          'prefecture': prefCtrl.text.isEmpty ? '未設定' : prefCtrl.text,
                          'coach_contact': '',
                          'notes': '',
                        });
                      } else {
                        if (selectedOpponentId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('対戦相手を選択してください')));
                          return;
                        }
                        targetOpponentId = selectedOpponentId!;
                      }

                      // SQLiteに試合を登録
                      await DatabaseHelper.instance.insertGame({
                        'season_id': _activeSeasonId,
                        'date': dateCtrl.text,
                        'opponent_team_id': targetOpponentId,
                        'is_u12': isU12 ? 1 : 0,
                        'status': 'not_started',
                        'my_score': 0,
                        'opp_score': 0,
                      });

                      if (mounted) Navigator.pop(context);
                      await _loadData();
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
    final filteredGames = _games.where((g) {
      final matchOpp = _searchOpponent.isEmpty || (g['opponent'] ?? '').toLowerCase().contains(_searchOpponent.toLowerCase());
      final matchPref = _searchPrefecture.isEmpty || (g['prefecture'] ?? '').toLowerCase().contains(_searchPrefecture.toLowerCase());
      final matchDate = _searchDate.isEmpty || (g['date'] ?? '').toLowerCase().contains(_searchDate.toLowerCase());
      return matchOpp && matchPref && matchDate;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('SwishLog', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), centerTitle: false),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
        : Column(
            children: [
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
                              final d = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
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
                  ? const Center(child: Text('該当する試合が見つからないか、\nまだ作成されていません。', textAlign: TextAlign.center))
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80, top: 8),
                      itemCount: filteredGames.length,
                      itemBuilder: (context, index) {
                        final game = filteredGames[index];
                        final String status = game['status'] ?? 'not_started';
                        final isU12 = (game['is_u12'] == 1);

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
                            onTap: () async {
                              if (status == 'completed') {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => AnalyticsScreen(gameId: game['id'].toString(), gameTitle: game['opponent'])));
                              } else if (status == 'in_progress') {
                                final starters = _activeRoster.take(5).toList();
                                final bench = _activeRoster.skip(5).toList();
                                await Navigator.push(context, MaterialPageRoute(builder: (context) => StatsEntryScreen(gameId: game['id'].toString(), opponentName: game['opponent'], starters: starters, bench: bench)));
                                _loadData();
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
                                          if (isU12) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)), child: const Text('U12', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))
                                        ],
                                      ),
                                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: badgeBgColor, borderRadius: BorderRadius.circular(6), border: Border.all(color: badgeBorderColor)), child: Text(badgeText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeTextColor)))
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text("vs ${game['opponent']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87)),
                                  if (game['prefecture'] != null && game['prefecture'].toString().isNotEmpty && game['prefecture'] != '未設定')
                                    Padding(padding: const EdgeInsets.only(top: 4), child: Text("📍 ${game['prefecture']}", style: const TextStyle(color: Colors.blueGrey, fontSize: 12, fontWeight: FontWeight.bold))),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('MY TEAM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), const SizedBox(width: 16),
                                      Text("${game['my_score']}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepOrange)), const Padding(padding: EdgeInsets.symmetric(horizontal: 12.0), child: Text('-', style: TextStyle(fontSize: 24, color: Colors.grey))),
                                      Text("${game['opp_score']}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)), const SizedBox(width: 16),
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
