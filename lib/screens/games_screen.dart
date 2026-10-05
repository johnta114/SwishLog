import 'game_analytics_screen.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import 'settings_screen.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'stats_entry_screen.dart';
import '../database/database_helper.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../main.dart';

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
  List<Map<String, dynamic>> _seasons = [];
  List<Map<String, dynamic>> _activeRoster = [];
  bool _isLoading = true;
  bool _isSearching = false;

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


  String? _lastLoadedSeasonId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = Provider.of<AppSettingsProvider>(context);
    if (settings.isLoaded && _lastLoadedSeasonId != settings.activeSeasonId) {
      _lastLoadedSeasonId = settings.activeSeasonId;
      _loadData();
    }
  }

  // SQLiteからデータを読み込む
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    final games = await DatabaseHelper.instance.getAllGames();
    final opponents = await DatabaseHelper.instance.getOpponentTeams();
    final seasons = await DatabaseHelper.instance.getSeasons();
    
    final settings = Provider.of<AppSettingsProvider>(context, listen: false);
    String? activeSeason = settings.activeSeasonId ?? (seasons.isNotEmpty ? seasons.first['id'] : null);

    List<Map<String, dynamic>> roster = [];
    if (activeSeason != null) {
      roster = await DatabaseHelper.instance.getRosterForSeason(activeSeason);
    }


    setState(() {
      _games = games;
      _knownOpponents = opponents;
      _seasons = seasons;
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
                                    Text(
                                      name,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black87,
                                        fontWeight: FontWeight.bold,
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

  void _confirmDeleteGame(String id, String opponentName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除の確認'),
        content: Text('vs $opponentName の試合を削除しますか？\n関連するすべてのスタッツとアクションログも削除されます。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await DatabaseHelper.instance.deleteGame(id);
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('削除する', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      )
    );
  }

  void _showGameModal([Map<String, dynamic>? game]) {
    final isEdit = game != null;
    if (_activeSeasonId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('先に「チーム管理」からシーズンを作成してください')));
      return;
    }

    bool isNewOpponent = false;
    String? selectedOpponentId = isEdit ? game['opponent_team_id']?.toString() : null;
    String? selectedSeasonId = isEdit ? game['season_id']?.toString() : _activeSeasonId;
    final newOpponentCtrl = TextEditingController();
    final prefCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: isEdit ? game['date'] : DateTime.now().toString().split(' ')[0]);
    bool isU12 = isEdit ? (game['is_u12'] == 1) : false;

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
                  Text(isEdit ? '試合の編集' : '新規試合の作成', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      initialSelection: selectedOpponentId,
                      dropdownMenuEntries: _knownOpponents.map((opp) {
                        return DropdownMenuEntry<String>(
                          value: opp['id'].toString(),
                          label: "${opp['name']} (📍 ${opp['prefecture']})",
                        );
                      }).toList(),
                      onSelected: (val) => setModalState(() => selectedOpponentId = val),
                    ),
                  ] else ...[
                    TextField(controller: newOpponentCtrl, decoration: const InputDecoration(label: const Text.rich(TextSpan(children: [TextSpan(text: '対戦相手チーム名 '), TextSpan(text: '*', style: TextStyle(color: Colors.red))])), border: OutlineInputBorder()), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 12),
                    TextField(controller: prefCtrl, decoration: const InputDecoration(labelText: '都道府県 (任意)', border: OutlineInputBorder())),
                  ],
                  
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: '対象シーズン', border: OutlineInputBorder()),
                    value: selectedSeasonId,
                    items: _seasons.map((s) => DropdownMenuItem(value: s['id'].toString(), child: Text(s['name'].toString()))).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedSeasonId = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: dateCtrl, readOnly: true,
                    decoration: InputDecoration(
                      labelText: '試合日', border: const OutlineInputBorder(),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (dateCtrl.text.isNotEmpty) IconButton(icon: const Icon(Icons.clear, size: 20), onPressed: () => setModalState(() => dateCtrl.clear())),
                          const Icon(Icons.calendar_today, size: 20),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ),
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

                      final data = {
                        'season_id': selectedSeasonId,
                        'date': dateCtrl.text,
                        'opponent_team_id': targetOpponentId,
                        'is_u12': isU12 ? 1 : 0,
                      };
                      if (isEdit) {
                        await DatabaseHelper.instance.updateGame(game['id'].toString(), data);
                      } else {
                        data['status'] = 'not_started';
                        data['my_score'] = 0;
                        data['opp_score'] = 0;
                        await DatabaseHelper.instance.insertGame(data);
                      }

                      if (mounted) Navigator.pop(context);
                      await _loadData();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text(isEdit ? '更新する' : '作成する', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            mainScreenKey.currentState?.goToHome();
          },
          child: const Text('SwishLog', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ), 
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;

              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
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
                      ? const Center(child: Text('該当する試合が見つからないか、\nまだ作成されていません。', textAlign: TextAlign.center))
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
                                  onTap: () async {
                                    final status = game['status'] ?? 'completed';
                                    if (status == 'completed') {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => GameAnalyticsScreen(gameId: game['id'].toString(), gameTitle: 'vs ${game['opponent']}')));
                                    } else if (status == 'in_progress') {
                                      final starters = _activeRoster.take(5).toList();
                                      final bench = _activeRoster.skip(5).toList();
                                      await Navigator.push(context, MaterialPageRoute(builder: (context) => StatsEntryScreen(gameId: game['id'].toString(), opponentName: game['opponent'], starters: starters, bench: bench)));
                                      _loadData();
                                    } else {
                                      _showStarterSelectionModal(game);
                                    }
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
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: _isSearching ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                  alignment: Alignment.topCenter,
                  sizeCurve: Curves.easeInOut,
                  secondChild: const SizedBox(width: double.infinity, height: 0),
                  firstChild: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextField(
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
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
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
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _dateSearchCtrl,
                              decoration: InputDecoration(
                                labelText: '試合日 (例: 2026-10)',
                                isDense: true,
                                border: const OutlineInputBorder(),
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
                                      icon: const Icon(Icons.calendar_today, size: 20, color: Colors.black54),
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

