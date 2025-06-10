// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../components/header.dart';
import '../services/cart_service.dart';
import '../services/endereco_service.dart';
import '../constants/design_constants.dart';
import '../app_colors.dart';
import 'pagamento_screen.dart';

class EnderecoScreen extends StatefulWidget {
  const EnderecoScreen({super.key});

  @override
  State<EnderecoScreen> createState() => _EnderecoScreenState();
}

class _EnderecoScreenState extends State<EnderecoScreen> {
  final CartService _cartService = CartService();
  final EnderecoService _enderecoService = EnderecoService();
  final _formKey = GlobalKey<FormState>();
  
  String? enderecoSelecionado;
  bool _isCreatingAddress = false;
  
  // Controllers para novo endereço
  final nomeController = TextEditingController();
  final cepController = TextEditingController();
  final ruaController = TextEditingController();
  final numeroController = TextEditingController();
  final complementoController = TextEditingController();
  final bairroController = TextEditingController();
  final cidadeController = TextEditingController();
  final estadoController = TextEditingController();

  @override
  void dispose() {
    nomeController.dispose();
    cepController.dispose();
    ruaController.dispose();
    numeroController.dispose();
    complementoController.dispose();
    bairroController.dispose();
    cidadeController.dispose();
    estadoController.dispose();
    super.dispose();
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
                            child: _buildAddressForm(),
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
                            _buildAddressForm(),
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

  Widget _buildAddressForm() {
    final enderecosSalvos = _enderecoService.getEnderecos();
    final screenWidth = MediaQuery.of(context).size.width;
    final containerPadding = screenWidth < 360 ? 16.0 : screenWidth < 480 ? 20.0 : 24.0;
    
    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: DesignConstants.primaryContainerDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Endereço de entrega',
            style: DesignConstants.headingStyle,
          ),
          const SizedBox(height: 20),
          
          // Endereços salvos
          if (enderecosSalvos.isNotEmpty) ...[
            const Text(
              'Endereços salvos:',
              style: DesignConstants.subheadingStyle,
            ),
            const SizedBox(height: 16),
            ...enderecosSalvos.map((endereco) => _buildAddressCard(endereco)),
            const SizedBox(height: 24),
          ],
          
          // Botão para adicionar novo endereço
          if (!_isCreatingAddress)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _isCreatingAddress = true;
                  });
                },
                style: DesignConstants.secondaryButtonStyle.copyWith(
                  padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
                  side: WidgetStateProperty.all(const BorderSide(color: AppColors.primaryPurple)),
                  foregroundColor: WidgetStateProperty.all(AppColors.primaryPurple),
                ),
                icon: const Icon(Icons.add_location),
                label: const Text('Adicionar novo endereço'),
              ),
            ),
          
          // Formulário para novo endereço
          if (_isCreatingAddress) ...[
            const Text(
              'Novo endereço:',
              style: DesignConstants.subheadingStyle,
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    "Nome para identificação",
                    nomeController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nome é obrigatório';
                      }
                      return null;
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          "CEP",
                          cepController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'CEP é obrigatório';
                            }
                            if (value.length < 8) {
                              return 'CEP deve ter 8 dígitos';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: _buildTextField(
                          "Rua",
                          ruaController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Rua é obrigatória';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: _buildTextField(
                          "Número",
                          numeroController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Número obrigatório';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          "Complemento",
                          complementoController,
                          isRequired: false,
                        ),
                      ),
                    ],
                  ),
                  _buildTextField(
                    "Bairro",
                    bairroController,
                                              validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Bairro é obrigatório';
                            }
                            return null;
                          },
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          "Cidade",
                          cidadeController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Cidade é obrigatória';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: _buildTextField(
                          "UF",
                          estadoController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'UF é obrigatória';
                            }
                            if (value.length != 2) {
                              return 'UF deve ter 2 letras';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _isCreatingAddress = false;
                              _clearForm();
                            });
                          },
                          style: DesignConstants.secondaryButtonStyle.copyWith(
                            foregroundColor: WidgetStateProperty.all(Colors.grey),
                            side: WidgetStateProperty.all(const BorderSide(color: Colors.grey)),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveNewAddress,
                          style: DesignConstants.primaryButtonStyle.copyWith(
                            backgroundColor: WidgetStateProperty.all(AppColors.primaryPurple),
                          ),
                          child: const Text('Salvar endereço'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddressCard(Map<String, String> endereco) {
    final isSelected = enderecoSelecionado == endereco['id'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignConstants.borderRadius),
        border: Border.all(
          color: isSelected ? AppColors.primaryPurple : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected ? DesignConstants.lightShadow : null,
      ),
      child: RadioListTile<String>(
        value: endereco['id']!,
        groupValue: enderecoSelecionado,
        onChanged: (value) {
          setState(() {
            enderecoSelecionado = value;
          });
        },
        activeColor: AppColors.primaryPurple,
        title: Text(
          endereco['nome']!,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${endereco['rua']}, ${endereco['numero']}'),
            if (endereco['complemento']!.isNotEmpty)
              Text('${endereco['complemento']}'),
            Text('${endereco['bairro']} - ${endereco['cidade']}/${endereco['estado']}'),
            Text('CEP: ${endereco['cep']}'),
          ],
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildOrderSummary() {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerPadding = screenWidth < 360 ? 16.0 : screenWidth < 480 ? 20.0 : 24.0;
    
    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: DesignConstants.primaryContainerDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumo do pedido:',
            style: DesignConstants.subheadingStyle,
          ),
          const SizedBox(height: 20),
          
          // Produtos
          Column(
            children: _cartService.cartItems.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      item['image'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (c,e,s) => const Icon(Icons.broken_image, size: 50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'R\$${(item['price'] as double).toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.primaryPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
          
          const SizedBox(height: 16),
          const Divider(color: Colors.white),
          const SizedBox(height: 16),
          
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'R\$${_cartService.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Botão continuar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (enderecoSelecionado != null) ? _goToPayment : null,
              style: DesignConstants.primaryButtonStyle.copyWith(
                backgroundColor: WidgetStateProperty.all(Colors.black87),
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ir para tela de pagamento',
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
    String? Function(String?)? validator,
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

  void _clearForm() {
    nomeController.clear();
    cepController.clear();
    ruaController.clear();
    numeroController.clear();
    complementoController.clear();
    bairroController.clear();
    cidadeController.clear();
    estadoController.clear();
  }

  void _saveNewAddress() {
    if (_formKey.currentState!.validate()) {
      final novoEndereco = {
        'nome': nomeController.text,
        'cep': cepController.text,
        'rua': ruaController.text,
        'numero': numeroController.text,
        'complemento': complementoController.text,
        'bairro': bairroController.text,
        'cidade': cidadeController.text,
        'estado': estadoController.text,
      };
      
      final savedId = _enderecoService.adicionarEndereco(novoEndereco);
      
      setState(() {
        enderecoSelecionado = savedId;
        _isCreatingAddress = false;
        _clearForm();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Endereço salvo com sucesso!"),
          backgroundColor: AppColors.primaria,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignConstants.borderRadius)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _goToPayment() {
    if (enderecoSelecionado != null) {
      _enderecoService.setEnderecoSelecionado(enderecoSelecionado!);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PagamentoScreen()),
      );
    }
  }
} 