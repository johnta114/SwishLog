import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SeasonRosterScreen extends StatefulWidget {
  const SeasonRosterScreen({super.key});

  @override
  State<SeasonRosterScreen> createState() => _SeasonRosterScreenState();
}

class _SeasonRosterScreenState extends State<SeasonRosterScreen> {
  // モックデータ：シーズン一覧
  final List<String> _seasons = ['2025年度', '2026年度'];
  String _selectedSeason = '2026年度';

  // モックデータ：すべての登録済み選手（マスターデータ）
  final List<Map<String, String>> _allPlayers = [
    {'court_name': 'タロウ', 'last_name': '山田', 'first_name': '太郎', 'birth': '2010-04-01'},
    {'court_name': 'ジロウ', 'last_name': '佐藤', 'first_name': '次郎', 'birth': '2011-08-15'},
    {'court_name': 'ケン', 'last_name': '鈴木', 'first_name': '健太', 'birth': '2010-12-05'},
    {'court_name': 'リョウ', 'last_name': '高橋', 'first_name': '涼', 'birth': '2012-01-20'},
    {'court_name': 'ショウ', 'last_name': '田中', 'first_name': '翔', 'birth': '2011-11-11'},
  ];

  // モックデータ：シーズンごとのロスター（名簿と背番号・ポジション）
  final Map<String, List<Map<String, String>>> _rosters = {
    '2025年度': [
      {'court_name': 'タロウ', 'jersey_number': '15', 'position': 'G'},
      {'court_name': 'ジロウ', 'jersey_number': '16', 'position': 'F'},
      {'court_name': 'ケン', 'jersey_number': '17', 'position': 'F'},
    ],
    '2026年度': [
      {'court_name': 'タロウ', 'jersey_number': '4', 'position': 'PG (キャプテン)'},
      {'court_name': 'ジロウ', 'jersey_number': '5', 'position': 'SG'},
      {'court_name': 'ケン', 'jersey_number': '6', 'position': 'SF'},
      {'court_name': 'リョウ', 'jersey_number': '7', 'position': 'PF'},
      {'court_name': 'ショウ', 'jersey_number': '8', 'position': 'C'},
    ],
  };

