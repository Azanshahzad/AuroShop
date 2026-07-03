import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';

class AddEditProductScreen extends StatefulWidget {
  const AddEditProductScreen({Key? key}) : super(key: key);

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageController = TextEditingController();
  String _selectedCategory = AppConstants.categories[1]; // Electronics default
  Product? _editingProduct;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final productArg = ModalRoute.of(context)!.settings.arguments as Product?;
      if (productArg != null) {
        _editingProduct = productArg;
        _nameController.text = productArg.name;
        _descController.text = productArg.description;
        _priceController.text = productArg.price.toString();
        _stockController.text = productArg.stock.toString();
        _imageController.text = productArg.imageUrl;
        if (AppConstants.categories.contains(productArg.category)) {
          _selectedCategory = productArg.category;
        }
      }
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    final finalProduct = Product(
      id: _editingProduct?.id ?? '',
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      imageUrl: _imageController.text.trim(),
      category: _selectedCategory,
      stock: int.parse(_stockController.text.trim()),
      rating: _editingProduct?.rating ?? 4.5,
      reviewsCount: _editingProduct?.reviewsCount ?? 0,
    );

    bool success;
    if (_editingProduct == null) {
      success = await productProvider.addProduct(finalProduct);
    } else {
      success = await productProvider.updateProduct(finalProduct);
    }

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_editingProduct == null ? "Product added" : "Product updated")),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error saving product")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_editingProduct == null ? "Add Product" : "Edit Product"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _nameController,
                hintText: "Product Name",
                prefixIcon: Icons.title_rounded,
                validator: (val) => val == null || val.trim().isEmpty ? "Name is required" : null,
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _descController,
                hintText: "Description",
                prefixIcon: Icons.description_outlined,
                validator: (val) => val == null || val.trim().isEmpty ? "Description is required" : null,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _priceController,
                      hintText: "Price (\$)",
                      prefixIcon: Icons.attach_money_rounded,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Price required";
                        if (double.tryParse(val) == null) return "Invalid number";
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _stockController,
                      hintText: "Stock Qty",
                      prefixIcon: Icons.inventory_rounded,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Stock required";
                        if (int.tryParse(val) == null) return "Invalid integer";
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _imageController,
                hintText: "Image URL",
                prefixIcon: Icons.image_outlined,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return "Image link is required";
                  if (!val.startsWith('http')) return "Must be valid URL link";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Category Dropdown
              const Text("Category", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.15)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    dropdownColor: isDark ? AppTheme.darkCard : Colors.white,
                    items: AppConstants.categories
                        .where((c) => c != "All")
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCategory = val;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              CustomButton(
                text: "Save Product",
                onPressed: _saveProduct,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
