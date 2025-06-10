// lib/components/header.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_colors.dart';
import '../services/auth_service.dart';
import '../constants/design_constants.dart';

// Assumindo que CustomSearchDelegate está em home_screen.dart ou importado corretamente
// se você for adicionar um ícone de busca aqui que o chame.
// import '../screens/home_screen.dart' show CustomSearchDelegate;


class CustomHeader extends StatelessWidget {
  final bool showBackButton;
  final String? title;
  final bool showCartIcon;

  const CustomHeader({
    super.key,
    this.showBackButton = false,
    this.title,
    this.showCartIcon = true,
  });

  void _navigateTo(BuildContext context, String route) {
    // Se for para /login ou /registrar e já estiver em uma dessas, não faz nada ou volta
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if ((route == '/login' && currentRoute == '/login') || 
        (route == '/registrar' && currentRoute == '/registrar')) {
      return;
    }
    if (route == '/') { // Para o logo, sempre vai para a home limpando a pilha
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } else {
        Navigator.of(context).pushNamed(route);
    }
  }

  void _showMobileMenu(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void _navigateToOrders(BuildContext context) {
    // Verifica se o usuário está logado
    if (FirebaseAuth.instance.currentUser != null) {
      Navigator.of(context).pushNamed('/pedidos');
    } else {
      // Se não estiver logado, vai para o login
      Navigator.of(context).pushNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ADICIONADO: Instancia o AuthService para usar no StreamBuilder
    final AuthService authService = AuthService();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 768;

        final horizontalPadding = constraints.maxWidth < 360 
            ? DesignConstants.smallSpacing 
            : DesignConstants.largeSpacing;
        final verticalPadding = constraints.maxWidth < 360 
            ? DesignConstants.smallSpacing 
            : DesignConstants.mediumSpacing;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding, 
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            gradient: DesignConstants.primaryGradient,
            boxShadow: DesignConstants.mediumShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Lado Esquerdo
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showBackButton)
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back, 
                        color: AppColors.primaria,
                        size: constraints.maxWidth < 360 ? 20 : 24,
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                      },
                      iconSize: constraints.maxWidth < 360 ? 20 : 24,
                    )
                  else if (!isDesktop)
                    IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.bars, 
                        color: AppColors.primaria,
                        size: constraints.maxWidth < 360 ? 18 : 20,
                      ),
                      onPressed: () => _showMobileMenu(context),
                      iconSize: constraints.maxWidth < 360 ? 20 : 24,
                    ),
                  if (isDesktop && !showBackButton) ...[
                    _HeaderButton(
                      icon: FontAwesomeIcons.rocket,
                      text: 'Explorar',
                      onPressed: () => _navigateTo(context, '/explorar'),
                    ),
                    const SizedBox(width: 8),
                    _HeaderButton(
                      icon: FontAwesomeIcons.receipt,
                      text: 'Meus Pedidos',
                      onPressed: () => _navigateToOrders(context),
                    ),
                  ],
                ],
              ),

              // Centro: Título ou Logo
              Expanded(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _navigateTo(context, '/'), // '/' deve levar para a home
                    child: title != null
                        ? Text(
                            title!,
                            textAlign: TextAlign.center,
                            style: DesignConstants.subheadingStyle.copyWith(
                              fontFamily: 'Montserrat',
                              color: AppColors.primaria,
                            ),
                          )
                        : Image.asset(
                            'assets/images/Logo_Geek_Arise.png',
                            height: constraints.maxWidth < 360 ? 36 : isDesktop ? 50 : 42,
                            errorBuilder: (_, __, ___) => FlutterLogo(size: constraints.maxWidth < 360 ? 32 : 40),
                          ),
                  ),
                ),
              ),

              // Lado Direito - MODIFICADO com StreamBuilder
              StreamBuilder<User?>(
                stream: authService.authStateChanges, // Ouve o estado de autenticação
                builder: (context, snapshot) {
                  final User? currentUser = snapshot.data;
                  bool isLoggedIn = currentUser != null;

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isDesktop && !showBackButton) ...[
                        if (isLoggedIn)
                          _HeaderButton(
                            icon: FontAwesomeIcons.rightFromBracket, // Ícone de Sair
                            text: 'Sair',
                            onPressed: () async {
                              await authService.signOut();
                              // Navega para a home após o logout para atualizar o estado
                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                            },
                          )
                        else
                          _HeaderButton(
                            icon: FontAwesomeIcons.rightToBracket,
                            text: 'Entrar',
                            onPressed: () => _navigateTo(context, '/login'),
                          ),
                        if (showCartIcon) const SizedBox(width: 8),
                      ],
                      if (showCartIcon)
                        IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.cartShopping, 
                            color: AppColors.primaria,
                            size: constraints.maxWidth < 360 ? 18 : 20,
                          ),
                          tooltip: 'Carrinho',
                          onPressed: () => _navigateTo(context, '/carrinho'),
                          iconSize: constraints.maxWidth < 360 ? 20 : 24,
                        )
                      // Lógica de espaçamento para manter o layout quando o botão de carrinho não é mostrado
                      else if (!showCartIcon && isDesktop && !showBackButton)
                         const SizedBox(width: 48) // Espaço se só o botão de Entrar/Sair estiver visível
                      else if (!showCartIcon && !isDesktop && !showBackButton)
                         const SizedBox(width: 48), // Espaço para mobile para balancear o ícone do menu
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// Classe _HeaderButton (mantida como antes)
class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const _HeaderButton({
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: FaIcon(icon, size: 18, color: AppColors.primaria),
      label: Text(
        text,
        style: DesignConstants.captionStyle.copyWith(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w500,
          color: AppColors.primaria,
          fontSize: 15,
        ),
      ),
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaria,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignConstants.mediumSpacing, 
          vertical: DesignConstants.smallSpacing + 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignConstants.borderRadius),
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered)) {
              return AppColors.hover.withAlpha(50);
            }
            if (states.contains(WidgetState.pressed)) {
              return AppColors.hover.withAlpha(80);
            }
            return null;
          },
        ),
      ),
    );
  }
}