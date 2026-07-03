import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../utils/constants.dart';

class DatabaseService {
  final FirebaseFirestore? _firestore;
  bool _useFirebase = false;

  DatabaseService()
      : _firestore = _isFirebaseInitialized() ? FirebaseFirestore.instance : null {
    _useFirebase = _firestore != null;
  }

  static bool _isFirebaseInitialized() {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  bool get isFirebaseEnabled => _useFirebase;

  // ==================== PRODUCTS ====================

  // Fetch all products
  Future<List<Product>> getProducts() async {
    if (_useFirebase) {
      final snapshot = await _firestore!.collection('products').get();
      if (snapshot.docs.isEmpty) {
        // Seed default products to Firestore if empty
        await seedProductsToFirestore();
        final refetched = await _firestore!.collection('products').get();
        return refetched.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList();
      }
      return snapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList();
    } else {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = prefs.getString(AppConstants.prefsProductsKey);
      if (productsJson == null) {
        // Initial seed to SharedPreferences
        final initialList = AppConstants.mockProducts;
        await prefs.setString(AppConstants.prefsProductsKey, jsonEncode(initialList));
        return initialList.map((p) => Product.fromMap(p, p['id'])).toList();
      }
      final List<dynamic> decoded = jsonDecode(productsJson);
      return decoded.map((p) => Product.fromMap(p as Map<String, dynamic>, p['id'] ?? '')).toList();
    }
  }

  // Seed default products to Firestore if empty
  Future<void> seedProductsToFirestore() async {
    if (!_useFirebase) return;
    final batch = _firestore!.batch();
    for (var prod in AppConstants.mockProducts) {
      final docRef = _firestore!.collection('products').doc();
      batch.set(docRef, {
        'name': prod['name'],
        'description': prod['description'],
        'price': prod['price'],
        'imageUrl': prod['imageUrl'],
        'category': prod['category'],
        'stock': prod['stock'],
        'rating': prod['rating'],
        'reviewsCount': prod['reviewsCount'],
      });
    }
    await batch.commit();
  }

  // Add Product (Admin)
  Future<Product> addProduct(Product product) async {
    if (_useFirebase) {
      final docRef = await _firestore!.collection('products').add(product.toMap());
      return product.copyWith(id: docRef.id);
    } else {
      final prefs = await SharedPreferences.getInstance();
      final products = await getProducts();
      final newId = 'prod_${DateTime.now().millisecondsSinceEpoch}';
      final newProduct = product.copyWith(id: newId);
      products.add(newProduct);
      
      final encoded = products.map((p) => {'id': p.id, ...p.toMap()}).toList();
      await prefs.setString(AppConstants.prefsProductsKey, jsonEncode(encoded));
      return newProduct;
    }
  }

  // Update Product (Admin / Purchase)
  Future<void> updateProduct(Product product) async {
    if (_useFirebase) {
      await _firestore!.collection('products').doc(product.id).update(product.toMap());
    } else {
      final prefs = await SharedPreferences.getInstance();
      final products = await getProducts();
      final index = products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        products[index] = product;
        final encoded = products.map((p) => {'id': p.id, ...p.toMap()}).toList();
        await prefs.setString(AppConstants.prefsProductsKey, jsonEncode(encoded));
      }
    }
  }

  // Delete Product (Admin)
  Future<void> deleteProduct(String productId) async {
    if (_useFirebase) {
      await _firestore!.collection('products').doc(productId).delete();
    } else {
      final prefs = await SharedPreferences.getInstance();
      final products = await getProducts();
      products.removeWhere((p) => p.id == productId);
      final encoded = products.map((p) => {'id': p.id, ...p.toMap()}).toList();
      await prefs.setString(AppConstants.prefsProductsKey, jsonEncode(encoded));
    }
  }

  // ==================== ORDERS ====================

  // Create Order
  Future<OrderModel> createOrder(OrderModel order) async {
    if (_useFirebase) {
      final docRef = await _firestore!.collection('orders').add(order.toMap());
      // Reduce product stock levels in Firestore
      for (var item in order.items) {
        final doc = await _firestore!.collection('products').doc(item.product.id).get();
        if (doc.exists) {
          final currentStock = doc.data()?['stock'] ?? 0;
          final newStock = (currentStock - item.quantity).clamp(0, 999999);
          await _firestore!.collection('products').doc(item.product.id).update({'stock': newStock});
        }
      }
      return order.copyWith(id: docRef.id);
    } else {
      final prefs = await SharedPreferences.getInstance();
      final newId = 'order_${DateTime.now().millisecondsSinceEpoch}';
      final newOrder = order.copyWith(id: newId);
      
      // Save order
      final orders = await getOrders();
      orders.add(newOrder);
      final encodedOrders = orders.map((o) => {'id': o.id, ...o.toMap()}).toList();
      await prefs.setString(AppConstants.prefsOrdersKey, jsonEncode(encodedOrders));

      // Update product stock levels locally
      final products = await getProducts();
      for (var item in order.items) {
        final index = products.indexWhere((p) => p.id == item.product.id);
        if (index != -1) {
          final newStock = (products[index].stock - item.quantity).clamp(0, 999999);
          products[index] = products[index].copyWith(stock: newStock);
        }
      }
      final encodedProducts = products.map((p) => {'id': p.id, ...p.toMap()}).toList();
      await prefs.setString(AppConstants.prefsProductsKey, jsonEncode(encodedProducts));

      return newOrder;
    }
  }

  // Get User Orders
  Future<List<OrderModel>> getOrders({String? userId}) async {
    if (_useFirebase) {
      Query query = _firestore!.collection('orders');
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } else {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString(AppConstants.prefsOrdersKey);
      if (ordersJson == null) return [];
      final List<dynamic> decoded = jsonDecode(ordersJson);
      final list = decoded.map((o) => OrderModel.fromMap(o as Map<String, dynamic>, o['id'] ?? '')).toList();
      if (userId != null) {
        return list.where((o) => o.userId == userId).toList();
      }
      return list;
    }
  }

  // Update Order Status (Admin)
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    if (_useFirebase) {
      await _firestore!.collection('orders').doc(orderId).update({'status': newStatus});
    } else {
      final prefs = await SharedPreferences.getInstance();
      final orders = await getOrders();
      final index = orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        orders[index] = orders[index].copyWith(status: newStatus);
        final encoded = orders.map((o) => {'id': o.id, ...o.toMap()}).toList();
        await prefs.setString(AppConstants.prefsOrdersKey, jsonEncode(encoded));
      }
    }
  }
}
