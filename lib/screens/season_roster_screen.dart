import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../database/database_helper.dart';

class SeasonRosterScreen extends StatefulWidget {
  const SeasonRosterScreen({super.key});

  @override
  State<SeasonRosterScreen> createState() => _SeasonRosterScreenState();
}

class _SeasonRosterScreenState extends State<SeasonRosterScreen> {
  List<Map<String, dynamic>> _seasons = [];
  List<Map<String, dynamic>> _roster = [];
  String? _selectedSeasonId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final seasons = await DatabaseHelper.instance.getSeasons();
    
    setState(() {
      _seasons = seasons;
    });

    if (seasons.isNotEmpty) {
      if (_selectedSeasonId == null || !seasons.any((s) => s['id'] == _selectedSeasonId)) {
        _selectedSeasonId = seasons.first['id'];
      }
      await _loadRoster(_selectedSeasonId!);
    } else {
      setState(() {
        _roster = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRoster(String seasonId) async {
    setState(() => _isLoading = true);
    final roster = await DatabaseHelper.instance.getRosterForSeason(seasonId);
    setState(() {
      _roster = roster;
      _isLoading = false;
    });
  }

  void _showAddSeasonDialog() {
    final nameCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: DateTime.now().toString().split(' ')[0]);
    
    // 引き継ぎ用ステート
    String? inheritSeasonId;
    List<Map<String, dynamic>> inheritCandidates = [];
    List<String> selectedPlayerIds = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('新規シーズンの作成', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'シーズン名 (例: 2026年度)', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(
                      controller: dateCtrl, readOnly: true,
                      decoration: const InputDecoration(labelText: '開始日', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                        if (picked != null) setModalState(() => dateCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}");
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // 過去のシーズンからの引き継ぎ UI
                    if (_seasons.isNotEmpty) ...[
                      const Divider(),
                      const Text('過去のシーズンから選手を引き継ぐ', style: TextStyle(fontWeight: FontWeight.bold)),
                      DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text('引き継ぎ元のシーズンを選択'),
                        value: inheritSeasonId,
                        items: _seasons.map((s) => DropdownMenuItem(value: s['id'] as String, child: Text(s['name']))).toList(),
                        onChanged: (val) async {
                          if (val != null) {
                            final candidates = await DatabaseHelper.instance.getRosterForSeason(val);
                            setModalState(() {
                              inheritSeasonId = val;
                              inheritCandidates = candidates;
                              // デフォルトで全員チェックを入れる
                              selectedPlayerIds = candidates.map((c) => c['player_id'] as String).toList();
                            });
                          }
                        },
                      ),
                      if (inheritCandidates.isNotEmpty)
                        Container(
                          constraints: const BoxConstraints(maxHeight: 150),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: inheritCandidates.length,
                            itemBuilder: (context, index) {
                              final p = inheritCandidates[index];
                              final pId = p['player_id'] as String;
                              return CheckboxListTile(
                                title: Text(p['court_name'] ?? p['last_name']),
                                subtitle: Text("#${p['jersey_number'] ?? '-'}"),
                                value: selectedPlayerIds.contains(pId),
                                onChanged: (bool? checked) {
                                  setModalState(() {
                                    if (checked == true) selectedPlayerIds.add(pId);
                                    else selectedPlayerIds.remove(pId);
                                  });
                                },
                              );
                            },
                          ),
                        ),
                    ],

                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        if (nameCtrl.text.isEmpty) return;
                        
                        // シーズンをDBに登録
                        final newSeasonId = await DatabaseHelper.instance.insertSeason({
                          'name': nameCtrl.text,
                          'start_date': dateCtrl.text,
                        });

                        // 選択された選手を引き継ぎ（Rosterへの登録）
                        for (final pId in selectedPlayerIds) {
                          final oldRoster = inheritCandidates.firstWhere((p) => p['player_id'] == pId);
                          await DatabaseHelper.instance.insertRoster({
                            'season_id': newSeasonId,
                            'player_id': pId,
                            'jersey_number': oldRoster['jersey_number'],
                            'position': oldRoster['position'],
                          });
                        }

                        if (mounted) Navigator.pop(context);
                        setState(() => _selectedSeasonId = newSeasonId);
                        await _loadData();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, minimumSize: const Size.fromHeight(50)),
                      child: const Text('シーズンを作成', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  void _showAddPlayerModal() async {
    // 既存プレイヤーをDBから取得
    final allPlayers = await DatabaseHelper.instance.getAllPlayers();
    
    bool isNewPlayer = true;
    String? selectedExistingPlayerId;

    final lastCtrl = TextEditingController();
    final firstCtrl = TextEditingController();
    final courtCtrl = TextEditingController();
    final birthCtrl = TextEditingController();
    final jerseyCtrl = TextEditingController();
    String? selectedPosition;
    final positions = ['PG', 'SG', 'SF', 'PF', 'C'];

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('選手をロスターに追加', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    
                    // タブ切り替え風
                    Container(
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setModalState(() => isNewPlayer = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(color: isNewPlayer ? Colors.deepOrange : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                                child: Center(child: Text('新しく選手を登録', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isNewPlayer ? Colors.white : Colors.black54))),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setModalState(() => isNewPlayer = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(color: !isNewPlayer ? Colors.deepOrange : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                                child: Center(child: Text('過去の登録選手から選ぶ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: !isNewPlayer ? Colors.white : Colors.black54))),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (isNewPlayer) ...[
                      Row(
                        children: [
                          Expanded(child: TextField(controller: lastCtrl, decoration: const InputDecoration(labelText: '姓 (Last) *', border: OutlineInputBorder()))),
                          const SizedBox(width: 8),
                          Expanded(child: TextField(controller: firstCtrl, decoration: const InputDecoration(labelText: '名 (First) *', border: OutlineInputBorder()))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(controller: courtCtrl, decoration: const InputDecoration(labelText: 'コートネーム (表示名) *', border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                      TextField(
                        controller: birthCtrl, readOnly: true,
                        decoration: const InputDecoration(labelText: '生年月日', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(context: context, initialDate: DateTime(2014, 4, 1), firstDate: DateTime(1950), lastDate: DateTime.now());
                          if (picked != null) setModalState(() => birthCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}");
                        },
                      ),
                    ] else ...[
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: '登録済みの選手を選択', border: OutlineInputBorder()),
                        value: selectedExistingPlayerId,
                        items: allPlayers.map((p) {
                          return DropdownMenuItem<String>(
                            value: p['id'],
                            child: Text("${p['last_name']} ${p['first_name']} (${p['court_name']})"),
                          );
                        }).toList(),
                        onChanged: (val) => setModalState(() => selectedExistingPlayerId = val),
                      ),
                    ],

                    const Divider(height: 32),
                    const Text('このシーズンでの設定', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: jerseyCtrl, keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: '背番号', border: OutlineInputBorder(), prefixIcon: Icon(Icons.numbers)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'ポジション', border: OutlineInputBorder()),
                            value: selectedPosition,
                            items: [
                              const DropdownMenuItem<String>(value: null, child: Text('未選択')),
                              ...positions.map((p) => DropdownMenuItem(value: p, child: Text(p))),
                            ],
                            onChanged: (val) => setModalState(() => selectedPosition = val),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: () async {
                        if (_selectedSeasonId == null) return;
                        
                        String playerIdToLink;

                        if (isNewPlayer) {
                          if (lastCtrl.text.isEmpty || firstCtrl.text.isEmpty || courtCtrl.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('姓、名、コートネームは必須です')));
                            return;
                          }
                          
                          // ① playersテーブルに新規登録
                          playerIdToLink = await DatabaseHelper.instance.insertPlayer({
                            'last_name': lastCtrl.text,
                            'first_name': firstCtrl.text,
                            'court_name': courtCtrl.text,
                            'birth_date': birthCtrl.text,
                            'is_active': 1,
                          });
                        } else {
                          if (selectedExistingPlayerId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('既存の選手を選択してください')));
                            return;
                          }
                          playerIdToLink = selectedExistingPlayerId!;
                        }

                        // ② rostersテーブルに紐付け（背番号・ポジションを含む）
                        await DatabaseHelper.instance.insertRoster({
                          'season_id': _selectedSeasonId,
                          'player_id': playerIdToLink,
                          'jersey_number': int.tryParse(jerseyCtrl.text),
                          'position': selectedPosition,
                        });

                        if (mounted) Navigator.pop(context);
                        await _loadRoster(_selectedSeasonId!);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, minimumSize: const Size.fromHeight(50)),
                      child: const Text('追加する', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  void _showPlayerEditModal(Map<String, dynamic> player) {
    final lastCtrl = TextEditingController(text: player['last_name']);
    final firstCtrl = TextEditingController(text: player['first_name']);
    final courtCtrl = TextEditingController(text: player['court_name']);
    final birthCtrl = TextEditingController(text: player['birth_date'] ?? '');
    final jerseyCtrl = TextEditingController(text: player['jersey_number']?.toString() ?? '');
    String? selectedPosition = player['position'];
    final positions = ['PG', 'SG', 'SF', 'PF', 'C'];

    if (!positions.contains(selectedPosition)) selectedPosition = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('選手情報の編集', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(controller: lastCtrl, decoration: const InputDecoration(labelText: '姓 (Last Name) *', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(controller: firstCtrl, decoration: const InputDecoration(labelText: '名 (First Name) *', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(controller: courtCtrl, decoration: const InputDecoration(labelText: 'コートネーム *', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(
                      controller: birthCtrl, readOnly: true,
                      decoration: const InputDecoration(labelText: '生年月日 (任意)', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
                      onTap: () async {
                        final initial = DateTime.tryParse(birthCtrl.text) ?? DateTime(2014, 4, 1);
                        final picked = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(1900), lastDate: DateTime.now());
                        if (picked != null) setModalState(() => birthCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}");
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: jerseyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '背番号', border: OutlineInputBorder(), prefixIcon: Icon(Icons.numbers)))),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'ポジション', border: OutlineInputBorder()),
                            value: selectedPosition,
                            items: [
                              const DropdownMenuItem<String>(value: null, child: Text('未選択')),
                              ...positions.map((p) => DropdownMenuItem(value: p, child: Text(p))),
                            ],
                            onChanged: (val) => setModalState(() => selectedPosition = val),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        if (lastCtrl.text.isEmpty || firstCtrl.text.isEmpty || courtCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('姓、名、コートネームは必須です')));
                          return;
                        }
                        // 更新処理
                        await DatabaseHelper.instance.updatePlayer(player['player_id'], {
                          'last_name': lastCtrl.text,
                          'first_name': firstCtrl.text,
                          'court_name': courtCtrl.text,
                          'birth_date': birthCtrl.text,
                        });
                        if (_selectedSeasonId != null) {
                          await DatabaseHelper.instance.updateRoster(_selectedSeasonId!, player['player_id'], {
                            'jersey_number': int.tryParse(jerseyCtrl.text),
                            'position': selectedPosition,
                          });
                        }
                        if (mounted) Navigator.pop(context);
                        _loadData(); // リロード
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('保存する', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  void _confirmDeletePlayer(String playerId, String courtName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('「$courtName」の削除', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.person_remove, color: Colors.orange),
                  title: const Text('このシーズン名簿から外す (安全)'),
                  subtitle: const Text('過去の記録や別シーズンの登録は残ります'),
                  onTap: () async {
                    Navigator.pop(context);
                    await DatabaseHelper.instance.deletePlayerFromRoster(_selectedSeasonId!, playerId);
                    _loadRoster(_selectedSeasonId!);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('マスターデータから完全に削除する (危険)', style: TextStyle(color: Colors.red)),
                  subtitle: const Text('全ての過去の試合記録やスタッツから消去されます'),
                  onTap: () async {
                    Navigator.pop(context);
                    await DatabaseHelper.instance.deletePlayerCompletely(playerId);
                    _loadRoster(_selectedSeasonId!);
                  },
                )
              ],
            ),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SwishLog', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
        : Column(
            children: [
              // シーズン切り替えヘッダー
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.deepOrange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _seasons.isEmpty 
                        ? const Text('シーズンが未登録です', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))
                        : DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedSeasonId,
                              isExpanded: true,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                              items: _seasons.map((s) => DropdownMenuItem(value: s['id'] as String, child: Text(s['name'] as String))).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedSeasonId = val);
                                  _loadRoster(val);
                                }
                              },
                            ),
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_box, color: Colors.deepOrange, size: 28),
                      tooltip: '新規シーズンを作成',
                      onPressed: _showAddSeasonDialog,
                    )
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // 選手リスト
              Expanded(
                child: _seasons.isEmpty
                  ? const Center(child: Text('まずは右上のボタンから\n新しいシーズンを作成してください', textAlign: TextAlign.center))
                  : _roster.isEmpty
                    ? const Center(child: Text('このシーズンの登録選手がいません。\n右下の＋ボタンから追加してください。', textAlign: TextAlign.center))
                    : ListView.builder(
                        itemCount: _roster.length,
                        itemBuilder: (context, index) {
                          final player = _roster[index];
                          final name = player['court_name'] ?? player['last_name'];
                          final number = player['jersey_number']?.toString() ?? '-';
                          final position = player['position'] ?? '-';
                          final pId = player['player_id'] as String;

                          return Slidable(
                            key: ValueKey(pId),
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              extentRatio: 0.5,
                              children: [
                                CustomSlidableAction(
                                  onPressed: (context) => _showPlayerEditModal(player),
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.blue,
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Container(
                                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                                    child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.edit), SizedBox(height: 4), Text('編集', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))])),
                                  ),
                                ),
                                CustomSlidableAction(
                                  onPressed: (context) => _confirmDeletePlayer(pId, name),
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.red,
                                  padding: const EdgeInsets.only(left: 8, right: 8),
                                  child: Container(
                                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                                    child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.delete), SizedBox(height: 4), Text('削除', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))])),
                                  ),
                                ),
                              ],
                            ),
                            child: Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              elevation: 0, color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.deepOrange.shade100,
                                  child: Text(number, style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                                ),
                                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                subtitle: Text('ポジション: $position', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                trailing: const Icon(Icons.arrow_back_ios, size: 12, color: Colors.grey),
                              ),
                            ),
                          );
                        }
                      ),
              ),
            ],
          ),
      floatingActionButton: _seasons.isEmpty ? null : FloatingActionButton.extended(
        onPressed: _showAddPlayerModal,
        backgroundColor: Colors.deepOrange, icon: const Icon(Icons.person_add, color: Colors.white), label: const Text('選手追加', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
