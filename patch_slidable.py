import re

with open('lib/screens/analytics_screen.dart', 'r') as f:
    content = f.read()

# 1. Add Slidable import
if "package:flutter_slidable/flutter_slidable.dart" not in content:
    content = content.replace("import '../database/database_helper.dart';", "import '../database/database_helper.dart';\nimport 'package:flutter_slidable/flutter_slidable.dart';")

# 2. Add _confirmDeleteStat
delete_method = """  void _confirmDeleteStat(Map<String, dynamic> stat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除の確認'),
        content: const Text('このアクションを削除しますか？\\n（得点の場合は総得点にも反映されます）'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await DatabaseHelper.instance.deleteStat(stat['id'].toString());
              if (widget.gameId != null) {
                await DatabaseHelper.instance.updateGameScoreTotals(widget.gameId!);
              }
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('削除する', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      )
    );
  }
"""

if "_confirmDeleteStat" not in content:
    content = content.replace("  void _showEditStatDialog", delete_method + "\n  void _showEditStatDialog")

# 3. Replace ListTile with Slidable wrapping it
list_tile_old = """            return ListTile(
              leading: CircleAvatar(backgroundColor: iconColor.withValues(alpha: 0.2), child: Icon(icon, color: iconColor, size: 20)),
              title: Text("$name - $label", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(timeStr),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () => _showEditStatDialog(stat),
              ),
            );"""

list_tile_new = """            return Slidable(
              key: ValueKey(stat['id'].toString()),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.5,
                children: [
                  CustomSlidableAction(
                    onPressed: (context) => _showEditStatDialog(stat),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.edit), SizedBox(height: 4), Text('編集', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))])),
                    ),
                  ),
                  CustomSlidableAction(
                    onPressed: (context) => _confirmDeleteStat(stat),
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
              child: ListTile(
                leading: CircleAvatar(backgroundColor: iconColor.withValues(alpha: 0.2), child: Icon(icon, color: iconColor, size: 20)),
                title: Text("$name - $label", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(timeStr),
              ),
            );"""

content = content.replace(list_tile_old, list_tile_new)

with open('lib/screens/analytics_screen.dart', 'w') as f:
    f.write(content)
