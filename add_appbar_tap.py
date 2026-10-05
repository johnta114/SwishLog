import os
import re

screens_dir = 'lib/screens'
for filename in os.listdir(screens_dir):
    if filename.endswith('.dart'):
        filepath = os.path.join(screens_dir, filename)
        with open(filepath, 'r') as f:
            content = f.read()
        
        # Check if the file has an AppBar title with SwishLog
        if "Text('SwishLog'" in content:
            # We must import main.dart if not already there
            if "import '../main.dart';" not in content:
                # insert after the last import
                imports_end = content.rfind("import ")
                if imports_end != -1:
                    newline_after_import = content.find("\n", imports_end)
                    content = content[:newline_after_import] + "\nimport '../main.dart';" + content[newline_after_import:]
                else:
                    content = "import '../main.dart';\n" + content

            # Replace title
            # Look for: title: const Text('SwishLog', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
            # or variations.
            
            old_title_regex = r"title:\s*const\s*Text\('SwishLog',\s*style:\s*TextStyle\(fontSize:\s*20,\s*fontWeight:\s*FontWeight\.bold\)\),?"
            
            new_title = """title: GestureDetector(
          onTap: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            mainScreenKey.currentState?.goToHome();
          },
          child: const Text('SwishLog', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),"""
            
            content = re.sub(old_title_regex, new_title, content)
            
            with open(filepath, 'w') as f:
                f.write(content)

