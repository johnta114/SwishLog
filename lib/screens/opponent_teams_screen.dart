import 'package:flutter/material.dart';
import '../database/database_helper.dart';

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
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

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

  void _showAddOpponentModal() {
    final nameCtrl = TextEditingController();
    final prefCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('対戦相手の新規登録', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'チーム名 *', border: OutlineInputBorder()),
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
                  
                  // ★ モックデータではなく、SQLiteデータベースに保存する
                  await DatabaseHelper.instance.insertOpponentTeam({
                    'name': nameCtrl.text,
                    'prefecture': prefCtrl.text,
                    'coach_contact': contactCtrl.text,
                    'notes': notesCtrl.text,
                  });
                  
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
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final name = (opp['name'] ?? '').toLowerCase();
      final pref = (opp['prefecture'] ?? '').toLowerCase();
      return name.contains(query) || pref.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SwishLog - 対戦相手', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // 検索バー
          Container(
            color: Colors.deepOrange,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'チーム名・都道府県で検索', hintStyle: const TextStyle(color: Colors.black54), prefixIcon: const Icon(Icons.search, color: Colors.black54),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(icon: const Icon(Icons.clear, color: Colors.black54), onPressed: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); })
                  : null,
                filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(vertical: 0), border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          
          // リスト表示
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
              : filteredOpponents.isEmpty
                ? const Center(child: Text('まだ対戦相手が登録されていません。\n右下の＋ボタンから追加してください。', textAlign: TextAlign.center))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80, top: 8),
                    itemCount: filteredOpponents.length,
                    itemBuilder: (context, index) {
                      final opp = filteredOpponents[index];
                      // Nullセーフ処理
                      final name = opp['name'] as String? ?? '名称未設定';
                      final pref = opp['prefecture'] as String? ?? '';
                      final contact = opp['coach_contact'] as String? ?? '';
                      final notes = opp['notes'] as String? ?? '';

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ExpansionTile(
                          leading: CircleAvatar(backgroundColor: Colors.blueGrey.shade100, child: const Icon(Icons.shield, color: Colors.blueGrey)),
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Text(pref.isNotEmpty ? '📍 $pref' : '都道府県未設定', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          children: [
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.contact_phone, size: 16, color: Colors.grey), const SizedBox(width: 8),
                                      Text(contact.isNotEmpty ? contact : '連絡先未登録', style: const TextStyle(fontSize: 14)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.notes, size: 16, color: Colors.grey), const SizedBox(width: 8),
                                      Expanded(child: Text(notes.isNotEmpty ? notes : 'メモはありません。', style: const TextStyle(fontSize: 14))),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () => _confirmDelete(opp['id'].toString(), name),
                                        icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                        label: const Text('削除', style: TextStyle(color: Colors.red)),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton.icon(
                                        onPressed: () {}, // 将来的に編集モーダルへ
                                        icon: const Icon(Icons.edit, size: 16),
                                        label: const Text('編集'),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    }
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddOpponentModal,
        backgroundColor: Colors.deepOrange, icon: const Icon(Icons.add, color: Colors.white), label: const Text('チーム追加', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
