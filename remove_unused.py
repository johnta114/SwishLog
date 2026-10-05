import re

def remove_methods(filename):
    with open(filename, 'r') as f:
        content = f.read()

    # Find and remove _formatPercentage
    format_pct_str = r"  String _formatPercentage\(int made, int attempted\) {.*?}\n\n"
    content = re.sub(format_pct_str, "", content, flags=re.DOTALL)

    # Find and remove _buildCellContent
    # Make sure we don't accidentally wipe out the whole file by matching carefully
    build_cell_str = r"  Widget _buildCellContent\(String text, {bool isHeader = false, double minWidth = 72\.0}\) {.*?}\n\n"
    content = re.sub(build_cell_str, "", content, flags=re.DOTALL)

    with open(filename, 'w') as f:
        f.write(content)

remove_methods('lib/screens/home_screen.dart')
remove_methods('lib/screens/game_analytics_screen.dart')

