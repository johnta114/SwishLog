import re

with open('lib/screens/home_screen.dart', 'r') as f:
    content = f.read()

# Replace the Row in the Card
card_regex = r"(Card\([\s\S]*?Padding\([\s\S]*?padding: const EdgeInsets\.symmetric\(vertical: 24, horizontal: 16\),\s*child:\s*)Row\([\s\S]*?\]\s*,\s*\)"

new_row = """Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatColumn('試合数', _completedGames.length, Colors.black87, () => _showGamesList('全試合', _completedGames)),
                              Container(height: 40, width: 1, color: Colors.grey.shade200),
                              _buildStatColumn('勝', _winGames.length, Colors.deepOrange, () => _showGamesList('勝利した試合', _winGames)),
                              Container(height: 40, width: 1, color: Colors.grey.shade200),
                              _buildStatColumn('負', _lossGames.length, Colors.blueAccent, () => _showGamesList('敗北した試合', _lossGames)),
                              if (_drawGames.isNotEmpty) ...[
                                Container(height: 40, width: 1, color: Colors.grey.shade200),
                                _buildStatColumn('分', _drawGames.length, Colors.blueGrey, () => _showGamesList('引き分けた試合', _drawGames)),
                              ],
                            ],
                          )"""

content = re.sub(card_regex, r"\1" + new_row, content)

with open('lib/screens/home_screen.dart', 'w') as f:
    f.write(content)
