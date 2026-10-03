import re

with open('lib/screens/games_screen.dart', 'r') as f:
    content = f.read()

dropdown_block = """                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: '対象シーズン', border: OutlineInputBorder()),
                    value: selectedSeasonId,
                    items: _seasons.map((s) => DropdownMenuItem(value: s['id'].toString(), child: Text(s['name'].toString()))).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedSeasonId = val);
                    },
                  ),
                  const SizedBox(height: 16),

"""

# 1. Remove the dropdown from its current location
content = content.replace(dropdown_block, "")

# 2. Insert it before the date field
target_date_field = """                  const SizedBox(height: 16),
                  TextField(
                    controller: dateCtrl, readOnly: true,
                    decoration: InputDecoration(
                      labelText: '試合日',"""

new_date_field = dropdown_block + target_date_field
content = content.replace(target_date_field, new_date_field)

with open('lib/screens/games_screen.dart', 'w') as f:
    f.write(content)
