// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/header.dart';
import '../services/order_service.dart';
import '../constants/design_constants.dart';
import '../app_colors.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderService _orderService = OrderService();
  List<Order> userOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserOrders();
  }

  Future<void> _loadUserOrders() async {
    setState(() {
      isLoading = true;
    });
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final orders = await _orderService.getUserOrders(user.uid);
        setState(() {
          userOrders = orders;
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          userOrders = [];
          isLoading = false;
        });
      }
    } else {
      setState(() {
        userOrders = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < DesignConstants.mobileBreakpoint;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          const CustomHeader(
            showBackButton: true,
            title: 'Meus Pedidos',
            showCartIcon: true,
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : DesignConstants.maxContentWidth,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16.0 : 24.0,
                vertical: 24.0,
              ),
              child: Container(
                decoration: DesignConstants.primaryContainerDecoration,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: isLoading
                      ? _buildLoadingState()
                      : userOrders.isEmpty
                          ? _buildEmptyState()
                          : _buildOrdersList(isMobile),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primaria,
          ),
          SizedBox(height: 24),
          Text(
            'Carregando seus pedidos...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhum pedido encontrado',
            style: DesignConstants.headingStyle.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Quando você fizer seu primeiro pedido, ele aparecerá aqui!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
            },
            style: DesignConstants.primaryButtonStyle,
            child: const Text('Começar a comprar'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(bool isMobile) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: userOrders.length,
      itemBuilder: (context, index) {
        final order = userOrders[index];
        return _buildOrderCard(order, isMobile);
      },
    );
  }

  Widget _buildOrderCard(Order order, bool isMobile) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignConstants.borderRadius),
        boxShadow: DesignConstants.lightShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do pedido
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: DesignConstants.primaryGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pedido #${order.id}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Feito em ${dateFormat.format(order.orderDate)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _orderService.getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
                  // Conteúdo do pedido
        Padding(
          padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status detalhado
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _orderService.getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _orderService.getStatusColor(order.status).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: _orderService.getStatusColor(order.status),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _orderService.getStatusDescription(order.status),
                        style: TextStyle(
                          color: _orderService.getStatusColor(order.status),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Endereço de entrega
              if (order.deliveryAddress != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.blue.shade700, size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'Endereço de entrega:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        order.deliveryAddress!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              // Produtos em cards organizados
              const Text(
                'Produtos:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              
              ...order.items.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.imageUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.image_not_supported, size: 30, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Qtd: ${item.quantity}',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaria.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'R\$${item.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: AppColors.primaria,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
              
              const SizedBox(height: 20),
              
              // Informações organizadas em cards
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(Icons.payment, 'Forma de pagamento:', order.paymentMethod),
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.local_shipping, 'Entrega prevista:', dateFormat.format(order.deliveryDate)),
                    if (order.discount > 0) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(Icons.local_offer, 'Desconto aplicado:', 'R\$${order.discount.toStringAsFixed(2)}', 
                          valueColor: Colors.green),
                    ],
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.attach_money, color: AppColors.primaria, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Valor total:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'R\$${order.totalValue.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaria,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Botão de ação (se necessário)
              if (order.status == 'Aguardando pagamento') ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _confirmPayment(order.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaria,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(order.paymentMethod == 'Pix' ? Icons.qr_code : Icons.receipt, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          order.paymentMethod == 'Pix' ? 'Pagar com Pix' : 'Pagar Boleto',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  void _confirmPayment(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Pagamento'),
        content: const Text('Deseja confirmar o pagamento deste pedido?'),
        actions: [
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _orderService.confirmPayment(orderId);
              setState(() {
                _loadUserOrders();
              });
              
              if (mounted) {
                final currentContext = context;
                ScaffoldMessenger.of(currentContext).showSnackBar(
                  SnackBar(
                    content: const Text('Pagamento confirmado com sucesso!'),
                    backgroundColor: AppColors.primaria,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignConstants.borderRadius),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaria),
            child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
} 