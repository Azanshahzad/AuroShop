import 'cart_item.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final String shippingAddress;
  final String status; // 'Pending', 'Shipped', 'Delivered'
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.shippingAddress,
    required this.status,
    required this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      shippingAddress: map['shippingAddress'] ?? '',
      status: map['status'] ?? 'Pending',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'shippingAddress': shippingAddress,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    double? totalAmount,
    String? shippingAddress,
    String? status,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
