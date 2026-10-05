import re

with open('lib/screens/games_screen.dart', 'r') as f:
    content = f.read()

# I will replace everything from return Scaffold( to Expanded(child: filteredGames.isEmpty
# Because the intermediate code is broken.
build_start = "    return Scaffold("
build_end = "              Expanded(\n                child: filteredGames.isEmpty"

regex = re.escape(build_start) + r"[\s\S]*?" + re.escape(build_end)

correct_build = """    return Scaffold(
      appBar: AppBar(
        title: const Text('SwishLog', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), 
        centerTitle: false,
        actions: [ IconButton(icon: const Icon(Icons.search), onPressed: _showSearchModal), ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
        : Column(
            children: [
              Expanded(
                child: filteredGames.isEmpty"""

content = re.sub(regex, correct_build, content)

with open('lib/screens/games_screen.dart', 'w') as f:
    f.write(content)

