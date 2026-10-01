import os
import re

directory = "lib/screens"

for filename in os.listdir(directory):
    if filename.endswith(".dart"):
        filepath = os.path.join(directory, filename)
        with open(filepath, "r") as f:
            content = f.read()
            
        original_content = content
        
        # 1. Add backgroundColor: Colors.white, to showModalBottomSheet
        # Use regex to find `showModalBottomSheet(` and insert `backgroundColor: Colors.white,` right after context: context,
        content = re.sub(
            r"showModalBottomSheet\(\s*context:\s*context,\s*",
            r"showModalBottomSheet(\n      context: context,\n      backgroundColor: Colors.white,\n      ",
            content
        )
        
        # We should remove double backgroundColors if they already exist, but none existed.
        
        # 2. Patch labelText containing ' *'
        def replacer(match):
            full_match = match.group(0)
            prefix = match.group(1)
            text_without_star = match.group(2).strip()
            suffix = match.group(3)
            
            # Reconstruct the InputDecoration
            return f"{prefix}label: const Text.rich(TextSpan(children: [TextSpan(text: '{text_without_star} '), TextSpan(text: '*', style: TextStyle(color: Colors.red))])){suffix}"

        content = re.sub(
            r"(InputDecoration\([^)]*?)labelText:\s*'([^']+)\s*\*'([^)]*\))",
            replacer,
            content
        )
        
        if content != original_content:
            with open(filepath, "w") as f:
                f.write(content)
            print(f"Patched {filepath}")

