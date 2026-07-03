import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Large success tick
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 80,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  "Order Placed Successfully!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  "Thank you for shopping with Aura. Your package will reach you shortly.",
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48),
              
              // Back Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Continue Shopping"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
