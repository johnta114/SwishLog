import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class OpponentTeamsScreen extends StatefulWidget {
  const OpponentTeamsScreen({super.key});

  @override
  State<OpponentTeamsScreen> createState() => _OpponentTeamsScreenState();
}

class _OpponentTeamsScreenState extends State<OpponentTeamsScreen> {
  // DBから取得したデータを保持
  List<Map<String, dynamic>> _opponents = [];
  bool _isLoading = true;

  // 検索用
  bool _isSearching = false;
  String _searchName = '';
  String _searchPref = '';
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _prefCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOpponents();
  }

  // SQLiteから対戦相手のリストを取得する
  Future<void> _loadOpponents() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getOpponentTeams();
    setState(() {
      _opponents = data;
      _isLoading = false;
    });
  }

  void _showOpponentModal([Map<String, dynamic>? opponent]) {
    final isEdit = opponent != null;
    final nameCtrl = TextEditingController(text: isEdit ? opponent['name'] : '');
    final prefCtrl = TextEditingController(text: isEdit ? opponent['prefecture'] : '');
    final contactCtrl = TextEditingController(text: isEdit ? opponent['coach_contact'] : '');
    final notesCtrl = TextEditingController(text: isEdit ? opponent['notes'] : '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isEdit ? '対戦相手の編集' : '対戦相手の新規登録', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(label: const Text.rich(TextSpan(children: [TextSpan(text: 'チーム名 '), TextSpan(text: '*', style: TextStyle(color: Colors.red))])), border: OutlineInputBorder()),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: prefCtrl,
                decoration: const InputDecoration(labelText: '都道府県', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contactCtrl,
                decoration: const InputDecoration(labelText: '監督の連絡先', border: OutlineInputBorder(), prefixIcon: Icon(Icons.contact_phone)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'チームの特徴・メモ', border: OutlineInputBorder(), alignLabelWithHint: true),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isEmpty) return;
                  
                  final data = {
                    'name': nameCtrl.text,
                    'prefecture': prefCtrl.text,
                    'coach_contact': contactCtrl.text,
                    'notes': notesCtrl.text,
                  };
                  if (isEdit) {
                    await DatabaseHelper.instance.updateOpponentTeam(opponent['id'].toString(), data);
                  } else {
                    await DatabaseHelper.instance.insertOpponentTeam(data);
                  }
                  
                  // 保存が完了したらリストを再読み込みして閉じる
                  await _loadOpponents();
                  if (mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('保存する', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }
    );
  }

  void _confirmDelete(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除の確認'),
        content: Text('「$name」を削除しますか？\n（関連する試合データにも影響が出る可能性があります）'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              // ★ SQLiteから削除
              await DatabaseHelper.instance.deleteOpponentTeam(id);
              Navigator.pop(context);
              _loadOpponents(); // リロード
            },
            child: const Text('削除する', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      )
    );
  }



  @override
  Widget build(BuildContext context) {
    final filteredOpponents = _opponents.where((opp) {
      final matchName = _searchName.isEmpty || (opp['name'] ?? '').toLowerCase().contains(_searchName.toLowerCase());
      final matchPref = _searchPref.isEmpty || (opp['prefecture'] ?? '').toLowerCase().contains(_searchPref.toLowerCase());
      return matchName && matchPref;
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
                        ? const Center(child: Text('対戦相手が登録されていません。\n右下のボタンから追加してください。', textAlign: TextAlign.center))
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
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _nameCtrl,
                            decoration: InputDecoration(
                              labelText: 'チーム名',
                              isDense: true,
                              border: const OutlineInputBorder(),
                              suffixIcon: _searchName.isNotEmpty 
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _nameCtrl.clear();
                                      setState(() => _searchName = '');
                                    },
                                  )
                                : null,
                            ),
                            onChanged: (val) => setState(() => _searchName = val),
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
                              suffixIcon: _searchPref.isNotEmpty 
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _prefCtrl.clear();
                                      setState(() => _searchPref = '');
                                    },
                                  )
                                : null,
                            ),
                            onChanged: (val) => setState(() => _searchPref = val),
                          ),
                        ),
                      ],
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

