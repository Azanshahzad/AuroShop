import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/database_service.dart';

class ProductProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<Product> _products = [];
  bool _isLoading = false;
  String _searchQuery = "";
  String _selectedCategory = "All";

  ProductProvider() {
    fetchProducts();
  }

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  // Filtered products list
  List<Product> get filteredProducts {
    return _products.where((product) {
      final matchesCategory = _selectedCategory == "All" || product.category == _selectedCategory;
      final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // Fetch from DB
  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _products = await _dbService.getProducts();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  // Set category filter
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Add Product (Admin)
  Future<bool> addProduct(Product product) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newProd = await _dbService.addProduct(product);
      _products.add(newProd);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update Product (Admin / Purchase)
  Future<bool> updateProduct(Product product) async {
    try {
      await _dbService.updateProduct(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  // Delete Product (Admin)
  Future<bool> deleteProduct(String productId) async {
    try {
      await _dbService.deleteProduct(productId);
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
