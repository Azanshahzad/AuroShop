import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../utils/theme.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalController = TextEditingController();
  String _paymentMethod = "Credit Card";

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  void _onPay() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    final fullAddress = "${_addressController.text.trim()}, ${_cityController.text.trim()} - ${_postalController.text.trim()}";
    
    final success = await cartProvider.checkout(
      userId: authProvider.user?.id ?? 'guest_user',
      shippingAddress: fullAddress,
    );

    if (success) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/order-success',
          ModalRoute.withName('/home'),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to place order. Try again."),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary
              const Text(
                "Order Summary",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Items (${cartProvider.itemCount})",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "\$${cartProvider.totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Address Fields
              const Text(
                "Shipping Information",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _addressController,
                hintText: "Street Address",
                prefixIcon: Icons.home_outlined,
                validator: (val) => val == null || val.trim().isEmpty ? "Address is required" : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _cityController,
                      hintText: "City",
                      prefixIcon: Icons.location_city_outlined,
                      validator: (val) => val == null || val.trim().isEmpty ? "City is required" : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _postalController,
                      hintText: "Postal Code",
                      prefixIcon: Icons.pin_drop_outlined,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.trim().isEmpty ? "Postal code required" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Payment Methods
              const Text(
                "Payment Method",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              
              RadioListTile<String>(
                title: const Text("Credit Card"),
                subtitle: const Text("Pay securely with Stripe simulation"),
                value: "Credit Card",
                groupValue: _paymentMethod,
                activeColor: AppTheme.primaryColor,
                onChanged: (val) {
                  setState(() {
                    _paymentMethod = val!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text("Cash on Delivery"),
                subtitle: const Text("Pay at your doorstep"),
                value: "Cash on Delivery",
                groupValue: _paymentMethod,
                activeColor: AppTheme.primaryColor,
                onChanged: (val) {
                  setState(() {
                    _paymentMethod = val!;
                  });
                },
              ),
              const SizedBox(height: 40),
              
              // Button
              CustomButton(
                text: "Pay & Place Order",
                onPressed: _onPay,
                isLoading: cartProvider.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
