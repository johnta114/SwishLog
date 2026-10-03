import os
import glob
import re

files = glob.glob('lib/screens/*.dart')

for file in files:
    with open(file, 'r') as f:
        content = f.read()
    
    # Remove backgroundColor: Colors.white from showModalBottomSheet
    content = re.sub(r'^\s*backgroundColor:\s*Colors\.white,\s*\n', '', content, flags=re.MULTILINE)
    
    # Remove surfaceTintColor: Colors.transparent
    content = re.sub(r'^\s*surfaceTintColor:\s*Colors\.transparent,\s*\n', '', content, flags=re.MULTILINE)
    
    # Remove shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    content = re.sub(r'^\s*shape:\s*const RoundedRectangleBorder\(borderRadius:\s*BorderRadius\.vertical\(top:\s*Radius\.circular\(20\)\)\),\s*\n', '', content, flags=re.MULTILINE)
    
    with open(file, 'w') as f:
        f.write(content)

