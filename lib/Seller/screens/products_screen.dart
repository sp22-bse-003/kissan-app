import 'package:flutter/material.dart';
import '../screens/product_form_screen.dart';
import '../widgets/custom_drawer.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../shared/user_data.dart';
import 'package:kissan/core/di/service_locator.dart';
import 'package:kissan/core/models/product.dart' as model;
import 'package:kissan/core/repositories/product_repository.dart';
import 'package:kissan/core/widgets/tts_icon_button.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductsScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'All';
  late final ProductRepository _repo;
  List<model.Product> _allProducts = [];
  List<model.Product> _filteredProducts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ServiceLocator.init(context);
      _repo = ServiceLocator.get<ProductRepository>();
      await _loadProducts();
      _filterProducts(_selectedFilter);
    });
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    final products = await _repo.fetchProducts(query: _searchText);
    setState(() {
      _allProducts = products;
      _applyCombinedFilters();
      _loading = false;
    });
  }

  void _applyCombinedFilters() {
    List<model.Product> filtered = _allProducts;

    if (_selectedFilter == 'In Stock') {
      filtered = filtered.where((p) => p.quantity > 0).toList();
    } else if (_selectedFilter == 'Out of Stock') {
      filtered = filtered.where((p) => p.quantity == 0).toList();
    }

    if (_searchText.trim().isNotEmpty) {
      final query = _searchText.trim().toLowerCase();
      filtered =
          filtered.where((p) => p.name.toLowerCase().contains(query)).toList();
    }

    setState(() {
      _filteredProducts = filtered;
    });

    // ignore: avoid_print
    print(
      'Filtered: ${_filteredProducts.length} products for "$_searchText" and "$_selectedFilter"',
    );
  }

  void _filterProducts(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyCombinedFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.eco, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text(
              'KISSAN',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C853), Color(0xFF00E676)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      drawer: CustomDrawer(imagePath: sharedProfileImagePath),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00C853), Color(0xFF00E676)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00C853).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ProductFormScreen(
                      onSave: (model.Product toSave) async {
                        if (toSave.id == null) {
                          final created = await _repo.addProduct(toSave);
                          setState(() {
                            _allProducts.add(created);
                            _applyCombinedFilters();
                          });
                        } else {
                          await _repo.updateProduct(toSave);
                          await _loadProducts();
                        }
                      },
                    ),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_circle, color: Colors.white),
          label: const Text(
            'Add Product',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section with gradient background
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF00E676)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.inventory_2,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Manage Products',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Modern Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                        _applyCombinedFilters();
                      });
                    },
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: '🔍 Search Products...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF00C853),
                        size: 24,
                      ),
                      suffixIcon:
                          _searchText.isNotEmpty
                              ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchText = '';
                                    _applyCombinedFilters();
                                  });
                                },
                              )
                              : IconButton(
                                icon: const Icon(
                                  Icons.mic,
                                  color: Color(0xFF00C853),
                                ),
                                onPressed: _listen,
                              ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter Chips Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                _buildFilterChip('All', Icons.apps),
                const SizedBox(width: 10),
                _buildFilterChip('In Stock', Icons.check_circle),
                const SizedBox(width: 10),
                _buildFilterChip('Out of Stock', Icons.remove_circle),
              ],
            ),
          ),
          Expanded(
            child:
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return _buildProductCard(product);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String text, IconData icon) {
    final isSelected = _selectedFilter == text;
    return Expanded(
      child: GestureDetector(
        onTap: () => _filterProducts(text),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            gradient:
                isSelected
                    ? const LinearGradient(
                      colors: [Color(0xFF00C853), Color(0xFF00E676)],
                    )
                    : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey[300]!,
              width: 1.5,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: const Color(0xFF00C853).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : const Color(0xFF00C853),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(model.Product product) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: Colors.grey[200],
                width: 120,
                height: 120,
                child:
                    (product.imageUrl != null &&
                            product.imageUrl!.isNotEmpty &&
                            product.imageUrl!.startsWith('http'))
                        ? Image.network(
                          product.imageUrl!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                        : (product.imageUrl != null &&
                            product.imageUrl!.isNotEmpty)
                        ? Image.asset(
                          product.imageUrl!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image,
                                color: Colors.grey,
                                size: 48,
                              ),
                            );
                          },
                        )
                        : Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.inventory_2,
                            color: Colors.grey,
                            size: 48,
                          ),
                        ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      TtsIconButton(text: product.name, iconSize: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs.${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.quantity > 0
                        ? 'In Stock: ${product.quantity}'
                        : 'Out of Stock',
                    style: TextStyle(
                      color: product.quantity > 0 ? Colors.green : Colors.red,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ProductFormScreen(
                                    product: product,
                                    onSave: (model.Product updated) async {
                                      if (updated.id == null) {
                                        final created = await _repo.addProduct(
                                          updated,
                                        );
                                        // Update local list with created ID
                                        setState(() {
                                          _allProducts.add(created);
                                          _applyCombinedFilters();
                                        });
                                      } else {
                                        await _repo.updateProduct(updated);
                                        await _loadProducts();
                                      }
                                    },
                                  ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 0,
                          ),
                          minimumSize: const Size(60, 30),
                        ),
                        child: const Text('Edit'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (product.id == null) return;
                          await _repo.deleteProduct(product.id!);
                          await _loadProducts();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 0,
                          ),
                          minimumSize: const Size(60, 30),
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _listen() async {
    var status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Microphone permission not granted"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('Speech status: $val');

          if (val == 'listening') {
            setState(() => _isListening = true);

            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (_) => const AlertDialog(
                    title: Text("🎙 Listening..."),
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text("Speak now"),
                      ],
                    ),
                  ),
            );
          }

          if (val == 'notListening') {
            setState(() => _isListening = false);

            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          }
        },
        onError: (val) {
          print('Speech error: $val');
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          setState(() => _isListening = false);
        },
      );

      if (available) {
        _speech.listen(
          onResult: (val) {
            setState(() {
              _searchController.text = val.recognizedWords;
              _searchText = val.recognizedWords;
            });
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ Microphone not available."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }
}
