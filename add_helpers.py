import re

with open('lib/screens/game_analytics_screen.dart', 'r') as f:
    content = f.read()

helpers = """
  String _formatPercentage(int made, int attempted) {
    if (attempted == 0) return '0.0%\\n(0/0)';
    final percent = (made / attempted * 100).toStringAsFixed(1);
    return '$percent%\\n($made/$attempted)';
  }

  Widget _buildCellContent(String text, {bool isHeader = false}) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }
"""

if "_buildCellContent" not in content:
    # Insert right before _buildStatsTab
    content = content.replace("  Widget _buildStatsTab() {", helpers + "\n  Widget _buildStatsTab() {")

with open('lib/screens/game_analytics_screen.dart', 'w') as f:
    f.write(content)

