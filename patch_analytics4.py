with open('lib/screens/analytics_screen.dart', 'r') as f:
    content = f.read()

target = """            return ListTile(
              leading: CircleAvatar(backgroundColor: iconColor.withValues(alpha: 0.2), child: Icon(icon, color: iconColor, size: 20)),
              title: Text("$name - $label", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(timeStr),
            );"""
replacement = """            return ListTile(
              leading: CircleAvatar(backgroundColor: iconColor.withValues(alpha: 0.2), child: Icon(icon, color: iconColor, size: 20)),
              title: Text("$name - $label", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(timeStr),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () => _showEditStatDialog(stat),
              ),
            );"""

if target in content:
    content = content.replace(target, replacement)
    with open('lib/screens/analytics_screen.dart', 'w') as f:
        f.write(content)
    print("Fixed ListTile")
else:
    print("ListTile not found")
