import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/wishlist_provider.dart';
import '../providers/cart_provider.dart';
import '../utils/theme.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final isFavorite = wishlistProvider.isFavorite(product.id);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/product-details',
          arguments: product,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.shade100,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image & Wishlist Button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    product.imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: product.imageUrl.startsWith('http') ? BoxFit.cover : null,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 140,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey),
                      );
                    },
                  ),
                ),
                // Wishlist Badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: ClipOval(
                    child: Container(
                      color: (isDark ? AppTheme.darkBg : Colors.white).withOpacity(0.9),
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isFavorite ? Colors.redAccent : (isDark ? Colors.white70 : Colors.black54),
                          size: 20,
                        ),
                        onPressed: () {
                          wishlistProvider.toggleFavorite(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isFavorite 
                                    ? "${product.name} removed from Wishlist" 
                                    : "${product.name} added to Wishlist",
                              ),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // Category Badge
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: AppTheme.secondaryColor, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              product.rating.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "(${product.reviewsCount})",
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? AppTheme.darkTextSecondary.withOpacity(0.7) : AppTheme.lightTextSecondary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    // Price & Cart Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "\$${product.price.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        GestureDetector(
                          onTap: product.stock > 0
                              ? () {
                                  cartProvider.addItem(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("${product.name} added to Cart"),
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                      action: SnackBarAction(
                                        label: "View",
                                        textColor: AppTheme.secondaryColor,
                                        onPressed: () {
                                          Navigator.pushNamed(context, '/cart');
                                        },
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: product.stock > 0 
                                  ? AppTheme.primaryColor 
                                  : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              product.stock > 0 
                                  ? Icons.add_shopping_cart_rounded 
                                  : Icons.remove_shopping_cart_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
