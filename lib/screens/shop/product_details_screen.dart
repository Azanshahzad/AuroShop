import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../utils/theme.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({Key? key}) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Retrieve product arguments passed via navigation
    final product = ModalRoute.of(context)!.settings.arguments as Product;
    
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final isFavorite = wishlistProvider.isFavorite(product.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Slivers AppBar with Product Image
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
            actions: [
              ClipOval(
                child: Container(
                  color: (isDark ? AppTheme.darkBg : Colors.white).withOpacity(0.8),
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFavorite ? Colors.redAccent : (isDark ? Colors.white : Colors.black87),
                    ),
                    onPressed: () {
                      wishlistProvider.toggleFavorite(product);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product_image_${product.id}',
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image_rounded, size: 64, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
          ),
          
          // Details content
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkBg : AppTheme.lightBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          product.category,
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppTheme.secondaryColor, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            product.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "(${product.reviewsCount} reviews)",
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Product Name
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 12),
                  
                  // Stock Status
                  Row(
                    children: [
                      Icon(
                        product.stock > 0 ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded,
                        color: product.stock > 0 ? Colors.green : Colors.redAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        product.stock > 0 
                            ? "In Stock (${product.stock} items left)" 
                            : "Out of Stock",
                        style: TextStyle(
                          color: product.stock > 0 ? Colors.green : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Description Header
                  const Text(
                    "Description",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  
                  // Description
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Quantity Selector (if in stock)
                  if (product.stock > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Quantity",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: _quantity > 1
                                    ? () {
                                        setState(() {
                                          _quantity--;
                                        });
                                      }
                                    : null,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  _quantity.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: _quantity < product.stock
                                    ? () {
                                        setState(() {
                                          _quantity++;
                                        });
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Bottom Action Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Price",
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  ),
                ),
                Text(
                  "\$${(product.price * _quantity).toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: product.stock > 0 ? AppTheme.primaryColor : Colors.grey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: product.stock > 0
                      ? () {
                          // Add specified quantity to Cart
                          for (int i = 0; i < _quantity; i++) {
                            cartProvider.addItem(product);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Added $_quantity ${product.name} to Cart"),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      : null,
                  child: Text(
                    product.stock > 0 ? "Add to Cart" : "Out of Stock",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
