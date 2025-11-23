# Firebase Storage Integration

## Overview
This document describes the Firebase Storage integration for image uploads in the Kissan app.

## Features Implemented

### 1. Image Upload Service (`lib/core/services/image_upload_service.dart`)
A centralized service for handling all image uploads to Firebase Storage.

**Key Features:**
- Upload images with progress tracking
- Generate unique filenames using timestamps
- Automatic path organization (products/, profiles/)
- Error handling and logging
- Image deletion support

**Methods:**
- `uploadImage()` - Generic image upload
- `uploadProductImage()` - Upload product images
- `uploadProfileImage()` - Upload profile pictures
- `deleteImage()` - Delete images from storage

### 2. Product Image Upload
**Location:** `lib/Seller/screens/product_form_screen.dart`

**Features:**
- Upload images when creating/editing products
- Real-time upload progress indicator
- Automatic cleanup of old images when updating
- Support for both camera and gallery
- Network image display with loading states
- Fallback to local assets if needed

**User Flow:**
1. Seller selects image (camera/gallery)
2. Image displays locally (preview)
3. On save, image uploads to Firebase Storage with progress bar
4. Download URL saved to Firestore with product data
5. Old image automatically deleted (if updating)

### 3. Profile Picture Upload
**Locations:**
- Buyer: `lib/Buyers Screens/profile_screen.dart`
- Seller: `lib/Seller/screens/profile_screen.dart`

**Features:**
- Upload profile pictures to Firebase Storage
- Unique filenames per user
- Loading indicators during upload
- Success/error notifications
- Display network images with loading states
- Fallback to default avatar

**User Flow:**
1. User taps profile picture
2. Selects camera or gallery
3. Image uploads with loading indicator
4. Success message shown
5. Profile picture updates across app

## Firebase Storage Structure

```
kissan-cae04.firebasestorage.app/
├── products/
│   ├── product_123_1729524000000.jpg
│   ├── product_456_1729524100000.png
│   └── ...
└── profiles/
    ├── buyer_789_1729524200000.jpg
    ├── seller_101_1729524300000.png
    └── ...
```

## Usage Examples

### Uploading a Product Image

```dart
final imageUploadService = ServiceLocator.get<ImageUploadService>();

// Upload with progress tracking
final downloadUrl = await imageUploadService.uploadProductImage(
  imageFile,
  productId,
  onProgress: (progress) {
    print('Upload progress: ${(progress * 100).toStringAsFixed(0)}%');
  },
);

// Save URL to product
final product = Product(
  id: productId,
  name: 'Fertilizer',
  imageUrl: downloadUrl,
  // ... other fields
);
```

### Uploading a Profile Picture

```dart
final imageUploadService = ServiceLocator.get<ImageUploadService>();
final userId = FirebaseAuth.instance.currentUser?.uid ?? 'temp_id';

final downloadUrl = await imageUploadService.uploadProfileImage(
  imageFile,
  userId,
);
```

### Deleting an Image

```dart
final imageUploadService = ServiceLocator.get<ImageUploadService>();

await imageUploadService.deleteProductImage(oldImageUrl);
```

## Image Display

### Network Images (Firebase Storage)

```dart
Image.network(
  imageUrl,
  fit: BoxFit.cover,
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return CircularProgressIndicator(
      value: loadingProgress.expectedTotalBytes != null
          ? loadingProgress.cumulativeBytesLoaded /
              loadingProgress.expectedTotalBytes!
          : null,
    );
  },
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.error);
  },
)
```

### Hybrid Display (Network or Local)

```dart
imageUrl.startsWith('http')
    ? Image.network(imageUrl)
    : Image.asset(imageUrl)
```

## Security Rules (To Be Implemented)

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Product images - anyone can read, only authenticated sellers can write
    match /products/{imageId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Profile pictures - anyone can read, only owner can write
    match /profiles/{userId}_{timestamp}.{ext} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Error Handling

All image upload methods include:
- Try-catch blocks for network/storage errors
- User-friendly error messages via SnackBar
- Fallback to default images on load failures
- Automatic retry logic (via Firebase SDK)

## Performance Optimizations

1. **Lazy Loading**: Images load on-demand with loading indicators
2. **Caching**: Network images cached by Flutter automatically
3. **Compression**: Consider adding image compression before upload (future enhancement)
4. **Thumbnails**: Generate thumbnails for large images (future enhancement)

## Testing Checklist

- [ ] Upload product image (camera)
- [ ] Upload product image (gallery)
- [ ] Edit product and change image
- [ ] Delete product with image
- [ ] Upload buyer profile picture
- [ ] Upload seller profile picture
- [ ] Test with slow network
- [ ] Test with no network (offline)
- [ ] Verify old images are deleted
- [ ] Check Firebase Storage console

## Dependencies

```yaml
firebase_storage: ^12.3.4
firebase_core: ^3.7.0
firebase_auth: ^5.3.0
image_picker: ^1.1.2
```

## Next Steps

1. Implement image compression before upload
2. Add thumbnail generation for faster loading
3. Implement Storage security rules
4. Add image cropping functionality
5. Support multiple images per product
6. Add image optimization (WebP conversion)
7. Implement CDN caching

## Troubleshooting

### Image Not Uploading
- Check internet connection
- Verify Firebase project configuration
- Ensure Storage is enabled in Firebase Console
- Check Storage quota/limits

### Image Not Displaying
- Verify download URL format (should start with https://)
- Check network connectivity
- Verify image exists in Storage console
- Check error messages in console logs

### Permission Denied
- Ensure user is authenticated
- Check Storage security rules
- Verify Firebase initialization

## References
- [Firebase Storage Documentation](https://firebase.google.com/docs/storage)
- [FlutterFire Storage](https://firebase.flutter.dev/docs/storage/overview)
- [Image Picker Package](https://pub.dev/packages/image_picker)
