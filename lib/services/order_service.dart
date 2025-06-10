import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalValue;
  final String paymentMethod;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final String status;
  final double discount;
  final String? deliveryAddress;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalValue,
    required this.paymentMethod,
    required this.orderDate,
    required this.deliveryDate,
    required this.status,
    this.discount = 0.0,
    this.deliveryAddress,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalValue': totalValue,
      'paymentMethod': paymentMethod,
      'orderDate': Timestamp.fromDate(orderDate),
      'deliveryDate': Timestamp.fromDate(deliveryDate),
      'status': status,
      'discount': discount,
      'deliveryAddress': deliveryAddress,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static Order fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      userId: map['userId'],
      items: (map['items'] as List).map((item) => OrderItem.fromMap(item)).toList(),
      totalValue: (map['totalValue'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? '',
      orderDate: map['orderDate'] is Timestamp 
          ? (map['orderDate'] as Timestamp).toDate()
          : DateTime.parse(map['orderDate']),
      deliveryDate: map['deliveryDate'] is Timestamp
          ? (map['deliveryDate'] as Timestamp).toDate()
          : DateTime.parse(map['deliveryDate']),
      status: map['status'] ?? '',
      discount: (map['discount'] ?? 0).toDouble(),
      deliveryAddress: map['deliveryAddress'],
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String imageUrl;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }

  static OrderItem fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}

class OrderService extends ChangeNotifier {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  // Buscar pedidos do usuário no Firestore
  Future<List<Order>> getUserOrders(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();

      final orders = querySnapshot.docs
          .map((doc) => Order.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      // Ordenar por data do pedido (mais recente primeiro)
      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

      // Atualizar cache local
      _orders.clear();
      _orders.addAll(orders);
      
      return orders;
    } catch (e) {
      // Retornar pedidos do cache local em caso de erro
      return _orders.where((order) => order.userId == userId).toList()
        ..sort((a, b) => b.orderDate.compareTo(a.orderDate));
    }
  }

  // Criar pedido no Firestore
  Future<String?> createOrder({
    required String userId,
    required List<OrderItem> items,
    required double totalValue,
    required String paymentMethod,
    required double discount,
    String? deliveryAddress,
  }) async {
    try {
      final orderDate = DateTime.now();
      final deliveryDate = orderDate.add(const Duration(days: 7)); // 7 dias para entrega

      String status;
      switch (paymentMethod) {
        case 'Cartão':
          status = 'Processando pagamento';
          break;
        case 'Pix':
          status = 'Aguardando pagamento';
          break;
        case 'Boleto':
          status = 'Aguardando pagamento';
          break;
        default:
          status = 'Pedido criado';
      }

      final order = Order(
        id: '', // Será definido pelo Firestore
        userId: userId,
        items: items,
        totalValue: totalValue,
        paymentMethod: paymentMethod,
        orderDate: orderDate,
        deliveryDate: deliveryDate,
        status: status,
        discount: discount,
        deliveryAddress: deliveryAddress,
      );

      // Salvar no Firestore
      final docRef = await _firestore.collection('orders').add(order.toMap());
      
      // Criar order com ID do Firestore
      final orderWithId = Order(
        id: docRef.id,
        userId: userId,
        items: items,
        totalValue: totalValue,
        paymentMethod: paymentMethod,
        orderDate: orderDate,
        deliveryDate: deliveryDate,
        status: status,
        discount: discount,
        deliveryAddress: deliveryAddress,
      );

      // Adicionar ao cache local
      _orders.add(orderWithId);
      notifyListeners();

      // Simular processamento de pagamento
      if (paymentMethod == 'Cartão') {
        await Future.delayed(const Duration(seconds: 2));
        await updateOrderStatus(docRef.id, 'Pagamento confirmado');
      }

      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  // Atualizar status do pedido no Firestore
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      // Atualizar no Firestore
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Atualizar cache local
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        final order = _orders[orderIndex];
        final updatedOrder = Order(
          id: order.id,
          userId: order.userId,
          items: order.items,
          totalValue: order.totalValue,
          paymentMethod: order.paymentMethod,
          orderDate: order.orderDate,
          deliveryDate: order.deliveryDate,
          status: newStatus,
          discount: order.discount,
          deliveryAddress: order.deliveryAddress,
        );
        _orders[orderIndex] = updatedOrder;
        notifyListeners();
      }
    } catch (e) {
      // Erro silencioso
    }
  }

  Future<void> confirmPayment(String orderId) async {
    await updateOrderStatus(orderId, 'Pagamento confirmado');
    await Future.delayed(const Duration(seconds: 1));
    await updateOrderStatus(orderId, 'Preparando pedido');
  }

  String getStatusDescription(String status) {
    switch (status) {
      case 'Aguardando pagamento':
        return 'Aguardando confirmação do pagamento';
      case 'Processando pagamento':
        return 'Processando pagamento do cartão';
      case 'Pagamento confirmado':
        return 'Pagamento confirmado com sucesso';
      case 'Preparando pedido':
        return 'Preparando seu pedido para envio';
      case 'Em trânsito':
        return 'Pedido saiu para entrega';
      case 'Entregue':
        return 'Pedido entregue com sucesso';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Aguardando pagamento':
        return const Color(0xFFFF9800);
      case 'Processando pagamento':
        return const Color(0xFF2196F3);
      case 'Pagamento confirmado':
        return const Color(0xFF4CAF50);
      case 'Preparando pedido':
        return const Color(0xFF9C27B0);
      case 'Em trânsito':
        return const Color(0xFF00BCD4);
      case 'Entregue':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF757575);
    }
  }
} 