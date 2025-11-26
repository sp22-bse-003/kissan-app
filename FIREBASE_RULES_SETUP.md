# Firebase Storage Rules Setup

## Current Status

Your **Firestore rules** are already set correctly! ✅

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

---

## ⚠️ Missing: Firebase Storage Rules

To load product images from Firebase Storage, you need to add Storage rules separately.

### Step-by-Step Setup:

1. **Go to Firebase Console**
   - Open https://console.firebase.google.com/
   - Select project: `kissan-cae04`

2. **Navigate to Storage Rules**
   - Click **Storage** in the left menu
   - Click **Rules** tab at the top
   - You should see an editor

3. **Add These Rules:**

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow anyone to read all files
    // Only authenticated users can write
    match /{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

4. **Click "Publish"** button

---

## Better Production Rules (Recommended)

For better security, use these rules instead:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Product images folder
    match /products/{imageId} {
      allow read: if true;  // Anyone can view product images
      allow write: if request.auth != null;  // Only authenticated users
      allow delete: if request.auth != null;  // Only authenticated users
    }
    
    // Profile images folder
    match /profiles/{userId}/{imageId} {
      allow read: if true;  // Anyone can view profiles
      // Only the user can modify their own profile image
      allow write: if request.auth != null && request.auth.uid == userId;
      allow delete: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 🧪 Test After Setup

1. **Add a product with image** (Seller app)
2. **Check Firebase Storage Console**
   - Go to Storage section
   - You should see `products/` folder
   - Images should be there

3. **View products** (Buyer app)
   - Products screen should show images
   - Images load with spinner
   - ✅ Images display correctly!

---

## 🐛 Troubleshooting

### If images still don't show:

**Check 1: Storage Rules Published?**
- Firebase Console → Storage → Rules
- Make sure rules are published (green checkmark)

**Check 2: Storage Enabled?**
- Firebase Console → Storage
- If you see "Get Started", click it to enable Storage

**Check 3: Correct Bucket?**
- Your bucket should be: `kissan-cae04.appspot.com`
- Check in Firebase Console → Storage

**Check 4: Test Upload**
- Add a new product with image
- Check console logs for errors
- Verify upload completes successfully

---

## Summary

✅ **Firestore Rules**: Already correct  
⚠️ **Storage Rules**: Need to add (follow steps above)  
📱 **App Code**: Already fixed to load Firebase images  

**Next step: Add Storage rules in Firebase Console, then test image upload!** 🚀
