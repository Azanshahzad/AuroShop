import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/product_card.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    final currentUser = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
          // Cart Badge Icon
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Navigator.pushNamed(context, '/cart');
                },
              ),
              if (cartProvider.itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      cartProvider.itemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
        child: Column(
          children: [
            // Drawer Header
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              accountName: Text(
                currentUser?.name ?? 'Guest User',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(currentUser?.email ?? 'guest@aura.com'),
            ),
            
            // Options
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text("Home"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.favorite_outline_rounded),
              title: const Text("Wishlist"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/wishlist');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline_rounded),
              title: const Text("My Profile"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            
            // Admin panel if admin role is active
            if (authProvider.isAdmin) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  "Admin Dashboard",
                  style: TextStyle(
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard_customize_outlined, color: AppTheme.primaryColor),
                title: const Text("Admin Panel", style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin');
                },
              ),
            ],
            
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text("Logout", style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context);
                authProvider.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: productProvider.fetchProducts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Promo Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, Color(0xFF818CF8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Summer Sale",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "20% OFF ON ALL\nELECTRONICS!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        productProvider.setCategory("Electronics");
                      },
                      child: const Text("Shop Now", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Category Title
              Text(
                "Categories",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              
              // Category chips list
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppConstants.categories.length,
                  itemBuilder: (context, index) {
                    final cat = AppConstants.categories[index];
                    final isSelected = productProvider.selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryColor,
                        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected 
                              ? Colors.white 
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        onSelected: (_) {
                          productProvider.setCategory(cat);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              // Products list
              Text(
                "${productProvider.selectedCategory} Products",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              productProvider.isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : productProvider.filteredProducts.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40.0),
                            child: Column(
                              children: [
                                const Icon(Icons.storefront_rounded, size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text(
                                  "No products found in this category",
                                  style: TextStyle(
                                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: productProvider.filteredProducts.length,
                          itemBuilder: (context, index) {
                            return ProductCard(
                              product: productProvider.filteredProducts[index],
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
