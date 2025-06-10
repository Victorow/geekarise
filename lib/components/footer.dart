// lib/components/footer.dart
// ignore_for_file: deprecated_member_use, avoid_debug_print

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_colors.dart';
import '../constants/design_constants.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  void _navigateTo(BuildContext context, String route) {
    Navigator.of(context).pushNamed(route);
  }

  Future<void> _launchSocialUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
      // Optionally show a SnackBar to the user
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível abrir o link: $urlString'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignConstants.borderRadius)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Container(
      decoration: BoxDecoration(
        gradient: DesignConstants.primaryGradient,
        boxShadow: DesignConstants.mediumShadow.map((shadow) => 
          BoxShadow(
            color: shadow.color,
            blurRadius: shadow.blurRadius,
            offset: const Offset(0, -4),
          )
        ).toList(),
      ),
      padding: EdgeInsets.symmetric(
        vertical: DesignConstants.extraLargeSpacing,
        horizontal: isDesktop ? DesignConstants.extraLargeSpacing + 8 : DesignConstants.largeSpacing,
      ),
      child: Column(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _navigateTo(context, '/'),
              child: Image.asset(
                'assets/images/Logo_Geek_Arise.png',
                height: 50,
                errorBuilder: (_, __, ___) => const FlutterLogo(size: 50),
              ),
            ),
          ),
          const SizedBox(height: DesignConstants.largeSpacing + 1),
          Wrap(
            spacing: DesignConstants.largeSpacing - 4,
            runSpacing: DesignConstants.mediumSpacing - 1,
            alignment: WrapAlignment.center,
            children: [
              _FooterLink(
                  text: 'Sobre Nós',
                  onTap: () => _navigateTo(context, '/sobre')),
              _FooterLink(
                  text: 'Produtos',
                  onTap: () => _navigateTo(context, '/explorar')),
              _FooterLink(
                  text: 'Contato',
                  onTap: () => _navigateTo(context, '/contato')),
              _FooterLink(
                  text: 'Blog', onTap: () => _navigateTo(context, '/blog')),
              _FooterLink(
                  text: 'Política de Privacidade',
                  onTap: () => _navigateTo(context, '/politica')),
            ],
          ),
          const SizedBox(height: DesignConstants.largeSpacing + 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: DesignConstants.largeSpacing),
              _SocialIcon(
                  icon: FontAwesomeIcons.instagram,
                  onTap: () =>
                      _launchSocialUrl(context, 'https://instagram.com')),
              // Corrected placeholder URL
              const SizedBox(width: DesignConstants.largeSpacing),
            ],
          ),
          const SizedBox(height: DesignConstants.largeSpacing + 1),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: DesignConstants.largeSpacing - 4),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white38, width: 1)),
            ),
            child: Text(
              '© $currentYear Geek Arise. Todos os direitos reservados.',
              textAlign: TextAlign.center,
              style: DesignConstants.captionStyle.copyWith(
                color: AppColors.primaria.withAlpha(200),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _FooterLink({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: AppColors.hover.withAlpha(20),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignConstants.smallSpacing, 
          vertical: DesignConstants.smallSpacing / 2,
        ),
        child: Text(
          text,
          style: DesignConstants.captionStyle.copyWith(
            color: AppColors.primaria.withAlpha(220),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SocialIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignConstants.extraLargeBorderRadius + 6),
      hoverColor: AppColors.hover.withAlpha(100),
      splashColor: AppColors.hover.withAlpha(150),
      child: Padding(
        padding: const EdgeInsets.all(DesignConstants.smallSpacing),
        child: FaIcon(
          icon,
          color: AppColors.primaria,
          size: 22,
        ),
      ),
    );
  }
}
