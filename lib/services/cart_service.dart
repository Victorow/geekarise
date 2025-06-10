import 'package:flutter/material.dart';
import '../models/product.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => List.unmodifiable(_cartItems);

  int get itemCount => _cartItems.length;

  double get totalPrice => _cartItems.fold(0.0, (sum, item) => sum + (item['price'] as double));

  void addProduct(Product product) {
    final cartItem = {
      'id': product.id,
      'name': product.name,
      'price': product.price,
      'image': product.image,
      'category': product.category,
    };

    // Verifica se o produto já está no carrinho
    final existingIndex = _cartItems.indexWhere((item) => item['id'] == product.id);
    
    if (existingIndex == -1) {
      // Produto não está no carrinho, adiciona
      _cartItems.add(cartItem);
      notifyListeners();
    }
    // Se já existe, não adiciona novamente (você pode implementar quantidade se quiser)
  }

  void removeProduct(String productId) {
    _cartItems.removeWhere((item) => item['id'] == productId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  bool isProductInCart(String productId) {
    return _cartItems.any((item) => item['id'] == productId);
  }
} 