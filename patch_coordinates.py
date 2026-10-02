import re

with open('lib/screens/analytics_screen.dart', 'r') as f:
    content = f.read()

# Fix onTapDown calculation
tap_old = """                    onTapDown: (details) {
                      setState(() {
                        _posX = (details.localPosition.dx / 250) * 15.0;
                        _posY = (details.localPosition.dy / (250 * (14.0 / 15.0))) * 14.0;
                      });
                    },"""

tap_new = """                    onTapDown: (details) {
                      setState(() {
                        _posX = details.localPosition.dx / 250;
                        _posY = details.localPosition.dy / (250 * (14.0 / 15.0));
                      });
                    },"""

content = content.replace(tap_old, tap_new)

# Fix _MiniCourtPainter drawing
paint_old = """    if (x != null && y != null) {
      final dotPaint = Paint()..color = isMade ? Colors.deepOrange : Colors.grey..style = PaintingStyle.fill;
      canvas.drawCircle(mToPx(x!, y!), 6.0, dotPaint);
    }"""

paint_new = """    if (x != null && y != null) {
      final dotPaint = Paint()..color = isMade ? Colors.deepOrange : Colors.grey..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x! * size.width, y! * size.height), 6.0, dotPaint);
    }"""

content = content.replace(paint_old, paint_new)

with open('lib/screens/analytics_screen.dart', 'w') as f:
    f.write(content)
