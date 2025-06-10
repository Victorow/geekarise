// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_colors.dart';
import '../components/header.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../services/endereco_service.dart';
import '../constants/design_constants.dart';
import 'agradecimento_screen.dart';

// If AppColors is not defined, here's a placeholder. Replace with your actual AppColors.
// class AppColors {
//   static const Color lilasClaro = Color(0xFFF2EBF9);
//   static const Color lilasEscuro = Color(0xFFDCD0F0);
//   static const Color primaryPurple = Color(0xFF7E57C2);
//   static const Color lightGreyishPurple = Color(0xFFEDE7F6);
//   static const Color darkText = Colors.black87;
//   static const Color buttonBlack = Colors.black;
// }

class PagamentoScreen extends StatefulWidget {
  const PagamentoScreen({super.key});

  @override
  State<PagamentoScreen> createState() => _PagamentoScreenState();
}

class _PagamentoScreenState extends State<PagamentoScreen> {
  String metodoSelecionado = 'Cartão';
  final cupomController = TextEditingController();
  final CartService _cartService = CartService();
  final OrderService _orderService = OrderService();
  final EnderecoService _enderecoService = EnderecoService();
  double desconto = 0.0;
  bool isProcessingPayment = false;
  bool cupomAplicado = false;

  // Controllers para os campos do cartão
  final nomeController = TextEditingController();
  final cpfController = TextEditingController();
  final numeroCartaoController = TextEditingController();
  final validadeController = TextEditingController();
  final cvcController = TextEditingController();

  // Máscaras removidas - campos agora são apenas obrigatórios

  // Validação das máscaras removida - agora apenas campos obrigatórios

  @override
  void dispose() {
    cupomController.dispose();
    nomeController.dispose();
    cpfController.dispose();
    numeroCartaoController.dispose();
    validadeController.dispose();
    cvcController.dispose();
    super.dispose();
  }

  IconData _getPaymentMethodIcon(String metodo) {
    switch (metodo) {
      case 'Boleto':
        return Icons.receipt_long;
      case 'Cartão':
        return Icons.credit_card;
      case 'Pix':
        return Icons.qr_code_2;
      default:
        return Icons.payment;
    }
  }

