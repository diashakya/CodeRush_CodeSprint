import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:math';
import 'screens/dashboard_page.dart';

void main() {
  runApp(NepalShopApp());
}

class NepalShopApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'पसले',
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: Color(0xFF1E88E5),
        fontFamily: 'Roboto',
      ),
      home: ShopHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Product {
  final String name;
  final String category; // This will match filter section
  final double price;
  final String unit;
  int quantity;

  Product({
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    this.quantity = 0,
  });
}

class SaleRecord {
  final String productName;
  final DateTime time;
  final int quantity;
  final double totalAmount;
  final String type; // 'buy' or 'sell'

  SaleRecord({
    required this.productName,
    required this.time,
    required this.quantity,
    required this.totalAmount,
    required this.type,
  });
}

class ShopHomePage extends StatefulWidget {
  @override
  _ShopHomePageState createState() => _ShopHomePageState();
}

class _ShopHomePageState extends State<ShopHomePage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'सबै';
  List<Product> _filteredProducts = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _categories = [
    'सबै',
    'खानेकुरा',
    'नास्ता / स्न्याक्स',
    'पेय पदार्थ',
    'मसला',
    'घरेलु सामान',
  ];

  // Generate random quantities for demo
  final Random _random = Random();

  late final List<Product> _products;

  final List<SaleRecord> _sales = [];

  // Voice recognition fields
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isDialogOpen = false; // <-- Added dialog open flag

  // Bottom Navbar index
  int _selectedNavbarIndex = 0;

  @override
  void initState() {
    super.initState();
    // List of all products with random quantity for demo
    _products = [
  // खानेकुरा
  Product(name: 'बास्मती चामल', category: 'खानेकुरा', price: 180, unit: 'केजी', quantity: _rand()),
  Product(name: 'दाल', category: 'खानेकुरा', price: 150, unit: 'केजी', quantity: _rand()),
  Product(name: 'तोरीको तेल', category: 'खानेकुरा', price: 320, unit: 'लिटर', quantity: _rand()),
  Product(name: 'नुन', category: 'खानेकुरा', price: 20, unit: 'प्याकेट', quantity: _rand()),
  Product(name: 'चिनी', category: 'खानेकुरा', price: 100, unit: 'केजी', quantity: _rand()),
  Product(name: 'पीठो', category: 'खानेकुरा', price: 85, unit: 'केजी', quantity: _rand()),
  Product(name: 'गुन्द्रुक', category: 'खानेकुरा', price: 95, unit: 'प्याकेट', quantity: _rand()),
  Product(name: 'गहुँ', category: 'खानेकुरा', price: 90, unit: 'केजी', quantity: _rand()),
  Product(name: 'मकै', category: 'खानेकुरा', price: 80, unit: 'केजी', quantity: _rand()),
  Product(name: 'कोदो', category: 'खानेकुरा', price: 100, unit: 'केजी', quantity: _rand()),

  // मसला
  Product(name: 'जीरा', category: 'मसला', price: 200, unit: 'केजी', quantity: _rand()),
  Product(name: 'गरम मसला', category: 'मसला', price: 120, unit: 'प्याकेट', quantity: _rand()),
  Product(name: 'हल्दी पाउडर', category: 'मसला', price: 90, unit: 'प्याकेट', quantity: _rand()),
  Product(name: 'धनियाँ पाउडर', category: 'मसला', price: 80, unit: 'प्याकेट', quantity: _rand()),
  Product(name: 'अदुवा पाउडर', category: 'मसला', price: 100, unit: 'प्याकेट', quantity: _rand()),
  Product(name: 'लसुन पाउडर', category: 'मसला', price: 110, unit: 'प्याकेट', quantity: _rand()),

  // नास्ता / स्न्याक्स
  Product(name: 'चाउचाउ', category: 'नास्ता / स्न्याक्स', price: 25, unit: 'प्याकेट', quantity: _rand()),
  Product(name: 'कुरकुरे', category: 'नास्ता / स्न्याक्स', price: 20, unit: 'प्याकेट', quantity: _rand()),
  Product(name: 'बिस्कुट', category: 'नास्ता / स्न्याक्स', price: 30, unit: 'प्याकेट', quantity: _rand()),
  Product(name: 'पापड', category: 'नास्ता / स्न्याक्स', price: 15, unit: 'पिस', quantity: _rand()),
  Product(name: 'सेल रोटी मिक्स', category: 'नास्ता / स्न्याक्स', price: 125, unit: 'प्याकेट', quantity: _rand()),
  Product(name: 'भुजा', category: 'नास्ता / स्न्याक्स', price: 40, unit: 'प्याकेट', quantity: _rand()),
  Product(name: 'मकै भुटेको', category: 'नास्ता / स्न्याक्स', price: 30, unit: 'प्याकेट', quantity: _rand()),

  // पेय पदार्थ
  Product(name: 'कोकाकोला', category: 'पेय पदार्थ', price: 60, unit: 'बोतल', quantity: _rand()),
  Product(name: 'फ्रूटी', category: 'पेय पदार्थ', price: 25, unit: 'प्याकेट', quantity: _rand()),
  Product(name: 'रियल ज्यूस', category: 'पेय पदार्थ', price: 90, unit: 'प्याकेट', quantity: _rand()),
  Product(name: 'मिनरल वाटर', category: 'पेय पदार्थ', price: 20, unit: 'बोतल', quantity: _rand()),
  Product(name: 'नेपाली चिया', category: 'पेय पदार्थ', price: 45, unit: 'प्याकेट', quantity: _rand()),
  Product(name: 'इन्स्टेन्ट कफी', category: 'पेय पदार्थ', price: 120, unit: 'प्याकेट', quantity: _rand()),

  // घरेलु सामान
  Product(name: 'मह', category: 'घरेलु सामान', price: 850, unit: 'बोतल', quantity: _rand()),
  Product(name: 'अचार', category: 'घरेलु सामान', price: 280, unit: 'बोतल', quantity: _rand()),
  Product(name: 'घ्यु', category: 'घरेलु सामान', price: 1200, unit: 'लिटर', quantity: _rand()),
  Product(name: 'सावुन', category: 'घरेलु सामान', price: 25, unit: 'पिस', quantity: _rand()),
  Product(name: 'टुथपेस्ट', category: 'घरेलु सामान', price: 90, unit: 'वटा', quantity: _rand()),
  Product(name: 'ब्रस', category: 'घरेलु सामान', price: 40, unit: 'वटा', quantity: _rand()),
  Product(name: 'डिटर्जेन्ट पाउडर', category: 'घरेलु सामान', price: 90, unit: 'प्याकेट', quantity: _rand()),
  Product(name: 'डिटर्जेन्ट बार', category: 'घरेलु सामान', price: 25, unit: 'पिस', quantity: _rand()),
  Product(name: 'फिनाइल', category: 'घरेलु सामान', price: 100, unit: 'बोतल', quantity: _rand()),
  Product(name: 'झाडु', category: 'घरेलु सामान', price: 80, unit: 'वटा', quantity: _rand()),

  // खाना पकाउने सामग्री
  Product(name: 'ग्यास सिलिन्डर', category: 'खाना पकाउने सामग्री', price: 1800, unit: 'वटा', quantity: _rand()),
  Product(name: 'कुकर', category: 'खाना पकाउने सामग्री', price: 1200, unit: 'वटा', quantity: _rand()),
  Product(name: 'भाँडा माझ्ने साबुन', category: 'खाना पकाउने सामग्री', price: 25, unit: 'पिस', quantity: _rand()),
  Product(name: 'भाँडा माझ्ने लिक्विड', category: 'खाना पकाउने सामग्री', price: 120, unit: 'बोतल', quantity: _rand()),

  // बच्चाको सामग्री
  Product(name: 'पाम्पर्स', category: 'बच्चाको सामग्री', price: 300, unit: 'प्याकेट', quantity: _rand()),
  Product(name: 'बेबी लोसन', category: 'बच्चाको सामग्री', price: 250, unit: 'बोतल', quantity: _rand()),
  Product(name: 'बेबी पाउडर', category: 'बच्चाको सामग्री', price: 180, unit: 'बोतल', quantity: _rand()),
  Product(name: 'बेबी साबुन', category: 'बच्चाको सामग्री', price: 60, unit: 'पिस', quantity: _rand()),

  // अन्य
  Product(name: 'मोमबत्ती', category: 'अन्य', price: 20, unit: 'प्याकेट', quantity: _rand()),
  Product(name: 'म्याचिस', category: 'अन्य', price: 5, unit: 'प्याकेट', quantity: _rand()),
  Product(name: 'प्लास्टिक झोला', category: 'अन्य', price: 10, unit: 'पिस', quantity: _rand()),
  Product(name: 'अल्मुनियम फोइल', category: 'अन्य', price: 90, unit: 'रोल', quantity: _rand()),
];

    _filteredProducts = _products;
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();

    _speech = stt.SpeechToText();
  }

  // Helper to generate random quantity (between 5 and 28)
  static int _rand() {
    return 5 + Random().nextInt(24); // 5 to 28
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesSearch = product.name.toLowerCase().contains(_searchController.text.toLowerCase());
        final matchesCategory = _selectedCategory == 'सबै' || product.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _buyProduct(Product product) {
    setState(() {
      if (product.quantity < 20) {
        product.quantity++;
        _sales.add(
          SaleRecord(
            productName: product.name,
            time: DateTime.now(),
            quantity: 1,
            totalAmount: product.price,
            type: 'buy',
          ),
        );
      }
    });
    _showSnackBar('${product.name} किनियो! जम्मा: ${product.quantity}', Colors.green);
  }

  void _sellProduct(Product product) {
    setState(() {
      if (product.quantity > 0) {
        product.quantity--;
        _sales.add(
          SaleRecord(
            productName: product.name,
            time: DateTime.now(),
            quantity: 1,
            totalAmount: product.price,
            type: 'sell',
          ),
        );
      }
    });
    _showSnackBar('${product.name} बेचियो! जम्मा: ${product.quantity}', Colors.orange);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'खानेकुरा':
        return Colors.teal;
      case 'नास्ता / स्न्याक्स':
        return Colors.deepOrange;
      case 'पेय पदार्थ':
        return Colors.blue;
      case 'मसला':
        return Colors.green;
      case 'घरेलु सामान':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'खानेकुरा':
        return Icons.fastfood;
      case 'नास्ता / स्न्याक्स':
        return Icons.fastfood;
      case 'पेय पदार्थ':
        return Icons.local_drink;
      case 'मसला':
        return Icons.spa;
      case 'घरेलु सामान':
        return Icons.home;
      default:
        return Icons.inventory_2;
    }
  }

  // --- MIC FUNCTION WITH POPUP ---
  void _listenVoice() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            setState(() => _isListening = false);
            _closeListeningDialog();
          }
        },
        onError: (val) {
          setState(() => _isListening = false);
          _closeListeningDialog();
          _showSnackBar('Mic error: ${val.errorMsg}', Colors.red);
        },
      );
      if (available) {
        setState(() => _isListening = true);
        _showListeningDialog();
        await _speech.listen(
          localeId: 'ne_NP', // Try removing if Nepali not supported
          onResult: (val) {
            setState(() {
              _searchController.text = val.recognizedWords;
              _filterProducts();
            });
          },
        );
      } else {
        _showSnackBar('Speech recognition unavailable!', Colors.red);
      }
    } else {
      setState(() => _isListening = false);
      await _speech.stop();
      _closeListeningDialog();
    }
  }

  void _showListeningDialog() {
    if (!_isDialogOpen) {
      _isDialogOpen = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey.shade100,
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(22),
                  child: Icon(Icons.mic_rounded, color: Colors.red, size: 60),
                ),
                SizedBox(height: 14),
                Text(
                  "आवाज सुन्दैछ...\nकृपया बोल्नुहोस्!",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  "Voice is listening...",
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ).then((_) {
        _isDialogOpen = false;
      });
    }
  }

  void _closeListeningDialog() {
    if (_isDialogOpen) {
      Navigator.of(context, rootNavigator: true).pop();
      _isDialogOpen = false;
    }
  }
  // --- END MIC FUNCTION WITH POPUP ---

  // --- Cool Bottom Navbar ---
  Widget _buildBottomNavbar() {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF1E88E5),
        unselectedItemColor: Colors.grey[500],
        currentIndex: _selectedNavbarIndex,
        elevation: 14,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded, size: 28),
            label: "गृहपृष्ठ",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded, size: 28),
            label: "प्रोफाइल",
          ),
            
          
          BottomNavigationBarItem(
            icon: Icon(Icons.info_rounded, size: 28),
            label: "हाम्रो बारेमा",
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedNavbarIndex = index;
          });
          if (index == 1) {
            _showProfileDialog();
          } else if (index == 2) {
            _showAboutUsDialog();
          }
          // index==0 is home, do nothing (just stay here)
        },
      ),
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(Icons.person_rounded, color: Color(0xFF1E88E5)),
            SizedBox(width: 10),
            Text('प्रोफाइल', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Color(0xFF1E88E5),
                child: Icon(Icons.person, size: 48, color: Colors.white),
              ),
              SizedBox(height: 14),
              Text('Ram Bahadur', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 6),
              Text('rambahadur@gmail.com', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
              SizedBox(height: 12),
              Divider(),
              ListTile(
                leading: Icon(Icons.store, color: Color(0xFF43A047)),
                title: Text('पसलको नाम:'),
                subtitle: Text('सबित्रा किराना तथा चिया पसल'),
              ),
              ListTile(
                leading: Icon(Icons.phone, color: Color(0xFF43A047)),
                title: Text('फोन:'),
                subtitle: Text('९८४५६७८९०१'),
              ),
              ListTile(
                leading: Icon(Icons.location_on, color: Color(0xFF43A047)),
                title: Text('ठेगाना:'),
                subtitle: Text('काठमाडौं, नेपाल'),
              ),
              ListTile(
                leading: Icon(Icons.category, color: Color(0xFF43A047)),
                title: Text('पसलको प्रकार:'),
                subtitle: Text('किराना'),
              ),
              ListTile(
                leading: Icon(Icons.confirmation_number, color: Color(0xFF43A047)),
                title: Text('पसल ID:'),
                subtitle: Text('SHOP0125'),
              ),
              ListTile(
                leading: Icon(Icons.sync, color: Color(0xFF43A047)),
                title: Text('अन्तिम Sync:'),
                subtitle: Text(
                  '2025-06-23 8:15:00', // <-- Static date/time
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ठिक छ'),
          ),
        ],
      ),
    );
  }

  void _showAboutUsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(Icons.info_rounded, color: Color(0xFF1E88E5)),
            SizedBox(width: 10),
            Text('हाम्रो बारेमा', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'पसले एक सरल, स्मार्ट र नेपाली भाषामा आधारित पसल व्यवस्थापन एप हो। '
                  'यस एपको उद्देश्य साना तथा मझौला व्यवसायीहरूको दैनिक व्यापार सजिलो बनाउनु हो।\n\n'
                  'यो एप डेमो प्रयोजनका लागि बनाइएको हो।\n\n'
                  'पसले एपले स्टक व्यवस्थापन, बिक्री/किनमेल र आवाज खोज जस्ता सुविधाहरू उपलब्ध गराउँछ। '
                  'यसले तपाईंको पसलको सम्पूर्ण विवरण सजिलै ट्र्याक गर्न र विश्लेषण गर्न सहयोग गर्छ।\n\n'
                  'हामी नेपाली व्यवसायीहरूको डिजिटल यात्रामा साथ दिन प्रतिबद्ध छौं। '
                  'तपाईंको सुझाव र प्रतिक्रिया सधैं स्वागत छ!',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.copyright, size: 16, color: Colors.grey),
                  SizedBox(width: 3),
                  Text('2025 | Team Pasale', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                ],
              ),
            ],
          ),
        
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ठिक छ'),
          ),
        ],
      ),
    );
  }
  // --- End Cool Bottom Navbar ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'पसले',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFF1E88E5),
        elevation: 8,
        actions: [
          IconButton(
            icon: Icon(Icons.dashboard, color: Colors.white),
            tooltip: "ड्यासबोर्ड",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardPage(products: _products, sales: _sales),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.analytics, color: Colors.white),
            tooltip: "विश्लेषण",
            onPressed: () => _showAnalytics(),
          ),
        ],
      ),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Search and Filter Section
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'उत्पादन खोज्नुहोस्...',
                          prefixIcon: Icon(Icons.search, color: Color(0xFF1E88E5)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Color(0xFFF0F0F0),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        ),
                        onChanged: (value) => _filterProducts(),
                      ),
                      SizedBox(height: 12),
                      Container(
                        height: 45,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            final isSelected = _selectedCategory == category;
                            return Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(
                                  category,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Color(0xFF1E88E5),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategory = category;
                                    _filterProducts();
                                  });
                                },
                                backgroundColor: Colors.white,
                                selectedColor: Color(0xFF1E88E5),
                                elevation: isSelected ? 4 : 2,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Products List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                colors: [Colors.white, Color(0xFFFAFAFA)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: _getCategoryColor(product.category).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          _getCategoryIcon(product.category),
                                          color: _getCategoryColor(product.category),
                                          size: 24,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2C2C2C),
                                              ),
                                            ),
                                            Text(
                                              product.category,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: _getCategoryColor(product.category),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: product.quantity > 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'स्टक: ${product.quantity}',
                                          style: TextStyle(
                                            color: product.quantity > 0 ? Colors.green[700] : Colors.red[700],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'रू ${product.price.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E88E5),
                                            ),
                                          ),
                                          Text(
                                            'प्रति ${product.unit}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () => _buyProduct(product),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              elevation: 3,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.add_shopping_cart, size: 16),
                                                SizedBox(width: 4),
                                                Text('किनियो', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: product.quantity > 0 ? () => _sellProduct(product) : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              elevation: 3,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.sell, size: 16),
                                                SizedBox(width: 4),
                                                Text('बेचियो', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Voice search button (bottom left)
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: 72,
                height: 72,
                child: FloatingActionButton(
                  heroTag: 'voiceFab',
                  backgroundColor: _isListening ? Colors.red : Colors.blueGrey,
                  onPressed: _listenVoice,
                  child: Icon(
                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: Colors.white,
                    size: 40, // bigger icon
                  ),
                  tooltip: "आवाज खोज",
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(),
        backgroundColor: Color(0xFF1E88E5),
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('नयाँ उत्पादन थप्नुहोस्', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 8,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavbar(), // <-- Add cool bottom navbar here
    );
  }

  void _showAnalytics() {
    final totalProducts = _products.length;
    final totalStock = _products.fold(0, (sum, product) => sum + product.quantity);
    final totalValue = _products.fold(0.0, (sum, product) => sum + (product.quantity * product.price));
    final lowStockItems = _products.where((product) => product.quantity <= 2).length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('पसल विश्लेषण', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnalyticsRow('कुल उत्पादन:', totalProducts.toString()),
            _buildAnalyticsRow('कुल स्टक:', totalStock.toString()),
            _buildAnalyticsRow('स्टक मूल्य:', 'रू ${totalValue.toStringAsFixed(0)}'),
            _buildAnalyticsRow('कम स्टक चेतावनी:', lowStockItems.toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('बन्द गर्नुहोस्'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final unitController = TextEditingController();
    String selectedCategory = _categories[1]; // Default to first real category

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('नयाँ उत्पादन थप्नुहोस्'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'उत्पादन नाम'),
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(labelText: 'कोटि'),
                items: _categories
                  .where((cat) => cat != 'सबै')
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
                onChanged: (value) => setState(() => selectedCategory = value!),
              ),
              SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'मूल्य (रू)'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12),
              TextField(
                controller: unitController,
                decoration: InputDecoration(labelText: 'इकाई (केजी, वटा, लिटर)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('रद्द गर्नुहोस्'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty &&
                    unitController.text.isNotEmpty) {
                  final newProduct = Product(
                    name: nameController.text,
                    category: selectedCategory,
                    price: double.parse(priceController.text),
                    unit: unitController.text,
                    quantity: _rand(),
                  );
                  setState(() {
                    _products.add(newProduct);
                    _filterProducts();
                  });
                  Navigator.pop(context);
                  _showSnackBar('उत्पादन सफलतापूर्वक थपियो!', Colors.green);
                }
              },
              child: Text('थप्नुहोस्'),
            ),
          ],
        ),
      ),
    );
  }
}