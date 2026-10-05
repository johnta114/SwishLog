with open('lib/screens/games_screen.dart', 'r') as f:
    content = f.read()

old_str = """                              decoration: InputDecoration(
                                hintText: '試合日 (例: 2026-10)', hintStyle: const TextStyle(color: Colors.black54, fontSize: 13),
                                isDense: true, filled: true, fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                suffixIcon: Row("""

new_str = """                              decoration: InputDecoration(
                                labelText: '試合日 (例: 2026-10)',
                                isDense: true,
                                border: const OutlineInputBorder(),
                                suffixIcon: Row("""

content = content.replace(old_str, new_str)

with open('lib/screens/games_screen.dart', 'w') as f:
    f.write(content)
