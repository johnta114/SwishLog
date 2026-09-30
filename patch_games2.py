import re

with open('lib/screens/games_screen.dart', 'r') as f:
    content = f.read()

card_pattern = r"                        return Card\("
card_repl = r"""                        return Slidable(
                          key: ValueKey(game['id'].toString()),
                          endActionPane: ActionPane(
                            motion: const DrawerMotion(),
                            extentRatio: 0.5,
                            children: [
                              CustomSlidableAction(
                                onPressed: (context) => _showGameModal(game),
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.blue,
                                padding: const EdgeInsets.only(left: 8),
                                child: Container(
                                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                                  child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.edit), SizedBox(height: 4), Text('編集', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))])),
                                ),
                              ),
                              CustomSlidableAction(
                                onPressed: (context) => _confirmDeleteGame(game['id'].toString(), game['opponent']),
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.red,
                                padding: const EdgeInsets.only(left: 8, right: 8),
                                child: Container(
                                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                                  child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.delete), SizedBox(height: 4), Text('削除', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))])),
                                ),
                              ),
                            ],
                          ),
                          child: Card("""
content = re.sub(card_pattern, card_repl, content)

# I need to add closing parentheses for Slidable
# It's at the end of the item builder
# The card ends with `                          ),`
# Let's do it manually

with open('lib/screens/games_screen.dart', 'w') as f:
    f.write(content)