  Widget _buildPaymentMethodButton(String methodName, IconData iconData) {
    bool isSelected = metodoSelecionado == methodName;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton.icon(
          icon: Icon(iconData, color: isSelected ? Colors.white : AppColors.primaryPurple, size: 18),
          label: Text(methodName, style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primaryPurple,
            fontSize: 14,
            fontWeight: FontWeight.w600
          )),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? AppColors.primaryPurple : Colors.white,
            foregroundColor: isSelected ? Colors.white : AppColors.primaryPurple,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? AppColors.primaryPurple : AppColors.primaryPurple.withValues(alpha: 77),
                width: isSelected ? 0 : 1
              )
            ),
            elevation: isSelected ? 3 : 0,
          ),
          onPressed: () {
            setState(() {
              metodoSelecionado = methodName;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isWideScreen = screenWidth > 800;
    final horizontalMargin = screenWidth < 360 ? 8.0 : 16.0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(
              showBackButton: true,
              title: null,
              showCartIcon: true,
            ),
            SizedBox(height: screenHeight < 600 ? 12 : 20),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
                child: isWideScreen
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildPaymentForm(),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 2,
                            child: _buildOrderSummary(),
                          ),
                        ],
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            _buildPaymentForm(),
                            SizedBox(height: screenHeight < 600 ? 12 : 20),
                            _buildOrderSummary(),
                          ],
                        ),
                      ),
              ),
            ),
            SizedBox(height: screenHeight < 600 ? 8 : 16),
          ],
        ),
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();

  Widget _buildPaymentForm() {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerPadding = screenWidth < 360 ? 16.0 : screenWidth < 480 ? 20.0 : 24.0;
    
    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: DesignConstants.primaryContainerDecoration,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Escolha uma forma de pagamento:',
              style: DesignConstants.subheadingStyle,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildPaymentMethodButton('Boleto', Icons.receipt_long),
                _buildPaymentMethodButton('Cartão', Icons.credit_card),
                _buildPaymentMethodButton('Pix', Icons.qr_code_2),
              ],
            ),
            const SizedBox(height: 24),
            if (metodoSelecionado == 'Cartão') ...[
              _buildTextField(
                "Nome do titular",
                nomeController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nome do titular é obrigatório';
                  }
                  return null;
                },
              ),
              _buildTextField(
                "CPF",
                cpfController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'CPF é obrigatório';
                  }
                  return null;
                },
              ),
              _buildTextField(
                "Número do cartão",
                numeroCartaoController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Número do cartão é obrigatório';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      "Data de validade",
                      validadeController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Validade é obrigatória';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      "CVC",
                      cvcController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'CVC é obrigatório';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_cartService.cartItems.isNotEmpty && !isProcessingPayment)
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            _processPayment();
                          }
                        }
                      : null,
                  style: DesignConstants.primaryButtonStyle.copyWith(
                    backgroundColor: WidgetStateProperty.all(Colors.black87),
                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
                  ),
                  child: isProcessingPayment
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Confirmar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
            if (metodoSelecionado == 'Boleto') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 51)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.receipt_long, size: 60, color: AppColors.primaryPurple),
                    SizedBox(height: 20),
                    Text(
                      'Instruções para pagamento com Boleto',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'O boleto será gerado após a confirmação do pedido.\nVocê poderá imprimir ou pagar via internet banking.',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_cartService.cartItems.isNotEmpty && !isProcessingPayment)
                      ? _finalizeOrder
                      : null,
                  style: DesignConstants.primaryButtonStyle.copyWith(
                    backgroundColor: WidgetStateProperty.all(Colors.black87),
                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
                  ),
                  child: isProcessingPayment
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Gerar Boleto',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
            if (metodoSelecionado == 'Pix') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 51)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.qr_code_2, size: 60, color: AppColors.primaryPurple),
                    SizedBox(height: 20),
                    Text(
                      'Instruções para pagamento com Pix',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'O código QR será gerado após a confirmação do pedido.\nEscaneie o código ou copie a chave Pix.',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_cartService.cartItems.isNotEmpty && !isProcessingPayment)
                      ? _finalizeOrder
                      : null,
                  style: DesignConstants.primaryButtonStyle.copyWith(
                    backgroundColor: WidgetStateProperty.all(Colors.black87),
                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
                  ),
                  child: isProcessingPayment
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Gerar QR Code Pix',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    final totalComDesconto = _cartService.totalPrice - desconto;
    final screenWidth = MediaQuery.of(context).size.width;
    final containerPadding = screenWidth < 360 ? 16.0 : screenWidth < 480 ? 20.0 : 24.0;
    
    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: DesignConstants.primaryContainerDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumo da compra:',
            style: DesignConstants.subheadingStyle,
          ),
          const SizedBox(height: 20),
          
          // Cupom de desconto
          const Text(
            'Inserir cupom de desconto',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: cupomController,
            decoration: InputDecoration(
              hintText: "Digitar código do cupom",
              hintStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyCoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Aplicar cupom',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              if (cupomAplicado) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _removeCoupon,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryPurple,
                      side: const BorderSide(color: AppColors.primaryPurple),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Excluir cupom',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Forma de pagamento
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 51)),
            ),
            child: Row(
              children: [
                const Text(
                  'Forma de pagamento:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getPaymentMethodIcon(metodoSelecionado),
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        metodoSelecionado,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Cupom aplicado
          if (desconto > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cupom aplicado!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${cupomController.text.toUpperCase()} - 10% de desconto',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          if (desconto > 0) const SizedBox(height: 20),
          
          // Resumo dos valores
          _buildSummaryRow(
            'Sub total (${_cartService.itemCount} item${_cartService.itemCount != 1 ? 's' : ''}):',
            'R\$${_cartService.totalPrice.toStringAsFixed(2)}',
          ),
          if (desconto > 0)
            _buildSummaryRow(
              'Desconto:',
              '- R\$${desconto.toStringAsFixed(2)}',
              valueColor: Colors.green,
            ),
          
          const SizedBox(height: 12),
          const Divider(thickness: 1, color: Colors.white),
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Valor total:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.darkText,
                ),
              ),
              Text(
                'R\$${totalComDesconto.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primaryPurple,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: DesignConstants.primaryButtonStyle.copyWith(
                backgroundColor: WidgetStateProperty.all(Colors.black87),
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
              ),
              onPressed: (_cartService.cartItems.isNotEmpty && !isProcessingPayment) ? _finalizeOrder : null,
              child: isProcessingPayment
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Finalizar compra',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {
    bool isRequired = true,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label${isRequired ? ' *' : ''}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLength: maxLength,
            validator: validator,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              errorStyle: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.darkText),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: valueColor ?? AppColors.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _applyCoupon() {
    if (cupomController.text.isNotEmpty) {
      setState(() {
        final cupom = cupomController.text.toUpperCase();
        if (cupom == 'GEEK10' || cupom == 'ABERTURA') {
          desconto = _cartService.totalPrice * 0.1;
          cupomAplicado = true;
        } else {
          desconto = 0.0;
          cupomAplicado = false;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            desconto > 0
                ? "Cupom aplicado! Desconto de R\$${desconto.toStringAsFixed(2)}"
                : "Cupom inválido",
          ),
          backgroundColor: desconto > 0 ? AppColors.primaria : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignConstants.borderRadius)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _removeCoupon() {
    setState(() {
      cupomController.clear();
      desconto = 0.0;
      cupomAplicado = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Cupom removido!"),
        backgroundColor: AppColors.primaria,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignConstants.borderRadius)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _processPayment() async {
    setState(() {
      isProcessingPayment = true;
    });

          ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Processando pagamento..."),
          backgroundColor: AppColors.primaria,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignConstants.borderRadius)),
          margin: const EdgeInsets.all(16),
        ),
      );

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isProcessingPayment = false;
    });

    final numeroPedido = (1000 + DateTime.now().millisecondsSinceEpoch % 9000).toString();
    _cartService.clearCart();
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AgradecimentoScreen(numeroPedido: numeroPedido),
        ),
      );
    }
  }

  void _finalizeOrder() async {
    setState(() {
      isProcessingPayment = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        isProcessingPayment = false;
      });
      Navigator.of(context).pushNamed('/login');
      return;
    }
    
    if (metodoSelecionado == 'Cartão') {
      if (!_formKey.currentState!.validate()) {
        setState(() { isProcessingPayment = false; });
        return;
      }
    }

    try {
      // Criar itens do pedido
      final orderItems = _cartService.cartItems.map((cartItem) => OrderItem(
        productId: cartItem['id'] as String,
        productName: cartItem['name'] as String,
        price: cartItem['price'] as double,
        quantity: 1, // CartService atual não tem quantidade, sempre 1
        imageUrl: cartItem['image'] as String,
      )).toList();

      // Obter endereço selecionado
      final enderecoAtual = _enderecoService.getEnderecoAtual();
      final enderecoFormatado = enderecoAtual != null 
          ? _enderecoService.formatarEndereco(enderecoAtual)
          : null;

      // Criar o pedido
      await _orderService.createOrder(
        userId: user.uid,
        items: orderItems,
        totalValue: _cartService.totalPrice - desconto,
        paymentMethod: metodoSelecionado,
        discount: desconto,
        deliveryAddress: enderecoFormatado,
      );

      final numeroPedido = DateTime.now().millisecondsSinceEpoch.toString();
      
      _cartService.clearCart();
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AgradecimentoScreen(numeroPedido: numeroPedido),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isProcessingPayment = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao processar pedido: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignConstants.borderRadius)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }
}