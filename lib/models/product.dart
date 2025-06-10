// lib/models/product.dart
import 'package:flutter/foundation.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String description;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.description = '',
    this.image = '',
  });

  // Factory constructor para criar Product a partir dos dados do Firestore
  factory Product.fromFirestore(Map<String, dynamic> data, String documentId) {
    try {
      // Converte price para double, lidando com diferentes tipos
      double price = 0.0;
      if (data['price'] is num) {
        price = data['price'].toDouble();
      } else if (data['price'] is String) {
        price = double.tryParse(data['price']) ?? 0.0;
      }
      
      final product = Product(
        id: documentId,
        name: data['name']?.toString() ?? '',
        price: price,
        category: data['category']?.toString() ?? '',
        description: data['description']?.toString() ?? '',
        image: data['image']?.toString() ?? '',
      );
      
      if (kDebugMode) {
        debugPrint('Product: Criado - ID: ${product.id}, Nome: ${product.name}, Categoria: ${product.category}');
      }
      
      return product;
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Product: Erro ao criar produto a partir dos dados do Firestore: $e');
      }
      rethrow;
    }
  }

  // Converte Product para Map para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'description': description,
      'image': image,
    };
  }

  // Método para debug
  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, category: $category)';
  }

  // Operador de igualdade
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}