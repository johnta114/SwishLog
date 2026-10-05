import re

with open('lib/screens/home_screen.dart', 'r') as f:
    content = f.read()

# I will add numeric: true to all stat columns in both files.
# But first, I need to remove my previous fix if it's there.

def make_numeric(text):
    return re.sub(r"DataColumn\(label: _buildCellContent\('([^']+)', isHeader: true\)\),", r"DataColumn(label: _buildCellContent('\1', isHeader: true), numeric: true),", text)

# For home_screen.dart
# The columns are: 得点, 2P, 3P, フリースロー, リバウンド, アシスト, スティール, ターンオーバー, ファール
# Wait, I shouldn't do numeric: true for '選手' and 'No.'
old_cols = """                                      DataColumn(label: _buildCellContent('得点', isHeader: true)),
                                      DataColumn(label: _buildCellContent('2P', isHeader: true)),
                                      DataColumn(label: _buildCellContent('3P', isHeader: true)),
                                      DataColumn(label: _buildCellContent('フリースロー', isHeader: true)),
                                      DataColumn(label: _buildCellContent('リバウンド', isHeader: true)),
                                      DataColumn(label: _buildCellContent('アシスト', isHeader: true)),
                                      DataColumn(label: _buildCellContent('スティール', isHeader: true)),
                                      DataColumn(label: _buildCellContent('ターンオーバー', isHeader: true)),
                                      DataColumn(label: _buildCellContent('ファール', isHeader: true)),"""
new_cols = """                                      DataColumn(label: _buildCellContent('得点', isHeader: true), numeric: true),
                                      DataColumn(label: _buildCellContent('2P', isHeader: true), numeric: true),
                                      DataColumn(label: _buildCellContent('3P', isHeader: true), numeric: true),
                                      DataColumn(label: _buildCellContent('フリースロー', isHeader: true), numeric: true),
                                      DataColumn(label: _buildCellContent('リバウンド', isHeader: true), numeric: true),
                                      DataColumn(label: _buildCellContent('アシスト', isHeader: true), numeric: true),
                                      DataColumn(label: _buildCellContent('スティール', isHeader: true), numeric: true),
                                      DataColumn(label: _buildCellContent('ターンオーバー', isHeader: true), numeric: true),
                                      DataColumn(label: _buildCellContent('ファール', isHeader: true), numeric: true),"""

content = content.replace(old_cols, new_cols)
with open('lib/screens/home_screen.dart', 'w') as f:
    f.write(content)

with open('lib/screens/game_analytics_screen.dart', 'r') as f:
    content2 = f.read()

content2 = content2.replace(old_cols, new_cols)
with open('lib/screens/game_analytics_screen.dart', 'w') as f:
    f.write(content2)

