with open('lib/screens/analytics_screen.dart', 'r') as f:
    content = f.read()

# 1. AlertDialog style
dialog_old = """    return AlertDialog(
      title: const Text('アクションの修正', style: TextStyle(fontWeight: FontWeight.bold)),"""
dialog_new = """    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: const Text('アクションの修正', style: TextStyle(fontWeight: FontWeight.bold)),"""
content = content.replace(dialog_old, dialog_new)

# 2. Container decoration
container_old = """                  decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: GestureDetector("""
container_new = """                  decoration: const BoxDecoration(color: Color(0xFFF6E8D7), border: Border(bottom: BorderSide(color: Colors.black54, width: 2))),
                  child: GestureDetector("""
content = content.replace(container_old, container_new)

# 3. Court lines
painter_old = """    final paintLine = Paint()..color = Colors.black26..style = PaintingStyle.stroke..strokeWidth = 2.0;"""
painter_new = """    final paintLine = Paint()..color = Colors.black54..style = PaintingStyle.stroke..strokeWidth = 2.0;"""
content = content.replace(painter_old, painter_new)

# 4. Hoop circle and resetting line color
hoop_old = """    canvas.drawCircle(hoopCenter, 0.225 * scale, paintLine..color = Colors.deepOrange.withOpacity(0.5)..strokeWidth = 3.0);
    paintLine.color = Colors.black26; paintLine.strokeWidth = 2.0;"""
hoop_new = """    canvas.drawCircle(hoopCenter, 0.225 * scale, paintLine..color = Colors.deepOrange..strokeWidth = 3.0);
    paintLine.color = Colors.black54; paintLine.strokeWidth = 2.0;"""
content = content.replace(hoop_old, hoop_new)

with open('lib/screens/analytics_screen.dart', 'w') as f:
    f.write(content)
