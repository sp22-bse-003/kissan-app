import 'package:flutter/material.dart';
import 'package:kissan/l10n/gen/app_localizations.dart';
import './product_details_screen.dart';
import 'package:kissan/core/di/service_locator.dart';
import 'package:kissan/core/models/product.dart' as model;
import 'package:kissan/core/repositories/product_repository.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ScrollController _scrollController = ScrollController();

  String selectedCategory = 'Fertilizers';

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
    'Crops',
    'Seeds',
    'Pesticides',
    'Fertilizers',
    'Feeds',
    'Chemicals',
  ];

  late final ProductRepository _repo;
  List<model.Product> products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ServiceLocator.init(context);
      _repo = ServiceLocator.get<ProductRepository>();
      await _loadProducts();
    });
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    final list = await _repo.fetchProducts(
      category: selectedCategory,
      city: selectedCity,
    );
    setState(() {
      products = list;
      _loading = false;
    });
  }

  List<model.Product> get filteredProducts {
    return products.where((product) {
      final price = product.price;
      final location = product.sellerLocation ?? '';

      final priceMatch = price >= minPrice && price <= maxPrice;
      final cityMatch =
          selectedCity == 'All Cities' ||
          location.toLowerCase().contains(selectedCity.toLowerCase());

      return priceMatch && cityMatch;
    }).toList();
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.all(13.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 16),
                      _buildFilterButton(),
                      const SizedBox(height: 16),
                      _buildCategoryFilters(),
                      const SizedBox(height: 30),
                      _loading
                          ? const Center(child: CircularProgressIndicator())
                          : _buildProductGrid(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchHere,
                border: InputBorder.none,
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
          const Icon(Icons.mic, color: Colors.black, size: 27),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return GestureDetector(
      onTap: _showFilterDialog,
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Icon(Icons.filter_alt, color: Colors.black),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context)!.filterBy,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
        ],
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
                  });
                  await _loadProducts();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF32CD32) : Colors.white,
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

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: productsToShow.length,
      itemBuilder: (context, index) {
        final product = productsToShow[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(model.Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProductDetailsScreen(
                  product: {
                    'name': product.name,
                    'price': product.price,
                    'image': product.imageUrl ?? 'assets/images/dap.webp',
                    'weight': 50,
                    'description': product.description,
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
          border: Border.all(color: Colors.grey.shade500),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.volume_up,
                  size: 20,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child:
                    (product.imageUrl != null &&
                            product.imageUrl!.startsWith('http'))
                        ? Image.network(product.imageUrl!, fit: BoxFit.contain)
                        : Image.asset(
                          product.imageUrl ?? 'assets/images/dap.webp',
                          fit: BoxFit.contain,
                        ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 3),
              child: Text(
                'Rs. ${product.price.toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.green, fontSize: 14),
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
