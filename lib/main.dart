import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/shop/home_screen.dart';
import 'screens/shop/product_details_screen.dart';
import 'screens/shop/search_screen.dart';
import 'screens/cart_wishlist/cart_screen.dart';
import 'screens/cart_wishlist/wishlist_screen.dart';
import 'screens/checkout/checkout_screen.dart';
import 'screens/checkout/order_success_screen.dart';
import 'screens/profile/profile_screen.dart';

// Admin
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_products_screen.dart';
import 'screens/admin/add_edit_product_screen.dart';
import 'screens/admin/admin_orders_screen.dart';

// Utilities
import 'utils/theme.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Try initializing Firebase (wrapped in try-catch for offline fallback)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase config not found or invalid. Running in Mock Offline Mode: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Auto switches to Light/Dark based on device
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/search': (context) => const SearchScreen(),
          '/product-details': (context) => const ProductDetailsScreen(),
          '/cart': (context) => const CartScreen(),
          '/wishlist': (context) => const WishlistScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/order-success': (context) => const OrderSuccessScreen(),
          '/profile': (context) => const ProfileScreen(),
          
          // Admin Panel routes
          '/admin': (context) => const AdminDashboardScreen(),
          '/admin-products': (context) => const AdminProductsScreen(),
          '/admin-add-edit-product': (context) => const AddEditProductScreen(),
          '/admin-orders': (context) => const AdminOrdersScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}
