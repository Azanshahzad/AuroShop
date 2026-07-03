import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';
import '../../utils/theme.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productProvider = Provider.of<ProductProvider>(context);
    final products = productProvider.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Products"),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.pushNamed(context, '/admin-add-edit-product');
        },
      ),
      body: products.isEmpty
          ? const Center(
              child: Text("No products in store. Tap + to add one."),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          product.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image, size: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Stock: ${product.stock} • \$${product.price.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Edit / Delete Buttons
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryColor, size: 20),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/admin-add-edit-product',
                            arguments: product,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                        onPressed: () {
                          // Show delete confirmation dialog
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Delete Product"),
                              content: Text("Are you sure you want to delete ${product.name}?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(ctx);
                                    final success = await productProvider.deleteProduct(product.id);
                                    if (success && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Product deleted successfully")),
                                      );
                                    }
                                  },
                                  child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
