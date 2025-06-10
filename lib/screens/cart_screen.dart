// lib/screens/cart_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../components/header.dart';
import '../services/cart_service.dart';
import '../constants/design_constants.dart';
import 'home_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    // Escuta mudanças no carrinho
    _cartService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _removeItem(String itemId) {
    _cartService.removeProduct(itemId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Item removido do carrinho!"),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignConstants.borderRadius)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _emptyCart() {
    _cartService.clearCart();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Carrinho esvaziado!"),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignConstants.borderRadius)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = _cartService.cartItems;
    double totalPrice = _cartService.totalPrice;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(
              showBackButton: true,
              showCartIcon: true,
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.all(MediaQuery.of(context).size.width < 360 ? 8.0 : 16.0),
                decoration: DesignConstants.primaryContainerDecoration,
                child: Padding(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width < 360 ? 16.0 : 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Carrinho',
                            style: DesignConstants.headingStyle,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.black87),
                            onPressed: () {
                              Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                            },
                          ),
                        ],
                      ),
                      if (cartItems.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton(
                              style: DesignConstants.primaryButtonStyle.copyWith(
                                backgroundColor: WidgetStateProperty.all(Colors.black87),
                              ),
                              onPressed: _emptyCart,
                              child: const Text('Esvaziar carrinho'),
                            ),
                          ),
                        ),
                      if (cartItems.isEmpty)
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(FontAwesomeIcons.cartArrowDown, size: 60, color: Colors.grey),
                                const SizedBox(height: 16),
                                const Text('Seu carrinho está vazio!', style: TextStyle(fontSize: 18, color: Colors.grey)),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  style: DesignConstants.primaryButtonStyle,
                                  onPressed: () {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                                      (Route<dynamic> route) => false,
                                    );
                                  },
                                  child: const Text('Explorar produtos'),
                                )
                              ],
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              final item = cartItems[index];
                              return Container(
                                decoration: DesignConstants.cardDecoration,
                                margin: const EdgeInsets.only(bottom: 16),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: Image.asset(
                                    item['image'], width: 60, height: 60, fit: BoxFit.cover,
                                    errorBuilder: (c,e,s) => const Icon(Icons.broken_image, size: 60),
                                  ),
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Produto:', style: TextStyle(fontSize: 12, color: Colors.black87.withAlpha(179))),
                                      Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                                      const SizedBox(height: 4),
                                      Text('Valor: R\$${(item['price'] as double).toStringAsFixed(2)}', style: const TextStyle(color: Colors.black87)),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(FontAwesomeIcons.trashCan, color: Colors.redAccent),
                                    onPressed: () => _removeItem(item['id'] as String),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 8),
                      if (cartItems.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                              Text('R\$${totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                                                  SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: DesignConstants.secondaryButtonStyle.copyWith(
                                padding: WidgetStateProperty.all(const EdgeInsets.all(16)),
                                side: WidgetStateProperty.all(const BorderSide(color: Colors.black87)),
                                foregroundColor: WidgetStateProperty.all(Colors.black87),
                              ),
                              onPressed: () => Navigator.pushNamed(context, '/endereco'),
                              label: const Text('Confirmar endereço'),
                              icon: const Icon(Icons.location_on),
                            ),
                          ),
                      ]
                    ],
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