# Translation Service Usage Guide

## Overview
The `TranslationService` provides runtime translation for dynamic data (like Firebase data) without shifting the UI layout.

## Key Features
1. **No UI Shift**: Layout stays LTR (left-to-right) regardless of language
2. **Runtime Translation**: Text is translated on-the-fly based on selected language
3. **Firebase Data Translation**: Categories, cities, and product data are translated automatically

## How to Use

### 1. Import the Service
```dart
import 'package:kissan/core/services/translation_service.dart';
```

### 2. Translate Categories
```dart
// In your widget build method:
String category = product.category; // e.g., "Fertilizers" from Firebase
String translatedCategory = TranslationService.translateCategory(category, context);
// If language is Urdu: displays "کھاد"
// If language is English: displays "Fertilizers"

// Example in a Text widget:
Text(TranslationService.translateCategory(product.category, context))
```

### 3. Translate Cities
```dart
String city = product.sellerLocation; // e.g., "Lahore" from Firebase
String translatedCity = TranslationService.translateCity(city, context);
// If language is Urdu: displays "لاہور"
// If language is English: displays "Lahore"

// Example:
Text(TranslationService.translateCity(product.sellerLocation ?? '', context))
```

### 4. Translate Product Names
```dart
String productName = product.name; // e.g., "Wheat Seeds Premium"
String translated = TranslationService.translateProductName(productName, context);
// If language is Urdu: displays "گندم بیج Premium"

// Example:
Text(TranslationService.translateProductName(product.name, context))
```

### 5. Format Prices
```dart
double price = product.price; // e.g., 1500.0
String formattedPrice = TranslationService.formatPrice(price, context);
// If language is Urdu: displays "روپے 1500"
// If language is English: displays "Rs. 1500"

// Example:
Text(TranslationService.formatPrice(product.price, context))
```

### 6. Get Translated Lists
```dart
// Get all categories in current language for dropdown/filters
List<String> categories = TranslationService.getCategories(context);

// Get all cities in current language
List<String> cities = TranslationService.getCities(context);
```

### 7. Reverse Translation (for Firebase Queries)
When user selects a category in Urdu, convert it back to English for Firebase queries:

```dart
String selectedCategory = "کھاد"; // User selected in Urdu
String englishCategory = TranslationService.categoryToEnglish(selectedCategory);
// Returns: "Fertilizers"

// Use in Firebase query:
final products = await _repo.fetchProducts(category: englishCategory);
```

## Example: Update Product Card

### Before (Static):
```dart
Text(product.category)  // Shows "Fertilizers" always
```

### After (Dynamic Translation):
```dart
Text(TranslationService.translateCategory(product.category, context))
// Shows "Fertilizers" in English
// Shows "کھاد" in Urdu
```

## Example: Complete Product Card Implementation

```dart
class ProductCard extends StatelessWidget {
  final Product product;
  
  const ProductCard({required this.product});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Product Name - translated
          Text(
            TranslationService.translateProductName(product.name, context),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          
          // Category - translated
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              TranslationService.translateCategory(product.category, context),
              style: TextStyle(color: Colors.green),
            ),
          ),
          
          // Price - translated
          Text(
            TranslationService.formatPrice(product.price, context),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          
          // Location - translated
          Row(
            children: [
              Icon(Icons.location_on),
              Text(TranslationService.translateCity(
                product.sellerLocation ?? '',
                context,
              )),
            ],
          ),
        ],
      ),
    );
  }
}
```

## Example: Filter Implementation

```dart
class ProductFilter extends StatefulWidget {
  @override
  _ProductFilterState createState() => _ProductFilterState();
}

class _ProductFilterState extends State<ProductFilter> {
  String? selectedCategory;
  
  @override
  Widget build(BuildContext context) {
    // Get categories in current language
    final categories = TranslationService.getCategories(context);
    
    return DropdownButton<String>(
      value: selectedCategory,
      items: categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedCategory = value;
        });
        
        // Convert to English for Firebase query
        final englishCategory = TranslationService.categoryToEnglish(value!);
        
        // Fetch products with English category
        _loadProducts(englishCategory);
      },
    );
  }
  
  void _loadProducts(String category) {
    // Firebase query with English category
    _repo.fetchProducts(category: category);
  }
}
```

## Where to Apply

### 1. Products Screen
- `lib/Buyers Screens/products_screen.dart`
- Update: category badges, city names, product names, prices

### 2. Product Details Screen
- `lib/Buyers Screens/product_details_screen.dart`
- Update: all product information display

### 3. Seller Products Screen
- `lib/Seller/screens/products_screen.dart`
- Update: product listings

### 4. Product Form Screen
- `lib/Seller/screens/product_form_screen.dart`
- Update: dropdowns for categories and cities

### 5. Cart Screen
- `lib/Buyers Screens/cart_screen.dart`
- Update: product names, prices

### 6. Orders Screen
- `lib/Buyers Screens/orders_screen.dart`
- `lib/Seller/screens/orders_screen.dart`
- Update: product information in orders

## Important Notes

1. **Firebase Data Stays in English**: Always store data in English in Firebase for consistency
2. **Translation Happens at Display**: Translate only when showing to user
3. **Queries Use English**: Always convert user selections back to English for Firebase queries
4. **UI Never Shifts**: Layout remains LTR, only text content changes
5. **Extend as Needed**: Add more translations to the service as you add new features

## Testing

1. Start app in English - verify all UI is normal
2. Switch to Urdu - verify:
   - UI layout doesn't shift
   - Drawer stays on left
   - Categories show in Urdu
   - Cities show in Urdu
   - Prices show in Urdu format
   - Product names are translated
3. Switch back to English - verify everything returns to English
4. Test filters - verify they work in both languages

## Common Issues & Solutions

### Issue: UI still shifts when switching to Urdu
**Solution**: Make sure you've added the `builder` with `Directionality` in both `main.dart` and `Seller/main 1.dart`

### Issue: Some text is not translating
**Solution**: 
1. Check if you're using the translation service for that text
2. Add the translation to the appropriate map in `translation_service.dart`
3. Make sure you're passing `context` to the translation method

### Issue: Filters not working after translation
**Solution**: Always use `categoryToEnglish()` or `cityToEnglish()` before Firebase queries

## Future Enhancements

You can extend the translation service by:
1. Adding more product terms to `translateProductName()`
2. Adding more cities to `_cityTranslations`
3. Adding status translations (pending, approved, etc.)
4. Adding measurement unit translations (kg, bag, etc.)
5. Implementing Google Translate API for full description translation
