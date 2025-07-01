// homepage.dart

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'user.dart';
import 'user_profile.dart';

void main() => runApp(const PasaleApp());

class PasaleApp extends StatefulWidget {
  const PasaleApp({super.key});
  @override
  State<PasaleApp> createState() => _PasaleAppState();
}

class _PasaleAppState extends State<PasaleApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pasale',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(
        isDark: isDark,
        onThemeSwitch: () => setState(() => isDark = !isDark),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onThemeSwitch;
  const HomeScreen({super.key, required this.isDark, required this.onThemeSwitch});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedAction = 'किन्यो';
  int quantity = 1;
  int selectedCategoryIdx = 0;
  List<CategoryCard> categories = [
    CategoryCard(name: 'चामल', icon: Icons.rice_bowl, color: Colors.amber),
    CategoryCard(name: 'दाल', icon: Icons.soup_kitchen, color: Colors.orange),
    CategoryCard(name: 'तेल', icon: Icons.oil_barrel, color: Colors.yellow),
    CategoryCard(name: 'नुन', icon: Icons.spa, color: Colors.blue),
  ];
  List<ActionHistory> history = [];

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceInput = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _showAddCategorySheet() {
    final controller = TextEditingController();
    Color selectedColor = Colors.purple;
    IconData selectedIcon = Icons.category;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24
        ),
        child: StatefulBuilder(
          builder: (context, setSheetState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('नयाँ Category थप्नुहोस्', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Category नाम',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text("रंग:", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(width: 8),
                  ...[
                    Colors.purple, Colors.amber, Colors.green, Colors.orange, Colors.blue, Colors.red
                  ].map((c) => GestureDetector(
                    onTap: () => setSheetState(() => selectedColor = c),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(color: selectedColor == c ? Colors.black : Colors.transparent, width: 2),
                      ),
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text("Icon: ", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(width: 8),
                  ...[
                    Icons.fastfood, Icons.rice_bowl, Icons.spa,
                    Icons.oil_barrel, Icons.coffee, Icons.soup_kitchen,
                    Icons.local_drink, Icons.cake,
                  ].map((ic) => IconButton(
                    icon: Icon(ic, color: selectedIcon == ic ? selectedColor : Colors.grey),
                    onPressed: () => setSheetState(() => selectedIcon = ic),
                  )),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(160, 52),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.add),
                label: const Text("थप्नुहोस्"),
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Category नाम लेख्नुहोस्")),
                    );
                    return;
                  }
                  if (categories.any((c) => c.name == name)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("यस नामको Category पहिल्यै छ")),
                    );
                    return;
                  }
                  setState(() {
                    categories.add(CategoryCard(name: name, icon: selectedIcon, color: selectedColor));
                    selectedCategoryIdx = categories.length - 1;
                  });
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleVoiceInput(String input) {
    String action = selectedAction;
    int qty = quantity;
    int catIdx = selectedCategoryIdx;
    final buyWords = ['किन्यो', 'किन्न', 'buy'];
    final sellWords = ['बेच्यो', 'बेच्न', 'sell'];
    final numbers = RegExp(r'\d+');
    if (buyWords.any((w) => input.contains(w))) action = 'किन्यो';
    if (sellWords.any((w) => input.contains(w))) action = 'बेच्यो';
    final numberMatch = numbers.firstMatch(input);
    if (numberMatch != null) qty = int.parse(numberMatch.group(0)!);

    for (var i = 0; i < categories.length; i++) {
      if (input.contains(categories[i].name)) {
        catIdx = i;
        break;
      }
    }
    if (!categories.any((c) => input.contains(c.name)) && input.trim().isNotEmpty) {
      setState(() {
        categories.add(CategoryCard(name: input.trim(), icon: Icons.category, color: Colors.purple));
        catIdx = categories.length - 1;
      });
    }
    setState(() {
      selectedAction = action;
      quantity = qty;
      selectedCategoryIdx = catIdx;
      _voiceInput = input;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("🎤 पहिचान: $input")),
    );
  }

  void _handleConfirm() {
    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Category थप्नुहोस्!")),
      );
      return;
    }
    setState(() {
      history.insert(
        0,
        ActionHistory(
          action: selectedAction,
          category: categories[selectedCategoryIdx].name,
          quantity: quantity,
          date: DateTime.now(),
          color: categories[selectedCategoryIdx].color,
          icon: categories[selectedCategoryIdx].icon,
        ),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ $selectedAction: ${categories[selectedCategoryIdx].name} - Qty: $quantity'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            setState(() { history.removeAt(0); });
          },
        ),
      ),
    );
    setState(() {
      quantity = 1;
    });

    // Navigate to UserProfileScreen with fixed user info (change this data as you want)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(
          user: User(
            id: 'user123',
            name: 'Diya Shakya',
            shopName: 'Pasale Store',
            location: 'Kathmandu, Nepal',
            contact: '+977-9800000000',
            email: 'diya@example.com',
            website: 'https://pasalestore.com',
            description: 'Welcome to Pasale Store, your trusted shop in Kathmandu.',
            profileImageUrl: '', // can be empty or a URL string
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: color.primaryContainer,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.storefront, size: 32),
            const SizedBox(width: 10),
            Text("Pasale", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: widget.isDark
                  ? Icon(Icons.light_mode, key: const ValueKey('light'), color: Colors.yellow)
                  : Icon(Icons.dark_mode, key: const ValueKey('dark'), color: Colors.deepPurple),
            ),
            onPressed: widget.onThemeSwitch,
            tooltip: "Switch Theme",
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // Action Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ActionButton(
                    label: 'किन्यो',
                    icon: Icons.shopping_cart_rounded,
                    isSelected: selectedAction == 'किन्यो',
                    selectedColor: Colors.green,
                    onTap: () => setState(() => selectedAction = 'किन्यो'),
                  ),
                  const SizedBox(width: 20),
                  _ActionButton(
                    label: 'बेच्यो',
                    icon: Icons.sell,
                    isSelected: selectedAction == 'बेच्यो',
                    selectedColor: Colors.red,
                    onTap: () => setState(() => selectedAction = 'बेच्यो'),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Category Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Category छान्नुहोस्", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.deepPurple, size: 28),
                    onPressed: _showAddCategorySheet,
                    tooltip: "नयाँ Category थप्नुहोस्",
                  ),
                ],
              ),
              Container(
                height: 96,
                padding: const EdgeInsets.only(top: 8, bottom: 14),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (ctx, i) {
                    final cat = categories[i];
                    final isSelected = i == selectedCategoryIdx;
                    return GestureDetector(
                      onTap: () => setState(() => selectedCategoryIdx = i),
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(cat.name),
                            content: const Text("हटाउने हो?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    if (selectedCategoryIdx == i) {
                                      selectedCategoryIdx = 0;
                                    }
                                    categories.removeAt(i);
                                  });
                                  Navigator.pop(ctx);
                                },
                                child: const Text("Delete", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 110,
                        decoration: BoxDecoration(
                          color: isSelected ? cat.color.withOpacity(0.77) : color.surfaceVariant,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: isSelected
                              ? [BoxShadow(color: cat.color.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 3))]
                              : null,
                          border: Border.all(
                            color: isSelected ? cat.color : Colors.transparent,
                            width: isSelected ? 2.2 : 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(cat.icon, color: isSelected ? Colors.white : cat.color, size: 34),
                            const SizedBox(height: 7),
                            Text(
                              cat.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : cat.color,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              // Quantity Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    iconSize: 36,
                    onPressed: () => setState(() { if (quantity > 1) quantity--; }),
                  ),
                  const SizedBox(width: 20),
                  Text(quantity.toString(), style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    iconSize: 36,
                    onPressed: () => setState(() { quantity++; }),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Confirm Button
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Confirm'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(160, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _handleConfirm,
                ),
              ),

              const SizedBox(height: 30),

              // History List
              if (history.isNotEmpty)
                Text("इतिहास", style: Theme.of(context).textTheme.titleLarge),
              ...history.map((h) => ListTile(
                leading: Icon(h.icon, color: h.color),
                title: Text('${h.action} ${h.category}'),
                trailing: Text('Qty: ${h.quantity}'),
                subtitle: Text(h.date.toLocal().toString().split(' ')[0]),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

// Supporting classes

class CategoryCard {
  final String name;
  final IconData icon;
  final Color color;

  CategoryCard({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class ActionHistory {
  final String action;
  final String category;
  final int quantity;
  final DateTime date;
  final Color color;
  final IconData icon;

  ActionHistory({
    required this.action,
    required this.category,
    required this.quantity,
    required this.date,
    required this.color,
    required this.icon,
  });
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isSelected ? Colors.white : Colors.black87;
    final bgColor = isSelected ? selectedColor : Colors.transparent;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selectedColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
