import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static AuthService get instance => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Test phone numbers for development (add these in Firebase Console too)
  static const Map<String, String> testPhoneNumbers = {
    '+923001234567': '123456',
    '+923009876543': '654321',
  };

  // Check if phone number is a test number
  bool isTestPhoneNumber(String phoneNumber) {
    return testPhoneNumbers.containsKey(phoneNumber);
  }

  // Get test OTP for a test phone number
  String? getTestOTP(String phoneNumber) {
    return testPhoneNumbers[phoneNumber];
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with phone number
  Future<void> signInWithPhone({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(String error) verificationFailed,
    required Function(PhoneAuthCredential credential) verificationCompleted,
  }) async {
    try {
      debugPrint('📱 Attempting to send OTP to: $phoneNumber');

      // Check if this is a test phone number
      if (isTestPhoneNumber(phoneNumber)) {
        debugPrint(
          '🧪 Using test phone number - OTP: ${getTestOTP(phoneNumber)}',
        );
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          debugPrint('✅ Auto-verification completed');
          verificationCompleted(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('❌ Verification failed: ${e.code} - ${e.message}');
          if (e.code == 'invalid-phone-number') {
            verificationFailed(
              'Invalid phone number format. Use +92XXXXXXXXXX',
            );
          } else if (e.code == 'too-many-requests') {
            verificationFailed(
              'Too many requests. Please try again later or use a test number.',
            );
          } else if (e.code == 'operation-not-allowed') {
            verificationFailed(
              'Phone authentication is not enabled. Please contact support.',
            );
          } else {
            verificationFailed(_handleAuthException(e));
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint(
            '✅ OTP sent successfully! Verification ID: ${verificationId.substring(0, 10)}...',
          );
          if (isTestPhoneNumber(phoneNumber)) {
            debugPrint(
              '🧪 Test number detected. Use OTP: ${getTestOTP(phoneNumber)}',
            );
          } else {
            debugPrint(
              '📨 SMS sent to $phoneNumber. Please check your messages.',
            );
          }
          codeSent(verificationId, resendToken);
        },
        timeout: const Duration(seconds: 60),
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint(
            '⏱️ Auto retrieval timeout for: ${verificationId.substring(0, 10)}...',
          );
        },
      );
    } catch (e) {
      debugPrint('❌ Phone sign in error: $e');
      throw 'Failed to send verification code. Please check your internet connection and try again.';
    }
  }

  // Verify phone OTP
  Future<UserCredential?> verifyPhoneOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      debugPrint('✅ Phone verified: ${userCredential.user?.phoneNumber}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ OTP verification error: ${e.code}');
      throw _handleAuthException(e);
    }
  }

  // Sign up with phone and password
  Future<UserCredential?> signUpWithPhonePassword({
    required String phoneNumber,
    required String password,
    required String name,
    String role = 'buyer',
  }) async {
    try {
      // For phone authentication, we'll use the phone as email format
      final email =
          '${phoneNumber.replaceAll('+', '').replaceAll(' ', '')}@kissan.app';

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name and phone number
      await credential.user?.updateDisplayName(name);
      await credential.user?.updatePhoneNumber(
        PhoneAuthProvider.credential(
          verificationId: '', // Will be set during phone verification
          smsCode: '',
        ),
      );

      // Create user document in Firestore
      await _createUserDocument(
        uid: credential.user!.uid,
        phone: phoneNumber,
        name: name,
        role: role,
      );

      debugPrint('✅ User registered: ${credential.user?.phoneNumber}');
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Sign up error: ${e.code}');
      throw _handleAuthException(e);
    }
  }

  // Sign in with phone and password
  Future<UserCredential?> signInWithPhonePassword({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      // Convert phone to email format
      final email =
          '${phoneNumber.replaceAll('+', '').replaceAll(' ', '')}@kissan.app';

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('✅ User signed in: ${credential.user?.phoneNumber}');
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Sign in error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ Unexpected sign in error: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument({
    required String uid,
    required String phone,
    required String name,
    required String role,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'phone': phone,
        'name': name,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ User document created for: $uid');
    } catch (e) {
      debugPrint('❌ Error creating user document: $e');
      throw 'Failed to create user profile. Please try again.';
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      debugPrint('❌ Error getting user data: $e');
      return null;
    }
  }

  // Update user data
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ User data updated for: $uid');
    } catch (e) {
      debugPrint('❌ Error updating user data: $e');
      throw 'Failed to update profile. Please try again.';
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
      debugPrint('✅ Password updated');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Password update error: ${e.code}');
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint('✅ User signed out');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      throw 'Failed to sign out. Please try again.';
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user document
        await _firestore.collection('users').doc(user.uid).delete();
        // Delete auth account
        await user.delete();
        debugPrint('✅ Account deleted');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Delete account error: ${e.code}');
      throw _handleAuthException(e);
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this phone number.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This phone number is already registered.';
      case 'invalid-email':
        return 'Invalid phone number.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'invalid-verification-code':
        return 'Invalid verification code. Please try again.';
      case 'invalid-verification-id':
        return 'Verification session expired. Please request a new code.';
      case 'requires-recent-login':
        return 'Please sign in again to perform this action.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}
