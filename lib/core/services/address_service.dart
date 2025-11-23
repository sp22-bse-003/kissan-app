import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:kissan/core/models/delivery_address.dart';

/// Service for managing delivery addresses
class AddressService {
  static final AddressService _instance = AddressService._internal();
  factory AddressService() => _instance;
  AddressService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get singleton instance
  static AddressService get instance => _instance;

  /// Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  /// Get addresses collection reference
  CollectionReference get _addressesCollection =>
      _firestore.collection('delivery_addresses');

  /// Get all addresses for current user
  Stream<List<DeliveryAddress>> getUserAddresses() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _addressesCollection
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('isDefault', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => DeliveryAddress.fromFirestore(doc))
              .toList();
        });
  }

  /// Get default address
  Future<DeliveryAddress?> getDefaultAddress() async {
    if (_currentUserId == null) return null;

    try {
      final snapshot =
          await _addressesCollection
              .where('userId', isEqualTo: _currentUserId)
              .where('isDefault', isEqualTo: true)
              .limit(1)
              .get();

      if (snapshot.docs.isEmpty) return null;
      return DeliveryAddress.fromFirestore(snapshot.docs.first);
    } catch (e) {
      debugPrint('❌ Error getting default address: $e');
      return null;
    }
  }

  /// Add new address
  Future<String?> addAddress(DeliveryAddress address) async {
    if (_currentUserId == null) {
      debugPrint('❌ No user logged in');
      return null;
    }

    try {
      // If setting as default, unset other defaults first
      if (address.isDefault) {
        await _unsetAllDefaults();
      }

      final docRef = await _addressesCollection.add(address.toFirestore());
      debugPrint('✅ Address added: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error adding address: $e');
      return null;
    }
  }

  /// Update existing address
  Future<bool> updateAddress(DeliveryAddress address) async {
    if (_currentUserId == null) return false;

    try {
      // If setting as default, unset other defaults first
      if (address.isDefault) {
        await _unsetAllDefaults();
      }

      await _addressesCollection.doc(address.id).update(address.toFirestore());
      debugPrint('✅ Address updated: ${address.id}');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating address: $e');
      return false;
    }
  }

  /// Delete address
  Future<bool> deleteAddress(String addressId) async {
    if (_currentUserId == null) return false;

    try {
      await _addressesCollection.doc(addressId).delete();
      debugPrint('✅ Address deleted: $addressId');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting address: $e');
      return false;
    }
  }

  /// Set address as default
  Future<bool> setDefaultAddress(String addressId) async {
    if (_currentUserId == null) return false;

    try {
      // Unset all defaults first
      await _unsetAllDefaults();

      // Set new default
      await _addressesCollection.doc(addressId).update({'isDefault': true});
      debugPrint('✅ Default address set: $addressId');
      return true;
    } catch (e) {
      debugPrint('❌ Error setting default address: $e');
      return false;
    }
  }

  /// Unset all default addresses for current user
  Future<void> _unsetAllDefaults() async {
    if (_currentUserId == null) return;

    try {
      final snapshot =
          await _addressesCollection
              .where('userId', isEqualTo: _currentUserId)
              .where('isDefault', isEqualTo: true)
              .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('❌ Error unsetting defaults: $e');
    }
  }

  /// Get address by ID
  Future<DeliveryAddress?> getAddressById(String addressId) async {
    try {
      final doc = await _addressesCollection.doc(addressId).get();
      if (!doc.exists) return null;
      return DeliveryAddress.fromFirestore(doc);
    } catch (e) {
      debugPrint('❌ Error getting address: $e');
      return null;
    }
  }
}
