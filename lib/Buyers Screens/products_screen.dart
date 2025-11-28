import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kissan/l10n/gen/app_localizations.dart';
import './product_details_screen.dart';
import 'package:kissan/core/di/service_locator.dart';
import 'package:kissan/core/models/product.dart' as model;
import 'package:kissan/core/repositories/product_repository.dart';
import 'package:kissan/core/services/tts_service.dart';
import 'package:kissan/core/services/cart_service.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  String selectedCategory = 'All';
  String searchQuery = '';
  String sortBy = 'newest'; // newest, price_low, price_high, name
  bool showScrollToTop = false;

  double minPrice = 0;
  double maxPrice = 10000;
  String selectedCity = 'All Cities';

  final List<String> cities = const [
    'All Cities',
    'Karachi',
    'Lahore',
    'Multan',
    'Faisalabad',
    'Sahiwal',
    'Islamabad',
    'Rawalpindi',
  ];

  final List<String> categories = const [
    'All',
    'Crops',
    'Seeds',
    'Pesticides',
    'Fertilizers',
    'Feeds',
    'Chemicals',
  ];

  late final ProductRepository _repo;
  late final CartService _cartService;
  List<model.Product> products = [];
  bool _loading = true;

  // Pagination
  int currentPage = 1;
  final int productsPerPage = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ServiceLocator.init(context);
      _repo = ServiceLocator.get<ProductRepository>();
      _cartService = ServiceLocator.get<CartService>();
      await _loadProducts();
    });
  }

  void _scrollListener() {
    if (_scrollController.offset > 200 && !showScrollToTop) {
      setState(() => showScrollToTop = true);
    } else if (_scrollController.offset <= 200 && showScrollToTop) {
      setState(() => showScrollToTop = false);
    }
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final list = await _repo.fetchProducts(
      category: selectedCategory == 'All' ? null : selectedCategory,
      city: selectedCity == 'All Cities' ? null : selectedCity,
    );
    if (!mounted) return;
    setState(() {
      products = list;
      _loading = false;
    });
  }

  List<model.Product> get allFilteredProducts {
    var filtered =
        products.where((product) {
          final price = product.price;
          final location = product.sellerLocation ?? '';
          final name = product.name.toLowerCase();
          final category = product.category.toLowerCase();

          // Search filter
          final query = searchQuery;
          final searchMatch =
              query.isEmpty ||
              name.contains(query.toLowerCase()) ||
              category.contains(query.toLowerCase());

          // Price filter
          final priceMatch = price >= minPrice && price <= maxPrice;

          // City filter
          final cityMatch =
              selectedCity == 'All Cities' ||
              location.toLowerCase().contains(selectedCity.toLowerCase());

          return searchMatch && priceMatch && cityMatch;
        }).toList();

    // Sort products
    switch (sortBy) {
      case 'price_low':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'newest':
      default:
        // Keep original order (newest first from backend)
        break;
    }

    return filtered;
  }

  // Get paginated products for current page
  List<model.Product> get filteredProducts {
    final allProducts = allFilteredProducts;
    final startIndex = (currentPage - 1) * productsPerPage;
    final endIndex = startIndex + productsPerPage;

    if (startIndex >= allProducts.length) {
      return [];
    }

    return allProducts.sublist(
      startIndex,
      endIndex > allProducts.length ? allProducts.length : endIndex,
    );
  }

  // Get total pages
  int get totalPages {
    final total = allFilteredProducts.length;
    return (total / productsPerPage).ceil();
  }

  // Navigate to next page
  void _nextPage() {
    if (currentPage < totalPages) {
      setState(() {
        currentPage++;
      });
      scrollToTop();
    }
  }

  // Navigate to previous page
  void _previousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
      scrollToTop();
    }
  }

  // Reset to page 1 when filters change
  void _resetPagination() {
    setState(() {
      currentPage = 1;
    });
  }

  void scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _addToCart(model.Product product) async {
    try {
      await _cartService.addProductToCart(
        productId: product.id ?? '',
        productName: product.name,
        productBrand: product.category, // Using category as brand
        productWeight: '1 unit', // Default weight
        productPrice: product.price,
        productImageUrl: product.imageUrl ?? '',
        sellerId: product.sellerId,
        quantity: 1,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('${product.name} added to cart')),
              ],
            ),
            backgroundColor: const Color(0xFF00C853),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to cart: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Safety check for web initialization
    if (!mounted) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _loadProducts,
              color: const Color(0xFF00C853),
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeBanner(),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildSearchBar(),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: _buildFilterButton()),
                                const SizedBox(width: 12),
                                _buildSortButton(),
                              ],
                            ),
                            if (_hasActiveFilters()) ...[
                              const SizedBox(height: 12),
                              _buildActiveFilters(),
                            ],
                            const SizedBox(height: 16),
                            _buildCategoryFilters(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _loading
                          ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                          : Column(
                            children: [
                              _buildProductGrid(),
                              if (allFilteredProducts.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                _buildPaginationControls(),
                                const SizedBox(height: 20),
                              ],
                            ],
                          ),
                    ],
                  ),
                ),
              ),
            ),
            // Floating scroll to top button
            if (showScrollToTop)
              Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: const Color(0xFF00C853),
                  onPressed: scrollToTop,
                  child: const Icon(Icons.arrow_upward, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _resetPagination();
                });
              },
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchHere,
                border: InputBorder.none,
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
          if (searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  searchQuery = '';
                });
              },
            ),
          const Icon(Icons.mic, color: Colors.grey, size: 24),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  // Welcome Banner
  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C853), Color(0xFF00E676)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.eco, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome to KISSAN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${products.length}+ Quality Products Available',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Sort Button
  Widget _buildSortButton() {
    return GestureDetector(
      onTap: _showSortOptions,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort, size: 20),
            const SizedBox(width: 4),
            Text(
              'Sort',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort By',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildSortOption('Newest First', 'newest'),
              _buildSortOption('Price: Low to High', 'price_low'),
              _buildSortOption('Price: High to Low', 'price_high'),
              _buildSortOption('Name A-Z', 'name'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String label, String value) {
    final isSelected = sortBy == value;
    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? const Color(0xFF00C853) : Colors.grey,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() {
          sortBy = value;
        });
        Navigator.pop(context);
      },
    );
  }

  // Active Filters Display
  bool _hasActiveFilters() {
    return searchQuery.isNotEmpty ||
        selectedCategory != 'All' ||
        minPrice > 0 ||
        maxPrice < 10000 ||
        selectedCity != 'All Cities';
  }

  Widget _buildActiveFilters() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (searchQuery.isNotEmpty)
          _buildFilterChip('Search: $searchQuery', () {
            _searchController.clear();
            setState(() => searchQuery = '');
          }),
        if (selectedCategory != 'All')
          _buildFilterChip(
            selectedCategory,
            () => setState(() => selectedCategory = 'All'),
          ),
        if (minPrice > 0 || maxPrice < 10000)
          _buildFilterChip(
            'Rs. ${minPrice.toInt()} - ${maxPrice.toInt()}',
            () => setState(() {
              minPrice = 0;
              maxPrice = 10000;
            }),
          ),
        if (selectedCity != 'All Cities')
          _buildFilterChip(
            selectedCity,
            () => setState(() => selectedCity = 'All Cities'),
          ),
      ],
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF00C853).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00C853).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF00C853),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 16, color: Color(0xFF00C853)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return GestureDetector(
      onTap: _showFilterDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.filter_alt, size: 20),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.filterBy,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    double tempMinPrice = minPrice;
    double tempMaxPrice = maxPrice;
    String tempSelectedCity = selectedCity;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Filter Products',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Price Range',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Rs. ${tempMinPrice.toInt()} - Rs. ${tempMaxPrice.toInt()}',
                      style: const TextStyle(color: Colors.green),
                    ),
                    RangeSlider(
                      values: RangeValues(tempMinPrice, tempMaxPrice),
                      min: 0,
                      max: 10000,
                      divisions: 20,
                      activeColor: Colors.green,
                      labels: RangeLabels(
                        'Rs. ${tempMinPrice.toInt()}',
                        'Rs. ${tempMaxPrice.toInt()}',
                      ),
                      onChanged: (RangeValues values) {
                        setDialogState(() {
                          tempMinPrice = values.start;
                          tempMaxPrice = values.end;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Select City',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: tempSelectedCity,
                          isExpanded: true,
                          items:
                              cities.map((String city) {
                                return DropdownMenuItem<String>(
                                  value: city,
                                  child: Text(city),
                                );
                              }).toList(),
                          onChanged: (String? newValue) {
                            setDialogState(() {
                              tempSelectedCity = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      tempMinPrice = 0;
                      tempMaxPrice = 10000;
                      tempSelectedCity = 'All Cities';
                    });
                  },
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      minPrice = tempMinPrice;
                      maxPrice = tempMaxPrice;
                      selectedCity = tempSelectedCity;
                      _resetPagination();
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            categories.map((category) {
              final isSelected = category == selectedCategory;
              return GestureDetector(
                onTap: () async {
                  setState(() {
                    selectedCategory = category;
                    _resetPagination();
                  });
                  await _loadProducts();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF00C853) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildProductGrid() {
    final productsToShow = filteredProducts;

    if (productsToShow.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'No products found matching your filters',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid based on screen width
        final screenWidth = constraints.maxWidth;
        final crossAxisCount =
            screenWidth < 600 ? 2 : (screenWidth < 900 ? 3 : 4);
        final aspectRatio = screenWidth < 600 ? 0.68 : 0.75;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: productsToShow.length,
          itemBuilder: (context, index) {
            final product = productsToShow[index];
            return _buildProductCard(product);
          },
        );
      },
    );
  }

  Widget _buildProductCard(model.Product product) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ProductDetailsScreen(
                      product: {
                        'id': product.id,
                        'name': product.name,
                        'price': product.price,
                        'imageUrl': product.imageUrl,
                        'weight': 50,
                        'category': product.category,
                        'description': product.description,
                        'sellerId':
                            product
                                .sellerId, // CRITICAL: Pass sellerId to details screen
                        'sellerName': product.sellerName ?? '',
                        'sellerPhone': product.sellerPhone ?? '',
                        'sellerLocation': product.sellerLocation ?? '',
                      },
                    ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full-width image section
                Expanded(
                  flex: 6,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: _buildProductImage(product),
                        ),
                      ),
                      // TTS Icon
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () async {
                            final text =
                                '${product.name}. Price: ${product.price.toStringAsFixed(0)} rupees. Category: ${product.category}';
                            await TtsService.instance.speak(text);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.volume_up,
                              size: 16,
                              color: Color(0xFF00C853),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Product details section
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Product name
                        Flexible(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 3),
                        // Seller name
                        if (product.sellerName != null &&
                            product.sellerName!.isNotEmpty)
                          Flexible(
                            child: Text(
                              product.sellerName!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        const Spacer(),
                        // Price and cart icon row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Price
                            Expanded(
                              child: Text(
                                'Rs. ${product.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Color(0xFF00C853),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Add to cart button
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF00C853),
                                    Color(0xFF00E676),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _addToCart(product),
                                  borderRadius: BorderRadius.circular(8),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.shopping_cart,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaginationControls() {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: currentPage > 1 ? _previousPage : null,
              icon: const Icon(Icons.arrow_back_ios, size: 16),
              label: const Text(
                'Previous',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    currentPage > 1
                        ? const Color(0xFF00C853)
                        : Colors.grey.shade300,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: currentPage > 1 ? 2 : 0,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Page Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF00E676)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$currentPage / $totalPages',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Next Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: currentPage < totalPages ? _nextPage : null,
              label: const Text(
                'Next',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    currentPage < totalPages
                        ? const Color(0xFF00C853)
                        : Colors.grey.shade300,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: currentPage < totalPages ? 2 : 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(model.Product product) {
    final imageUrl = product.imageUrl;

    // If no image URL, show default icon
    if (imageUrl == null || imageUrl.isEmpty) {
      return Center(
        child: Icon(Icons.grass, size: 50, color: Colors.green[300]),
      );
    }

    // If it's a Firebase Storage URL or any http URL
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading image: $error');
          return Center(
            child: Icon(Icons.grass, size: 50, color: Colors.green[300]),
          );
        },
      );
    }

    // If it's an asset path
    return Image.asset(
      imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Icon(Icons.grass, size: 50, color: Colors.green[300]),
        );
      },
    );
  }
}
