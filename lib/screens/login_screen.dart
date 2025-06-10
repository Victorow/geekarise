// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _emailLoginController = TextEditingController();
  final _passwordLoginController = TextEditingController();
  final _nameRegisterController = TextEditingController();
  final _emailRegisterController = TextEditingController();
  final _passwordRegisterController = TextEditingController();
  final _confirmPasswordRegisterController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _redirectTo;
  bool _termsAccepted = false;
  bool _currentlyShowingLogin = true; // Controle simples do formulário ativo - inicia com LOGIN

  late AnimationController _animationController;
  late Animation<double> _animation;

  bool get _isLoginView => _currentlyShowingLogin;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (arguments != null && arguments.containsKey('redirectTo')) {
      _redirectTo = arguments['redirectTo'] as String?;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailLoginController.dispose();
    _passwordLoginController.dispose();
    _nameRegisterController.dispose();
    _emailRegisterController.dispose();
    _passwordRegisterController.dispose();
    _confirmPasswordRegisterController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE NAVEGAÇÃO E SUBMISSÃO ---

  void _navigateToHome() {
    HapticFeedback.lightImpact();
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Campos Inválidos"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    HapticFeedback.lightImpact();
    if (_isLoginView) {
      await _performLogin();
    } else {
      await _performRegister();
    }
  }
  
  Future<void> _performLogin() async {
    if (!(_loginFormKey.currentState?.validate() ?? false)) {
      _showErrorDialog("Por favor, preencha todos os campos obrigatórios para continuar.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _auth.signInWithEmailAndPassword(
          email: _emailLoginController.text.trim(),
          password: _passwordLoginController.text.trim());
      if (mounted) {
        final targetRoute = _redirectTo ?? '/home';
        Navigator.pushNamedAndRemoveUntil(
            context, targetRoute, (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _performRegister() async {
    if (!(_registerFormKey.currentState?.validate() ?? false)) {
      _showErrorDialog("Por favor, preencha todos os campos obrigatórios para criar sua conta.");
      return;
    }

    if (_passwordRegisterController.text !=
        _confirmPasswordRegisterController.text) {
      setState(() => _errorMessage = 'As senhas não coincidem.');
      return;
    }

    if (!_termsAccepted) {
      setState(() =>
          _errorMessage = 'Você precisa ler e aceitar os Termos de Serviço.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
              email: _emailRegisterController.text.trim(),
              password: _passwordRegisterController.text.trim());
      User? newUser = userCredential.user;
      if (newUser != null) {
        await _firestore.collection('users').doc(newUser.uid).set({
          'name': _nameRegisterController.text.trim(),
          'email': newUser.email,
          'createdAt': Timestamp.now()
        });
        await newUser.updateDisplayName(_nameRegisterController.text.trim());
      }
      if (mounted) {
        final targetRoute = _redirectTo ?? '/home';
        Navigator.pushNamedAndRemoveUntil(
            context, targetRoute, (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Conta criada com sucesso! Bem-vindo à Geek Arise!',
                style: GoogleFonts.poppins())));
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleAuthMode() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentlyShowingLogin = !_currentlyShowingLogin;
      _errorMessage = null;
    });
    
    if (_animationController.status != AnimationStatus.forward &&
        _animationController.status != AnimationStatus.completed) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  Future<void> _resetPassword() async {
    final emailController = TextEditingController();
    bool isSending = false; 

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Text("Redefinir Senha"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Digite o e-mail associado à sua conta. Enviaremos um link para você criar uma nova senha.",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(hintText: "Seu e-mail"),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: isSending
                    ? null 
                    : () async {
                        if (emailController.text.isNotEmpty &&
                            emailController.text.contains('@')) {
                          setDialogState(() => isSending = true);
                          final dialogContext = context;
                          final navigator = Navigator.of(dialogContext);
                          final scaffoldMessenger = ScaffoldMessenger.of(dialogContext);
                          
                          try {
                            await _auth.sendPasswordResetEmail(
                                email: emailController.text.trim());
                            if (mounted) {
                              navigator.pop();
                              showDialog(
                                context: dialogContext,
                                builder: (context) => AlertDialog(
                                  title: const Text("Link Enviado!"),
                                  content: const Text(
                                      "Verifique sua caixa de entrada (e a pasta de spam) para o link de redefinição de senha."),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            if (mounted) {
                              navigator.pop();
                              scaffoldMessenger.showSnackBar(SnackBar(
                                  content: Text(
                                      e.message ?? "Erro ao enviar e-mail.")));
                            }
                          }
                        }
                      },
                child: isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Enviar"),
              ),
            ],
          );
        },
      ),
    );
  }

   Future<void> _showTermsDialog() async {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 16,
        insetPadding: EdgeInsets.symmetric(
          horizontal: screenWidth < 360 ? 8.0 : 16.0,
          vertical: screenHeight < 600 ? 20.0 : 40.0,
        ),
        child: Container(
          width: double.infinity,
          height: screenHeight < 600 ? screenHeight * 0.9 : screenHeight * 0.8,
          constraints: BoxConstraints(
            maxWidth: screenWidth > 600 ? 500 : screenWidth * 0.95,
            maxHeight: screenHeight * 0.9,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(screenWidth < 360 ? 16.0 : 24.0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    colors: [Color(0xFF6A82FB), Color(0xFF4C6BFA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      color: Colors.white,
                      size: screenWidth < 360 ? 24.0 : 28.0,
                    ),
                    SizedBox(width: screenWidth < 360 ? 12.0 : 16.0),
                    Expanded(
                      child: Text(
                        "Termos e Condições de Uso",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: screenWidth < 360 ? 16.0 : 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(screenWidth < 360 ? 16.0 : 24.0),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTermsSection(
                          "📅 Última atualização",
                          "09 de junho de 2025",
                          isHighlight: true,
                        ),
                        _buildTermsSection(
                          "🎌 Bem-vindo(a) à Geek Arise!",
                          "Estes Termos e Condições de Uso (\"Termos\") são o contrato que rege sua jornada de compra em nosso site www.geekarise.com.br (\"Site\"), de propriedade de Geek Arise LTDA.\n\nAo navegar em nosso site ou realizar uma compra, você declara ter lido, compreendido e concordado com estes Termos.",
                        ),
                        _buildTermsSection(
                          "🎯 1. OBJETO",
                          "O objeto destes Termos é apresentar as regras para a compra e venda online de nossos produtos, que incluem action figures, mangás, vestuário, acessórios, pôsteres e outros artefatos do universo de animes e da cultura pop japonesa.",
                        ),
                        _buildTermsSection(
                          "👤 2. CADASTRO DO CLIENTE",
                          "• Informações precisas, verdadeiras e completas são obrigatórias\n• Você é responsável pela segurança de seu login e senha\n• Menores de 18 anos precisam de autorização dos responsáveis",
                        ),
                        _buildTermsSection(
                          "🛒 3. PROCESSO DE COMPRA",
                          "• Imagens são ilustrativas\n• Preços podem ser alterados sem aviso\n• Aceitamos: Cartão de Crédito, Pix, Boleto\n• Confirmação após aprovação do pagamento",
                        ),
                        _buildTermsSection(
                          "🚚 4. ENVIO E ENTREGA",
                          "• Entregas realizadas por terceiros em todo o Brasil\n• Prazos são estimativas\n• Custo do frete é do cliente\n• Reenvio por ausência gera nova cobrança",
                        ),
                        _buildTermsSection(
                          "🔄 5. TROCAS E DEVOLUÇÕES",
                          "• 7 dias para arrependimento (CDC Art. 49)\n• 30 dias para defeitos de fabricação\n• Produto deve estar na embalagem original\n• Estorno na mesma modalidade de pagamento",
                        ),
                        _buildTermsSection(
                          "⚖️ 6. PROPRIEDADE INTELECTUAL",
                          "Respeitamos todos os direitos autorais dos animes e mangás. Comercializamos apenas produtos licenciados ou em conformidade com a cultura fã.",
                        ),
                        _buildTermsSection(
                          "🔒 7. PRIVACIDADE (LGPD)",
                          "Seus dados são sagrados como um pergaminho antigo! Tratamos seus dados pessoais de acordo com a LGPD. Acesse nossa Política de Privacidade para detalhes.",
                        ),
                        _buildTermsSection(
                          "📞 8. ATENDIMENTO",
                          "Nossa guilda de suporte está disponível em: contato@geekarise.com.br",
                          isContact: true,
                        ),
                        _buildTermsSection(
                          "📋 9. LEI APLICÁVEL",
                          "Estes Termos são regidos pelas leis do Brasil. Foro da Comarca de São Paulo - SP.",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Actions
              Container(
                padding: EdgeInsets.all(screenWidth < 360 ? 16.0 : 24.0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  color: Colors.white,
                ),
                child: screenWidth < 400 
                  ? Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              foregroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(vertical: screenHeight < 600 ? 12 : 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "❌ Recusar",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: screenWidth < 360 ? 12.0 : 14.0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => _termsAccepted = true);
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4C6BFA),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: screenHeight < 600 ? 12 : 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: Text(
                              "✅ Li e Aceito os Termos",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth < 360 ? 12.0 : 14.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              foregroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(vertical: screenHeight < 600 ? 12 : 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "❌ Recusar",
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => _termsAccepted = true);
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4C6BFA),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: screenHeight < 600 ? 12 : 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: Text(
                              "✅ Li e Aceito os Termos",
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermsSection(String title, String content, {bool isHighlight = false, bool isContact = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth < 360 ? 16.0 : 20.0),
      padding: EdgeInsets.all(screenWidth < 360 ? 12.0 : 16.0),
      decoration: BoxDecoration(
        color: isHighlight 
          ? const Color(0xFF4C6BFA).withOpacity(0.1)
          : isContact 
            ? Colors.green.withOpacity(0.1)
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlight 
            ? const Color(0xFF4C6BFA).withOpacity(0.3)
            : isContact 
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: screenWidth < 360 ? 14.0 : 16.0,
              fontWeight: FontWeight.bold,
              color: isHighlight 
                ? const Color(0xFF4C6BFA)
                : isContact 
                  ? Colors.green.shade700
                  : Colors.black87,
            ),
          ),
          SizedBox(height: screenWidth < 360 ? 6.0 : 8.0),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: screenWidth < 360 ? 12.0 : 14.0,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
  // --- LÓGICA DE CONSTRUÇÃO DA UI ---
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return _buildWideLayout(constraints);
        } else {
          return _buildNarrowLayout();
        }
      },
    );
  }

  Widget _buildWideLayout(BoxConstraints constraints) {
    final panelWidth = constraints.maxWidth / 2;
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final animationValue = _animation.value;
          final welcomePanelX = animationValue * panelWidth;
          final registerFormX = welcomePanelX - panelWidth;
          final loginFormX = welcomePanelX + panelWidth;
          return Stack(
            children: [
              Positioned(
                  left: registerFormX,
                  width: panelWidth,
                  height: constraints.maxHeight,
                  child: _buildForm(isLogin: false)),
              Positioned(
                  left: loginFormX,
                  width: panelWidth,
                  height: constraints.maxHeight,
                  child: _buildForm(isLogin: true)),
              Positioned(
                  left: welcomePanelX,
                  width: panelWidth,
                  height: constraints.maxHeight,
                  child: _buildWelcomePanel(animationValue)),
              Positioned(
                top: 20,
                left: 20,
                child: IconButton(
                  icon: Icon(Icons.home_rounded, color: Colors.grey.shade800),
                  iconSize: 28,
                  onPressed: _navigateToHome,
                  tooltip: 'Voltar para Home',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNarrowLayout() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.06; // 6% da largura da tela
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFF6A82FB), Color(0xFF4C6BFA)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding.clamp(16.0, 32.0),
                    vertical: screenHeight * 0.02,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: screenHeight - MediaQuery.of(context).padding.top - (screenHeight * 0.04),
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, animation) => FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(scale: animation, child: child)),
                        child: !_isLoginView
                            ? _buildFormCard(isLogin: false)
                            : _buildFormCard(isLogin: true),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: SafeArea(
                  child: IconButton(
                    icon: const Icon(Icons.home_rounded, color: Colors.white),
                    onPressed: _navigateToHome,
                    tooltip: 'Voltar para Home',
                    iconSize: screenWidth < 360 ? 20 : 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard({required bool isLogin}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardPadding = screenWidth < 360 ? 16.0 : screenWidth < 480 ? 20.0 : 24.0;
    
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: screenWidth > 500 ? 480 : screenWidth * 0.95,
      ),
      child: Card(
        key: ValueKey(isLogin),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: _buildForm(isLogin: isLogin)
        ),
      ),
    );
  }

  Widget _buildWelcomePanel(double animationValue) {
    final borderRadius = BorderRadius.lerp(
      const BorderRadius.only(
          topRight: Radius.circular(200), bottomRight: Radius.circular(200)),
      const BorderRadius.only(
          topLeft: Radius.circular(200), bottomLeft: Radius.circular(200)),
      animationValue,
    )!;
    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        children: [
          // Imagens de fundo com transição suave
          Positioned.fill(
            child: Stack(
              children: [
                // Imagem para registro (visível quando _animation.value está próximo de 0)
                Positioned.fill(
                  child: Opacity(
                    opacity: 1.0 - _animation.value,
                    child: Image.asset(
                      'assets/images/20%off2.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Imagem para login (visível quando _animation.value está próximo de 1)
                Positioned.fill(
                  child: Opacity(
                    opacity: _animation.value,
                    child: Image.asset(
                      'assets/images/20%off.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Filtro escuro para legibilidade do texto
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black38, Colors.black54],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Conteúdo do painel
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: 1.0 - _animation.value,
                    child: IgnorePointer(
                      ignoring: _animation.value > 0.5,
                      child: _buildPanelContent(
                        title: 'Bem-vindo!',
                        subtitle: 'Ainda não tem uma conta?',
                        buttonText: 'Cadastre-se',
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: _animation.value,
                    child: IgnorePointer(
                      ignoring: _animation.value < 0.5,
                      child: _buildPanelContent(
                        title: 'Olá, amante do Geek!',
                        subtitle: 'Já tem uma conta?',
                        buttonText: 'Login',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelContent(
      {required String title,
      required String subtitle,
      required String buttonText}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title,
            style: GoogleFonts.poppins(
                color: Colors.white, 
                fontSize: 32, 
                fontWeight: FontWeight.w600,
                shadows: const [
                  Shadow(
                    offset: Offset(2, 2),
                    blurRadius: 6,
                    color: Colors.black87,
                  ),
                  Shadow(
                    offset: Offset(-1, -1),
                    blurRadius: 4,
                    color: Colors.black54,
                  ),
                ]),
            textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(subtitle,
            style: GoogleFonts.poppins(
                color: Colors.white, 
                fontSize: 16,
                shadows: const [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 4,
                    color: Colors.black87,
                  ),
                  Shadow(
                    offset: Offset(-0.5, -0.5),
                    blurRadius: 2,
                    color: Colors.black54,
                  ),
                ])),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: _toggleAuthMode,
          style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black.withOpacity(0.3),
              side: const BorderSide(color: Colors.white, width: 2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
          child: Text(buttonText,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black87,
                    ),
                  ])),
        ),
      ],
    );
  }

  // ATUALIZADO: Todos os campos agora são obrigatórios e têm asterisco.
  Widget _buildForm({required bool isLogin}) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Padding responsivo
    final horizontalPadding = screenWidth < 360 ? 16.0 : screenWidth < 480 ? 24.0 : 40.0;
    final verticalPadding = screenHeight < 600 ? 12.0 : 24.0;
    
    // Tamanho de fonte responsivo
    final titleFontSize = screenWidth < 360 ? 22.0 : screenWidth < 480 ? 25.0 : 28.0;
    
    // Espaçamentos responsivos
    final titleSpacing = screenHeight < 600 ? 20.0 : 30.0;
    final fieldSpacing = screenHeight < 600 ? 16.0 : 20.0;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: Form(
        key: isLogin ? _loginFormKey : _registerFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isLogin ? 'Login' : 'Criar Conta',
                style: GoogleFonts.poppins(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            SizedBox(height: titleSpacing),
            if (!isLogin) ...[
              TextFormField(
                  controller: _nameRegisterController,
                  decoration: _buildInputDecoration(
                      labelText: 'Nome Completo', icon: Icons.person_outline),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'O nome completo é obrigatório';
                    }
                    if (v.trim().length < 2) {
                      return 'O nome deve ter pelo menos 2 caracteres';
                    }
                    return null;
                  }),
              SizedBox(height: fieldSpacing),
            ],
            TextFormField(
                controller:
                    isLogin ? _emailLoginController : _emailRegisterController,
                keyboardType: TextInputType.emailAddress,
                decoration: _buildInputDecoration(
                    labelText: 'Email', icon: Icons.alternate_email),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'O e-mail é obrigatório';
                  }
                  final emailTrimmed = v.trim();
                  // Validação mais robusta de email
                  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                  if (!emailRegex.hasMatch(emailTrimmed)) {
                     return 'Insira um e-mail válido';
                  }
                  return null;
                }),
            SizedBox(height: fieldSpacing),
            TextFormField(
                controller: isLogin
                    ? _passwordLoginController
                    : _passwordRegisterController,
                obscureText: true,
                decoration: _buildInputDecoration(
                    labelText: 'Senha', icon: Icons.lock_outline),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                     return 'A senha é obrigatória';
                  }
                  if (v.length < 6) {
                    return 'A senha deve ter no mínimo 6 caracteres';
                  }
                  return null;
                }),
            SizedBox(height: fieldSpacing),
            if (!isLogin) ...[
              TextFormField(
                  controller: _confirmPasswordRegisterController,
                  obscureText: true,
                  decoration: _buildInputDecoration(
                      labelText: 'Confirmar Senha', icon: Icons.lock_outline),
                  validator: (v) {
                     if (v == null || v.isEmpty) {
                        return 'A confirmação de senha é obrigatória';
                     }
                     if (v != _passwordRegisterController.text) {
                       return 'As senhas não coincidem';
                     }
                     return null;
                  }),
              SizedBox(height: fieldSpacing),
            ],
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _errorMessage != null
                  ? Padding(
                      key: ValueKey(_errorMessage),
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(_errorMessage!,
                          style: GoogleFonts.poppins(
                              color: Colors.red, fontSize: 14)))
                  : const SizedBox.shrink(),
            ),
            if (isLogin)
              Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: _resetPassword,
                      child: const Text('Esqueceu a senha?'))),
            if (!isLogin)
              Padding(
                padding: EdgeInsets.symmetric(vertical: fieldSpacing * 0.4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _termsAccepted,
                      onChanged: (v) => setState(() => _termsAccepted = v!),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: RichText(
                          text: TextSpan(
                            text: 'Eu li e aceito os ',
                            style: TextStyle(
                              fontSize: screenWidth < 360 ? 12.0 : 14.0,
                              color: Colors.grey.shade700,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Termos de Serviço',
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  decoration: TextDecoration.underline,
                                  fontSize: screenWidth < 360 ? 12.0 : 14.0,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _showTermsDialog,
                              ),
                              TextSpan(
                                text: ' *',
                                style: TextStyle(
                                  color: Colors.red, 
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth < 360 ? 12.0 : 14.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: fieldSpacing),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB69CFF),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, screenHeight < 600 ? 45 : 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : Text(isLogin ? 'Login' : 'Cadastrar',
                      style: TextStyle(fontSize: screenWidth < 360 ? 14.0 : 16.0)),
            ),
            SizedBox(height: fieldSpacing * 1.5),
            _buildSocialLoginDivider(),
            SizedBox(height: fieldSpacing),
            _buildSocialButtons(),
            if (MediaQuery.of(context).size.width <= 800) ...[
              SizedBox(height: fieldSpacing),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Text(
                    isLogin ? "Não tem uma conta?" : "Já tem uma conta?",
                    style: TextStyle(fontSize: screenWidth < 360 ? 12.0 : 14.0),
                  ),
                  TextButton(
                      onPressed: _toggleAuthMode,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        isLogin ? "Cadastre-se" : "Login",
                        style: TextStyle(fontSize: screenWidth < 360 ? 12.0 : 14.0),
                      ))
                ]
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLoginDivider() => Row(children: [
        const Expanded(child: Divider()),
        Text("  ou entre com  ",
            style: GoogleFonts.poppins(color: Colors.grey)),
        const Expanded(child: Divider())
      ]);

  Widget _buildSocialButtons() =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _buildSocialButton(FontAwesomeIcons.google),
        const SizedBox(width: 16),
        _buildSocialButton(FontAwesomeIcons.facebookF),
        const SizedBox(width: 16),
        _buildSocialButton(FontAwesomeIcons.github)
      ]);

  Widget _buildSocialButton(IconData icon) => IconButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Login social não implementado ainda.")));
      },
      icon: FaIcon(icon, color: Colors.grey.shade700),
      style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: Colors.grey.shade300),
          padding: const EdgeInsets.all(12)));

  // ATUALIZADO: Agora usa 'labelText' com RichText para o asterisco.
  InputDecoration _buildInputDecoration(
      {required String labelText, required IconData icon}) {
    return InputDecoration(
        label: RichText(
          text: TextSpan(
            text: labelText,
            style: TextStyle(color: Colors.grey.shade700),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              )
            ]
          ),
        ),
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 16));
  }
}