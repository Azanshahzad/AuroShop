import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';
import '../../models/order.dart';
import '../../utils/theme.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({Key? key}) : super(key: key);

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<OrderModel> _orders = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  void _fetchOrders() async {
    setState(() {
      _loading = true;
    });
    try {
      final list = await _dbService.getOrders();
      // Sort orders by date descending
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() {
        _orders = list;
      });
    } catch (_) {}
    setState(() {
      _loading = false;
    });
  }

  void _updateStatus(String orderId, String currentStatus) {
    String nextStatus;
    if (currentStatus == 'Pending') {
      nextStatus = 'Shipped';
    } else if (currentStatus == 'Shipped') {
      nextStatus = 'Delivered';
    } else {
      return; // Already delivered
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Update Status"),
        content: Text("Update order status from '$currentStatus' to '$nextStatus'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _dbService.updateOrderStatus(orderId, nextStatus);
              _fetchOrders();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Order updated to $nextStatus")),
                );
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return AppTheme.secondaryColor;
      case 'Shipped':
        return AppTheme.primaryColor;
      case 'Delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Orders"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text("No customer orders recorded yet"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    final formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "Order ID: ${order.id}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                              GestureDetector(
                                onTap: order.status != 'Delivered'
                                    ? () => _updateStatus(order.id, order.status)
                                    : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(order.status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _getStatusColor(order.status).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        order.status,
                                        style: TextStyle(
                                          color: _getStatusColor(order.status),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                      if (order.status != 'Delivered') ...[
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_circle_up_rounded,
                                          color: _getStatusColor(order.status),
                                          size: 14,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Text(
                            "Customer ID: ${order.userId}",
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Address: ${order.shippingAddress}",
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Date: $formattedDate",
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                            ),
                          ),
                          const Divider(height: 24),
                          
                          // Items summary breakdown
                          const Text("Items ordered:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 6),
                          ...order.items.map((i) => Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "${i.product.name} (x${i.quantity})",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    Text(
                                      "\$${i.totalPrice.toStringAsFixed(2)}",
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              )),
                          const Divider(height: 24),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total Sales Value", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                "\$${order.totalAmount.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
