import re

with open('lib/screens/home_screen.dart', 'r') as f:
    content = f.read()

old_helper = """  Widget _buildCellContent(String text, {bool isHeader = false}) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }"""

new_helper = """  Widget _buildCellContent(String text, {bool isHeader = false}) {
    final textWidget = Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal),
    );
    if (isHeader) {
      return Expanded(child: Center(child: textWidget));
    }
    return Center(child: textWidget);
  }"""

content = content.replace(old_helper, new_helper)

with open('lib/screens/home_screen.dart', 'w') as f:
    f.write(content)

with open('lib/screens/game_analytics_screen.dart', 'r') as f:
    content2 = f.read()
content2 = content2.replace(old_helper, new_helper)
with open('lib/screens/game_analytics_screen.dart', 'w') as f:
    f.write(content2)

