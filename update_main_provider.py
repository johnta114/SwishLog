import re

with open('lib/main.dart', 'r') as f:
    content = f.read()

if "import 'package:provider/provider.dart';" not in content:
    content = "import 'package:provider/provider.dart';\nimport 'providers/app_settings_provider.dart';\n" + content

# Replace runApp(const SwishLogApp());
old_runapp = "runApp(const SwishLogApp());"
new_runapp = """runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
      ],
      child: const SwishLogApp(),
    ),
  );"""
content = content.replace(old_runapp, new_runapp)

with open('lib/main.dart', 'w') as f:
    f.write(content)
