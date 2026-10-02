import re

with open('lib/screens/analytics_screen.dart', 'r') as f:
    content = f.read()

chip_old = """  Widget _buildFilterChip(String label, int value) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedQuarter == value,
      onSelected: (selected) {
        if (selected) _updateQuarter(value);
      },
      selectedColor: Colors.deepOrange.shade100,
      labelStyle: TextStyle(
        color: _selectedQuarter == value ? Colors.deepOrange.shade900 : Colors.black87,
        fontWeight: _selectedQuarter == value ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }"""

chip_new = """  Widget _buildFilterChip(String label, int value) {
    return ChoiceChip(
      label: Text(label),
      showCheckmark: false,
      selected: _selectedQuarter == value,
      onSelected: (selected) {
        if (selected) _updateQuarter(value);
      },
      selectedColor: Colors.deepOrange.shade100,
      labelStyle: TextStyle(
        color: _selectedQuarter == value ? Colors.deepOrange.shade900 : Colors.black87,
        fontWeight: FontWeight.bold,
      ),
    );
  }"""

content = content.replace(chip_old, chip_new)

with open('lib/screens/analytics_screen.dart', 'w') as f:
    f.write(content)
