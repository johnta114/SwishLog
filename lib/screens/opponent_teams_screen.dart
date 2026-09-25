import 'package:flutter/material.dart';

class OpponentTeamsScreen extends StatefulWidget {
  const OpponentTeamsScreen({super.key});

  @override
  State<OpponentTeamsScreen> createState() => _OpponentTeamsScreenState();
}

class _OpponentTeamsScreenState extends State<OpponentTeamsScreen> {
  // モックデータ：対戦相手のリスト
  final List<Map<String, String>> _opponents = [
    {'name': '〇〇高校', 'prefecture': '東京都', 'contact': '山田監督 (090-XXXX-XXXX)', 'notes': 'オールコートマンツーマンが激しい。ガードの#4が要警戒。'},
    {'name': '□□クラブ', 'prefecture': '神奈川県', 'contact': '佐藤コーチ (sato@example.com)', 'notes': '2-3ゾーンディフェンス中心。リバウンドが強い。'},
    {'name': '△△クラブ (練習試合)', 'prefecture': '埼玉県', 'contact': '', 'notes': '毎月合同練習をしているチーム。'},
  ];

  // 検索クエリ
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  // 対戦相手の新規登録ダイアログ
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
                onPressed: () {
                  if (nameCtrl.text.isEmpty) return;
                  setState(() {
                    _opponents.add({
                      'name': nameCtrl.text,
                      'prefecture': prefCtrl.text,
                      'contact': contactCtrl.text,
                      'notes': notesCtrl.text,
                    });
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

  @override
  Widget build(BuildContext context) {
    // 検索フィルタリング
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
                hintText: 'チーム名・都道府県で検索',
                hintStyle: const TextStyle(color: Colors.black54),
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.black54),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          
          // リスト表示
          Expanded(
            child: filteredOpponents.isEmpty
              ? const Center(child: Text('対戦相手が見つかりません。', textAlign: TextAlign.center))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80, top: 8),
                  itemCount: filteredOpponents.length,
                  itemBuilder: (context, index) {
                    final opp = filteredOpponents[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueGrey.shade100,
                          child: const Icon(Icons.shield, color: Colors.blueGrey),
                        ),
                        title: Text(opp['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text(opp['prefecture']!.isNotEmpty ? '📍 ${opp['prefecture']}' : '未設定', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        children: [
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.contact_phone, size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(opp['contact']!.isNotEmpty ? opp['contact']! : '連絡先未登録', style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.notes, size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(opp['notes']!.isNotEmpty ? opp['notes']! : 'メモはありません。', style: const TextStyle(fontSize: 14)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () {}, // 編集モーダルへ
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text('編集する'),
                                  ),
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
        backgroundColor: Colors.deepOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('チーム追加', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