  // 1. シーズンの削除機能
  void _confirmDeleteSeason() {
    if (_seasons.isEmpty) return;
    final targetSeason = _selectedSeason;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('シーズンの削除', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('「$targetSeason」を削除しますか？\n\n※このシーズンに登録されている名簿データもすべて消去されます。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _seasons.remove(targetSeason);
                _rosters.remove(targetSeason);
                if (_seasons.isNotEmpty) {
                  _selectedSeason = _seasons.last;
                } else {
                  _selectedSeason = '';
                }
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('削除する', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      )
    );
  }

  // 2. 選手の削除機能（名簿から外す vs 完全に消去する）
  void _confirmDeletePlayer(String courtName, int rosterIndex) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('「$courtName」の削除', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              // オプションA: 今のシーズンから外すだけ
              ListTile(
                leading: const Icon(Icons.person_remove, size: 32, color: Colors.blueGrey),
                title: Text('$_selectedSeason の名簿から外す', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('今シーズンの名簿からは消えますが、過去の記録やマスターデータは残ります。'),
                onTap: () {
                  setState(() {
                    _rosters[_selectedSeason]!.removeAt(rosterIndex);
                  });
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              
              // オプションB: 完全消去
              ListTile(
                leading: const Icon(Icons.delete_forever, size: 32, color: Colors.red),
                title: const Text('選手データを完全に削除', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                subtitle: const Text('すべてのシーズンの名簿と、マスターデータから完全に消去します。'),
                onTap: () {
                  setState(() {
                    // 全シーズンの名簿から削除
                    for (var season in _rosters.keys) {
                      _rosters[season]!.removeWhere((p) => p['court_name'] == courtName);
                    }
                    // マスターデータから削除
                    _allPlayers.removeWhere((p) => p['court_name'] == courtName);
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      )
    );
  }

  // 新規シーズン追加 ＆ 引き継ぎモーダル
  void _showAddSeasonDialog() {
    final seasonCtrl = TextEditingController();
    String? copyFromSeason = _seasons.isNotEmpty ? _seasons.last : null;
    
    List<Map<String, String>> availableToCopy = [];
    List<String> selectedToCopy = [];

    void updateCopyList(String? season) {
      if (season != null && _rosters.containsKey(season)) {
        availableToCopy = List.from(_rosters[season]!);
        selectedToCopy = availableToCopy.map((p) => p['court_name']!).toList();
      } else {
        availableToCopy = [];
        selectedToCopy = [];
      }
    }
    updateCopyList(copyFromSeason);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return FractionallySizedBox(
              heightFactor: 0.85, 
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
                child: Column(
                  children: [
                    const Text('新しいシーズンを作成', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(controller: seasonCtrl, decoration: const InputDecoration(labelText: '新シーズン名 (例: 2027年度)', border: OutlineInputBorder())),
                    const SizedBox(height: 24),
                    const Align(alignment: Alignment.centerLeft, child: Text('過去のシーズンの名簿を引き継ぐ', style: TextStyle(fontWeight: FontWeight.bold))),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                      value: copyFromSeason,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('引き継がない（空から作成）')),
                        ..._seasons.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                      ],
                      onChanged: (val) => setModalState(() { copyFromSeason = val; updateCopyList(val); }),
                    ),
                    const SizedBox(height: 16),
                    if (availableToCopy.isNotEmpty) ...[
                      Align(alignment: Alignment.centerLeft, child: Text('引き継ぐ選手を選択 (${selectedToCopy.length}名):', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange))),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                          child: ListView.builder(
                            itemCount: availableToCopy.length,
                            itemBuilder: (context, index) {
                              final p = availableToCopy[index];
                              return CheckboxListTile(
                                title: Text(p['court_name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('背番号: ${p['jersey_number']} / ${p['position']}'),
                                activeColor: Colors.deepOrange,
                                value: selectedToCopy.contains(p['court_name']),
                                onChanged: (val) => setModalState(() {
                                  if (val == true) selectedToCopy.add(p['court_name']!);
                                  else selectedToCopy.remove(p['court_name']);
                                }),
                              );
                            },
                          ),
                        ),
                      ),
                    ] else ...[
                      const Expanded(child: Center(child: Text('引き継ぐ選手がいません'))),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (seasonCtrl.text.isNotEmpty) {
                          setState(() {
                            _seasons.add(seasonCtrl.text);
                            final newRoster = availableToCopy.where((p) => selectedToCopy.contains(p['court_name'])).toList();
                            _rosters[seasonCtrl.text] = newRoster;
                            _selectedSeason = seasonCtrl.text;
                          });
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange, minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('シーズンを作成', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  // 名簿追加モーダル（既存から選ぶ or 新規登録）
  void _showAddToRosterModal() {
    if (_selectedSeason.isEmpty) return; // シーズン未選択時は動作させない

    bool isNewPlayer = false; 
    String? selectedPlayer;
    final lastCtrl = TextEditingController();
    final firstCtrl = TextEditingController();
    final courtCtrl = TextEditingController();
    final birthCtrl = TextEditingController();
    final jerseyCtrl = TextEditingController();
    final positionCtrl = TextEditingController();

    final currentRoster = _rosters[_selectedSeason] ?? [];
    final availablePlayers = _allPlayers.where((p) => !currentRoster.any((r) => r['court_name'] == p['court_name'])).toList();

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
                  Text('$_selectedSeason の名簿に追加', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  Container(
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => isNewPlayer = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(color: !isNewPlayer ? Colors.deepOrange : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                              child: Center(child: Text('既存選手から選ぶ', style: TextStyle(fontWeight: FontWeight.bold, color: !isNewPlayer ? Colors.white : Colors.black54))),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => isNewPlayer = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(color: isNewPlayer ? Colors.deepOrange : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                              child: Center(child: Text('新規に登録する', style: TextStyle(fontWeight: FontWeight.bold, color: isNewPlayer ? Colors.white : Colors.black54))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  if (!isNewPlayer) ...[
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: '選手を選択', border: OutlineInputBorder()),
                      value: selectedPlayer,
                      items: availablePlayers.map((p) => DropdownMenuItem(value: p['court_name'], child: Text(p['court_name']!, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                      onChanged: (val) => setModalState(() => selectedPlayer = val),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(child: TextField(controller: lastCtrl, decoration: const InputDecoration(labelText: '氏（苗字）', border: OutlineInputBorder()))),
                        const SizedBox(width: 16),
                        Expanded(child: TextField(controller: firstCtrl, decoration: const InputDecoration(labelText: '名', border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: courtCtrl, decoration: const InputDecoration(labelText: 'コートネーム *', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(
                      controller: birthCtrl, readOnly: true, decoration: const InputDecoration(labelText: '誕生日', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(context: context, initialDate: DateTime(2012, 1, 1), firstDate: DateTime(1950), lastDate: DateTime.now());
                        if (picked != null) birthCtrl.text = "\${picked.year}-\${picked.month.toString().padLeft(2, '0')}-\${picked.day.toString().padLeft(2, '0')}";
                      },
                    ),
                  ],

                  const SizedBox(height: 24),
                  const Align(alignment: Alignment.centerLeft, child: Text('今年の背番号・ポジション', style: TextStyle(fontWeight: FontWeight.bold))),
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Expanded(flex: 1, child: TextField(controller: jerseyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '背番号 *', border: OutlineInputBorder()))),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: TextField(controller: positionCtrl, decoration: const InputDecoration(labelText: 'ポジション', border: OutlineInputBorder()))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  ElevatedButton(
                    onPressed: () {
                      String targetCourtName = '';
                      if (isNewPlayer) {
                        if (courtCtrl.text.isEmpty || jerseyCtrl.text.isEmpty) return;
                        targetCourtName = courtCtrl.text;
                        setState(() {
                          _allPlayers.add({'court_name': courtCtrl.text, 'last_name': lastCtrl.text, 'first_name': firstCtrl.text, 'birth': birthCtrl.text});
                        });
                      } else {
                        if (selectedPlayer == null || jerseyCtrl.text.isEmpty) return;
                        targetCourtName = selectedPlayer!;
                      }

                      setState(() {
                        _rosters[_selectedSeason]!.add({'court_name': targetCourtName, 'jersey_number': jerseyCtrl.text, 'position': positionCtrl.text});
                        _rosters[_selectedSeason]!.sort((a, b) => int.parse(a['jersey_number']!).compareTo(int.parse(b['jersey_number']!)));
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('登録する', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
    final currentRoster = _selectedSeason.isNotEmpty ? (_rosters[_selectedSeason] ?? []) : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('SwishLog - チーム管理', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // シーズン切り替えヘッダー
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.deepOrange),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSeason.isEmpty ? null : _selectedSeason,
                      isExpanded: true,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                      items: _seasons.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedSeason = val);
                      },
                      hint: const Text('シーズンなし'),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _showAddSeasonDialog,
                  icon: const Icon(Icons.add_box, color: Colors.blueGrey, size: 28),
                  tooltip: 'シーズン追加',
                ),
                IconButton(
                  onPressed: _seasons.isEmpty ? null : _confirmDeleteSeason,
                  icon: const Icon(Icons.delete, color: Colors.redAccent, size: 28),
                  tooltip: '現在のシーズンを削除',
                )
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // 名簿リスト（スワイプで編集・削除可能に）
          Expanded(
            child: _selectedSeason.isEmpty
              ? const Center(child: Text('シーズンが存在しません。\n右上のボタンから作成してください。', textAlign: TextAlign.center))
              : currentRoster.isEmpty
                ? const Center(child: Text('このシーズンの名簿には誰も登録されていません。\n右下のボタンから追加してください。', textAlign: TextAlign.center))
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: currentRoster.length,
                    itemBuilder: (context, index) {
                      final player = currentRoster[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Slidable(
                          key: ValueKey(player['court_name']),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            extentRatio: 0.5, // ボタンに余白を持たせるため少し広げる
                            children: [
                              CustomSlidableAction(
                                onPressed: (context) {
                                  // 編集処理（今後実装）
                                },
                                backgroundColor: Colors.transparent, // 背景を透明にして隙間を作る
                                padding: EdgeInsets.zero,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(12), // 独立した角丸
                                  ),
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.edit, color: Colors.white),
                                        SizedBox(height: 4),
                                        Text('編集', style: TextStyle(color: Colors.white, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              CustomSlidableAction(
                                onPressed: (context) {
                                  // ★スワイプからの削除時にオプションダイアログを開く
                                  _confirmDeletePlayer(player['court_name']!, index);
                                },
                                backgroundColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                child: Container(
                                  margin: const EdgeInsets.only(left: 4, right: 8, top: 2, bottom: 2), // 右側に少し余白
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.delete, color: Colors.white),
                                        SizedBox(height: 4),
                                        Text('削除', style: TextStyle(color: Colors.white, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          child: Card(
                            margin: EdgeInsets.zero,
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.deepOrange,
                                child: Text(
                                  player['jersey_number']!,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                                ),
                              ),
                              title: Text(player['court_name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              subtitle: Text('ポジション: ${player['position']!.isEmpty ? "未設定" : player['position']}'),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _selectedSeason.isEmpty ? null : FloatingActionButton.extended(
        onPressed: _showAddToRosterModal,
        backgroundColor: Colors.deepOrange,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: const Text('名簿に追加', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
