import 'package:flutter/material.dart';
import '../app_colors.dart';

class AgradecimentoScreen extends StatelessWidget {
  final String numeroPedido;

  const AgradecimentoScreen({
    super.key,
    required this.numeroPedido,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lilasClaro,
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.lilasEscuro,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Título Geek Arise
                const Text(
                  'Geek Arise',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Substituição pelo GIF animado
                Image.asset(
                  'assets/images/animacao.gif',
                  height: 260, // Ajuste conforme necessário
                  width: 260,  // Ajuste conforme necessário
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
                
                // Restante do seu código permanece igual...
                const Text(
                  'Olá, Cliente!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Mensagem de agradecimento
                const Text(
                  'Muito obrigado por comprar na Geek Arise!',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Número do pedido
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                    children: [
                      const TextSpan(text: 'Seu pedido '),
                      TextSpan(
                        text: '#$numeroPedido',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' já está sendo preparado com todo o cuidado pela nossa equipe.'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Mensagem final
                const Text(
                  'Alguma dúvida?',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Botão para voltar ao início
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Voltar ao início',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}