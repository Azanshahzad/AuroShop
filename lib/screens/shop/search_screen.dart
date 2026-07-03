import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../utils/theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Reset search query on search page enter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).setSearchQuery("");
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: TextStyle(
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: "Search products...",
            hintStyle: TextStyle(
              color: isDark ? AppTheme.darkTextSecondary.withOpacity(0.5) : AppTheme.lightTextSecondary.withOpacity(0.5),
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) {
            productProvider.setSearchQuery(value);
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () {
                _searchController.clear();
                productProvider.setSearchQuery("");
              },
            ),
        ],
      ),
      body: productProvider.searchQuery.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 64,
                    color: isDark ? Colors.white30 : Colors.black26,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Search Aura premium catalog",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            )
          : productProvider.filteredProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 64,
                        color: isDark ? Colors.white30 : Colors.black26,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No products match your search query",
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
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
    );
  }
}
