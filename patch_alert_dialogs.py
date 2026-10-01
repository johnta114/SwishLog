import os
import re

directory = "lib/screens"

for filename in os.listdir(directory):
    if filename.endswith(".dart"):
        filepath = os.path.join(directory, filename)
        with open(filepath, "r") as f:
            content = f.read()
            
        original_content = content
        
        # Add backgroundColor and surfaceTintColor to AlertDialog if not present
        def replacer(match):
            full = match.group(0)
            if "backgroundColor:" in full or "surfaceTintColor:" in full:
                return full
            return full.replace("AlertDialog(", "AlertDialog(\n      backgroundColor: Colors.white,\n      surfaceTintColor: Colors.transparent,")
            
        # Match AlertDialog( ... ) carefully. We'll just replace 'AlertDialog(' for any that don't already have it
        # Since it's a bit tricky with nested parens, let's just do a simple replace and hope it works for our specific cases.
        content = re.sub(r"AlertDialog\(\s*(?!backgroundColor|surfaceTintColor)", r"AlertDialog(\n        backgroundColor: Colors.white,\n        surfaceTintColor: Colors.transparent,\n        ", content)
        
        if content != original_content:
            with open(filepath, "w") as f:
                f.write(content)
            print(f"Patched AlertDialogs in {filepath}")

