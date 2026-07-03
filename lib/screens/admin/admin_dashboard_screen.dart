import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../services/database_service.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../utils/theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<OrderModel> _allOrders = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  void _fetchStats() async {
    setState(() {
      _loading = true;
    });
    try {
      final orders = await _dbService.getOrders();
      setState(() {
        _allOrders = orders;
      });
    } catch (_) {}
    setState(() {
      _loading = false;
    });
  }

  double get _totalRevenue => _allOrders.fold(0.0, (sum, order) => sum + order.totalAmount);
  int get _pendingCount => _allOrders.where((o) => o.status == 'Pending').length;
  int get _deliveredCount => _allOrders.where((o) => o.status == 'Delivered').length;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productProvider = Provider.of<ProductProvider>(context);
    final totalProducts = productProvider.products.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              _fetchStats();
              productProvider.fetchProducts();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Store Statistics",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  
                  // Statistics Cards Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4,
                    children: [
                      _buildStatCard(
                        title: "Total Revenue",
                        value: "\$${_totalRevenue.toStringAsFixed(2)}",
                        icon: Icons.monetization_on_rounded,
                        color: Colors.green,
                        isDark: isDark,
                      ),
                      _buildStatCard(
                        title: "Total Orders",
                        value: _allOrders.length.toString(),
                        icon: Icons.shopping_bag_rounded,
                        color: AppTheme.primaryColor,
                        isDark: isDark,
                      ),
                      _buildStatCard(
                        title: "Catalog Products",
                        value: totalProducts.toString(),
                        icon: Icons.inventory_2_rounded,
                        color: AppTheme.secondaryColor,
                        isDark: isDark,
                      ),
                      _buildStatCard(
                        title: "Pending Dispatch",
                        value: _pendingCount.toString(),
                        icon: Icons.pending_actions_rounded,
                        color: Colors.orange,
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Custom visual Sales Chart
                  const Text(
                    "Sales Activity Overview",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  _buildSalesBarChart(isDark),
                  const SizedBox(height: 32),

                  // Actions Section
                  const Text(
                    "Management Actions",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  
                  // Manage Products button
                  _buildActionButton(
                    title: "Manage Catalog Products",
                    subtitle: "Add, Edit, or Delete store items",
                    icon: Icons.edit_note_rounded,
                    color: AppTheme.primaryColor,
                    isDark: isDark,
                    onTap: () {
                      Navigator.pushNamed(context, '/admin-products');
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Manage Orders button
                  _buildActionButton(
                    title: "Manage Customer Orders",
                    subtitle: "View history & dispatch package states",
                    icon: Icons.local_shipping_outlined,
                    color: AppTheme.secondaryColor,
                    isDark: isDark,
                    onTap: () {
                      Navigator.pushNamed(context, '/admin-orders').then((_) => _fetchStats());
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
              ),
              Icon(icon, color: color, size: 22),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesBarChart(bool isDark) {
    // Generate simple custom bar widgets showing sales stats Mock data
    final barValues = [30.0, 45.0, 75.0, 20.0, 90.0, 50.0, 60.0];
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Weekly Revenue", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text("Last 7 Days", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(barValues.length, (index) {
                final val = barValues[index];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 14,
                      height: val,
                      decoration: BoxDecoration(
                        color: index == 4 ? AppTheme.primaryColor : AppTheme.primaryColor.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      labels[index],
                      style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
