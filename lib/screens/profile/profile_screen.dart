import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/order.dart';
import '../../utils/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<OrderModel> _userOrders = [];
  bool _loadingOrders = false;

  @override
  void initState() {
    super.initState();
    _fetchUserOrders();
  }

  void _fetchUserOrders() async {
    setState(() {
      _loadingOrders = true;
    });
    final uid = Provider.of<AuthProvider>(context, listen: false).user?.id;
    if (uid != null) {
      final orders = await _dbService.getOrders(userId: uid);
      // Sort orders by date descending
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() {
        _userOrders = orders;
      });
    }
    setState(() {
      _loadingOrders = false;
    });
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
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Meta Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Text(
                      user?.name.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Guest User',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'guest@aura.com',
                          style: TextStyle(
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (user?.isAdmin ?? false) 
                                ? AppTheme.primaryColor.withOpacity(0.1) 
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            (user?.isAdmin ?? false) ? "Admin Account" : "Customer Account",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: (user?.isAdmin ?? false) 
                                  ? AppTheme.primaryColor 
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            
            // Order History Header
            const Text(
              "My Order History",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            
            _loadingOrders
                ? const Center(child: CircularProgressIndicator())
                : _userOrders.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Column(
                            children: [
                              const Icon(Icons.history_rounded, size: 48, color: Colors.grey),
                              const SizedBox(height: 12),
                              Text(
                                "No orders placed yet",
                                style: TextStyle(
                                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _userOrders.length,
                        itemBuilder: (context, index) {
                          final order = _userOrders[index];
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
                                        "ID: ${order.id}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(order.status).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        order.status,
                                        style: TextStyle(
                                          color: _getStatusColor(order.status),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),
                                Text(
                                  "Placed on: $formattedDate",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Items Count: ${order.items.fold(0, (sum, i) => sum + i.quantity)}",
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Shipping address: ${order.shippingAddress}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppTheme.darkTextSecondary.withOpacity(0.8) : AppTheme.lightTextSecondary.withOpacity(0.8),
                                  ),
                                ),
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Paid Amount",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "\$${order.totalAmount.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
