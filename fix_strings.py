import re

with open('lib/screens/stats_entry_screen.dart', 'r') as f:
    content = f.read()

# Fix the button texts
content = content.replace("'失敗 (Miss)'", "'失敗'")
content = content.replace("'成功 (Made)'", "'成功'")

# Fix the redundant DB load append
old_load = """        if (type == '2P' || type == '3P' || type == 'FG' || type == 'FT') {
          label = "$label ${isMade ? '成功' : '失敗'}";
        }
        else if (type == 'SUB') label = "交代でIN";"""
new_load = """        if (type == 'SUB') label = "交代でIN";"""
content = content.replace(old_load, new_load)

# Fix the history modal render
old_history = "final isMadeText = log.isMade == null ? '' : (log.isMade! ? ' (成功)' : ' (失敗)');"
new_history = "final isMadeText = log.isMade == null ? '' : (log.isMade! ? ' 成功' : ' 失敗');"
content = content.replace(old_history, new_history)

# Fix the latest log render
old_latest = "_logs.isEmpty ? '▶ まだ記録はありません' : \"▶ 最新: ${_logs.last.playerName} - ${_logs.last.actionLabel} ${_logs.last.isMade == null ? '' : (_logs.last.isMade! ? '(成功)' : '(失敗)')}\","
new_latest = "_logs.isEmpty ? '▶ まだ記録はありません' : \"▶ 最新: ${_logs.last.playerName} - ${_logs.last.actionLabel}${_logs.last.isMade == null ? '' : (_logs.last.isMade! ? ' 成功' : ' 失敗')}\","
content = content.replace(old_latest, new_latest)

with open('lib/screens/stats_entry_screen.dart', 'w') as f:
    f.write(content)

