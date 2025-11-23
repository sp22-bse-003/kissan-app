# Quick Reference: Translation Service

## ✅ Problems Fixed

1. **UI Shift** - Drawer and layout no longer flip to RTL when selecting Urdu
2. **Firebase Data** - Categories, cities, and product data now translate dynamically

## 🚀 Quick Usage

### In Any Screen, Translate:

```dart
// Import
import 'package:kissan/core/services/translation_service.dart';

// Category (Fertilizers → کھاد)
TranslationService.translateCategory(product.category, context)

// City (Lahore → لاہور)
TranslationService.translateCity(product.sellerLocation, context)

// Price (Rs. 1500 → روپے 1500)
TranslationService.formatPrice(product.price, context)

// Product Name (Wheat Seeds → گندم بیج)
TranslationService.translateProductName(product.name, context)
```

## 📋 Where to Apply

Update these screens to use translation:

1. **Products Screen** (`lib/Buyers Screens/products_screen.dart`)
   - Line ~180: Category badges
   - Line ~420: Product cards

2. **Product Details** (`lib/Buyers Screens/product_details_screen.dart`)
   - All product info display

3. **Seller Products** (`lib/Seller/screens/products_screen.dart`)
   - Product listings

4. **Cart Screen** (`lib/Buyers Screens/cart_screen.dart`)
   - Product names and prices

5. **Orders Screens**
   - Buyer: `lib/Buyers Screens/orders_screen.dart`
   - Seller: `lib/Seller/screens/orders_screen.dart`

## 🧪 Test Steps

1. Run app: `flutter run -d chrome`
2. Go to Settings/Profile
3. Switch to Urdu (اُردُو)
4. Check:
   - ✅ Drawer stays on left
   - ✅ UI layout doesn't change
   - ✅ Text changes to Urdu
5. Switch back to English
6. Check everything returns to normal

## 💡 Pro Tips

- Always store data in English in Firebase
- Translate only when displaying to user
- Use reverse translation for queries: `categoryToEnglish()`
- Extend `translation_service.dart` to add more terms

## 📚 Full Documentation

See `TRANSLATION_GUIDE.md` for complete examples and troubleshooting.
