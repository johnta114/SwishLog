import re

with open('lib/screens/season_roster_screen.dart', 'r') as f:
    content = f.read()

# 1. Add Edit & Delete UI to header
header_old = """                    IconButton(
                      icon: const Icon(Icons.add_box, color: Colors.deepOrange, size: 28),
                      tooltip: '新規シーズンを作成',
                      onPressed: _showAddSeasonDialog,
                    )"""

header_new = """                    if (_seasons.isNotEmpty)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.grey),
                        onSelected: (val) {
                          if (val == 'edit') _showEditSeasonDialog();
                          if (val == 'delete') _confirmDeleteSeason();
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('シーズン情報を編集')),
                          const PopupMenuItem(value: 'delete', child: Text('シーズンを削除', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    IconButton(
                      icon: const Icon(Icons.add_box, color: Colors.deepOrange, size: 28),
                      tooltip: '新規シーズンを作成',
                      onPressed: _showAddSeasonDialog,
                    )"""

content = content.replace(header_old, header_new)

# 2. Add methods for edit and delete
add_season_method_signature = "  void _showAddSeasonDialog() {"
new_methods = """  void _showEditSeasonDialog() {
    if (_selectedSeasonId == null) return;
    final currentSeason = _seasons.firstWhere((s) => s['id'] == _selectedSeasonId);
    final nameCtrl = TextEditingController(text: currentSeason['name']);
    final dateCtrl = TextEditingController(text: currentSeason['start_date']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('シーズン情報を編集', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'シーズン名 (例: 2026年度)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(
                controller: dateCtrl, readOnly: true,
                decoration: InputDecoration(
                  labelText: '開始日', border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final date = await showDatePicker(context: context, initialDate: DateTime.tryParse(dateCtrl.text) ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                      if (date != null) dateCtrl.text = date.toString().split(' ')[0];
                    }
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                await DatabaseHelper.instance.updateSeason(_selectedSeasonId!, {
                  'name': nameCtrl.text,
                  'start_date': dateCtrl.text,
                });
                if (mounted) Navigator.pop(context);
                await _loadData();
              },
              child: const Text('保存', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteSeason() {
    if (_selectedSeasonId == null) return;
    final currentSeason = _seasons.firstWhere((s) => s['id'] == _selectedSeasonId);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('シーズンの削除', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: Text('「${currentSeason['name']}」を本当に削除しますか？\\n※このシーズンに紐づく試合データやロスター情報は破棄されますが、選手自体のマスターデータは残ります。'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await DatabaseHelper.instance.deleteSeason(_selectedSeasonId!);
                if (mounted) Navigator.pop(context);
                final remaining = await DatabaseHelper.instance.getAllSeasons();
                setState(() {
                  if (remaining.isNotEmpty) {
                    _selectedSeasonId = remaining.first['id'] as String;
                  } else {
                    _selectedSeasonId = null;
                  }
                });
                await _loadData();
              },
              child: const Text('削除する', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }
    );
  }

"""
content = content.replace(add_season_method_signature, new_methods + add_season_method_signature)

with open('lib/screens/season_roster_screen.dart', 'w') as f:
    f.write(content)
