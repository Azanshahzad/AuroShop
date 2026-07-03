import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../utils/constants.dart';

class WishlistProvider with ChangeNotifier {
  final List<Product> _items = [];

  WishlistProvider() {
    _loadWishlist();
  }

  List<Product> get items => [..._items];

  bool isFavorite(String productId) {
    return _items.any((p) => p.id == productId);
  }

  // Load from local storage
  Future<void> _loadWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = prefs.getString(AppConstants.prefsWishlistKey);
      if (wishlistJson != null) {
        final List<dynamic> decoded = jsonDecode(wishlistJson);
        for (var item in decoded) {
          _items.add(Product.fromMap(item as Map<String, dynamic>, item['id'] ?? ''));
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  // Save to local storage
  Future<void> _saveWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = _items.map((item) => {'id': item.id, ...item.toMap()}).toList();
      await prefs.setString(AppConstants.prefsWishlistKey, jsonEncode(encoded));
    } catch (_) {}
  }

  // Toggle favorite
  void toggleFavorite(Product product) {
    final index = _items.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _items.removeAt(index);
    } else {
      _items.add(product);
    }
    _saveWishlist();
    notifyListeners();
  }
}
