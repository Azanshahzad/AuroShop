class AppConstants {
  static const String appName = "Aura Shop";
  
  // Storage keys
  static const String prefsUserKey = "aura_user_data";
  static const String prefsCartKey = "aura_cart_data";
  static const String prefsWishlistKey = "aura_wishlist_data";
  static const String prefsProductsKey = "aura_products_data";
  static const String prefsOrdersKey = "aura_orders_data";

  // Mock Products list for offline/mock mode
  static const List<Map<String, dynamic>> mockProducts = [
    {
      "id": "prod_1",
      "name": "Aura Pulse Smartwatch",
      "description": "Premium smartwatch with AMOLED display, active heart rate monitoring, sleep tracking, and up to 10 days of battery life. Sleek modern aluminum body.",
      "price": 129.99,
      "imageUrl": "https://images.unsplash.com/photo-1542496658-e33a6d0d50f6?w=500&auto=format&fit=crop",
      "category": "Electronics",
      "stock": 15,
      "rating": 4.6,
      "reviewsCount": 124
    },
    {
      "id": "prod_2",
      "name": "Nebula Wireless Headphones",
      "description": "High-fidelity over-ear headphones featuring Hybrid Active Noise Cancellation (ANC), ambient sound mode, and ultra-comfortable memory foam earcups.",
      "price": 199.99,
      "imageUrl": "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&auto=format&fit=crop",
      "category": "Electronics",
      "stock": 8,
      "rating": 4.8,
      "reviewsCount": 89
    },
    {
      "id": "prod_3",
      "name": "EcoThread Organic Hoodie",
      "description": "Crafted from 100% certified organic cotton. Features a double-lined hood, kangaroo pocket, and brushed fleece interior for ultimate warmth and comfort.",
      "price": 59.99,
      "imageUrl": "https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=500&auto=format&fit=crop",
      "category": "Fashion",
      "stock": 25,
      "rating": 4.4,
      "reviewsCount": 42
    },
    {
      "id": "prod_4",
      "name": "Vanguard Leather Messenger Bag",
      "description": "Handcrafted full-grain leather messenger bag with padded sleeve for up to 15-inch laptops. Multiple organizational pockets and adjustable shoulder strap.",
      "price": 149.99,
      "imageUrl": "https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=500&auto=format&fit=crop",
      "category": "Accessories",
      "stock": 5,
      "rating": 4.7,
      "reviewsCount": 35
    },
    {
      "id": "prod_5",
      "name": "AeroStep Running Sneakers",
      "description": "Lightweight breathable mesh upper coupled with a responsive foam midsole designed for long-distance comfort and premium shock absorption.",
      "price": 89.99,
      "imageUrl": "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500&auto=format&fit=crop",
      "category": "Fashion",
      "stock": 18,
      "rating": 4.5,
      "reviewsCount": 78
    },
    {
      "id": "prod_6",
      "name": "HydroStream Insulated Bottle",
      "description": "Double-walled vacuum insulated stainless steel water bottle. Keeps drinks ice-cold for up to 24 hours or piping hot for up to 12 hours. Leak-proof cap.",
      "price": 24.99,
      "imageUrl": "https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=500&auto=format&fit=crop",
      "category": "Home & Living",
      "stock": 50,
      "rating": 4.3,
      "reviewsCount": 110
    }
  ];

  static const List<String> categories = [
    "All",
    "Electronics",
    "Fashion",
    "Accessories",
    "Home & Living"
  ];
}
