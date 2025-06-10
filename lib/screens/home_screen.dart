// lib/screens/home_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../app_colors.dart';
import '../components/header.dart';
import '../components/footer.dart';
import '../constants/design_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  void _navigateTo(BuildContext context, String route) {
    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < DesignConstants.mobileBreakpoint;
    final isTablet = size.width >= DesignConstants.mobileBreakpoint && size.width < DesignConstants.tabletBreakpoint;
    final isDesktop = size.width >= DesignConstants.tabletBreakpoint;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: !isDesktop ? _buildMobileDrawer(context) : null,
      body: Column(
        children: [
          const CustomHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeroSection(context, isMobile, isTablet, isDesktop),
                  const SizedBox(height: DesignConstants.sectionSpacing),
                  _buildCategoriesSection(context, isMobile, isTablet, isDesktop),
                  const SizedBox(height: DesignConstants.sectionSpacing),
                  _buildFeaturesSection(context, isMobile, isTablet, isDesktop),
                  const SizedBox(height: DesignConstants.sectionSpacing),
                  _buildTrendingSection(context, isMobile, isTablet, isDesktop),
                  const SizedBox(height: DesignConstants.sectionSpacing),
                  _buildNewsSection(context, isMobile, isTablet, isDesktop),
                  const SizedBox(height: DesignConstants.sectionSpacing),
                  const CustomFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primaria,
            ),
            child: Text(
              'Geek Arise',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildDrawerItem(FontAwesomeIcons.rocket, 'Explorar', '/explorar'),
          _buildDrawerItem(FontAwesomeIcons.rightToBracket, 'Entrar', '/login'),
          _buildDrawerItem(FontAwesomeIcons.cartShopping, 'Carrinho', '/carrinho'),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, String route) {
    return ListTile(
      leading: FaIcon(icon, color: AppColors.primaria),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.pop(context);
        _navigateTo(context, route);
      },
    );
  }

  Widget _buildConstrainedContent({required Widget child, bool isMobile = false}) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : DesignConstants.maxContentWidth),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.0 : 24.0,
        vertical: 24.0,
      ),
      child: child,
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isMobile, bool isTablet, bool isDesktop) {
    return _buildConstrainedContent(
      isMobile: isMobile,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Imagem de fundo
              Positioned.fill(
                child: Image.asset(
                  'assets/images/animefundo.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              // Filtro escuro para legibilidade
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black54, Colors.black87],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: isMobile
                    ? _buildHeroMobileLayout(context)
                    : _buildHeroDesktopLayout(context, isDesktop),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroContent(context, true),
        const SizedBox(height: 32),
        _buildHeroFeatures(),
      ],
    );
  }

  Widget _buildHeroDesktopLayout(BuildContext context, bool isDesktop) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildHeroContent(context, false),
        ),
        const SizedBox(width: 64),
        Expanded(
          flex: 2,
          child: _buildHeroImage(),
        ),
      ],
    );
  }

  Widget _buildHeroContent(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bem-vindo à\nGeek Arise!',
          style: TextStyle(
            fontSize: isMobile ? 32 : 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
            shadows: const [
              Shadow(
                offset: Offset(2, 2),
                blurRadius: 4,
                color: Colors.black87,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Descubra o melhor do universo otaku com produtos originais e de qualidade.',
          style: TextStyle(
            fontSize: isMobile ? 16 : 20,
            color: Colors.white,
            height: 1.5,
            shadows: const [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Colors.black87,
              ),
            ],
          ),
        ),
        if (!isMobile) const SizedBox(height: 32),
        if (!isMobile) _buildHeroFeatures(),
        const SizedBox(height: 40),
        _buildHeroButton(context),
      ],
    );
  }

  Widget _buildHeroFeatures() {
    return Row(
      children: [
        Expanded(
          child: _buildFeatureItem(
            FontAwesomeIcons.truckFast,
            'Entrega Nacional',
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildFeatureItem(
            FontAwesomeIcons.shieldHalved,
            'Produtos Originais',
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: FaIcon(icon, size: 16, color: AppColors.primaria),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 2,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _navigateTo(context, '/explorar'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaria,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      child: const Text(
        'Explorar Produtos',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      height: 500,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/Frame 5.png',
          height: 500,
          width: double.infinity,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
                         return Container(
               height: 500,
               decoration: BoxDecoration(
                 borderRadius: BorderRadius.circular(16),
                 color: Colors.white.withOpacity(0.5),
               ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported, size: 64, color: Colors.black26),
                    SizedBox(height: 8),
                    Text(
                      'Erro ao carregar imagem',
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context, bool isMobile, bool isTablet, bool isDesktop) {
    return _buildConstrainedContent(
      isMobile: isMobile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Nossas Categorias'),
          const SizedBox(height: 24),
          _buildCategoriesGrid(isMobile, isTablet, isDesktop),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(bool isMobile, bool isTablet, bool isDesktop) {
    final categories = [
      {
        'title': 'Roupas & Acessórios',
        'subtitle': 'Novo',
        'description': 'Camisetas, moletons e acessórios exclusivos',
        'image': 'assets/images/actionfigures.jpg',
        'icon': FontAwesomeIcons.shirt,
      },
      {
        'title': 'Mangás & Novels',
        'subtitle': 'Popular',
        'description': 'Os melhores títulos em português',
        'image': 'assets/images/lancamentoManga.webp',
        'icon': FontAwesomeIcons.book,
      },
      {
        'title': 'Action Figures',
        'subtitle': 'Limitado',
        'description': 'Figuras colecionáveis autênticas',
        'image': 'assets/images/explorarProdutos.jpg',
        'icon': FontAwesomeIcons.robot,
      },
      {
        'title': '20% OFF',
        'subtitle': 'Oferta',
        'description': 'Desconto especial para novos clientes',
        'image': 'assets/images/ofertasEspeciais.jpg',
        'icon': FontAwesomeIcons.tags,
      },
    ];

    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 4);
    final childAspectRatio = isMobile ? 1.2 : (isTablet ? 0.9 : 0.85);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: DesignConstants.cardSpacing,
        mainAxisSpacing: DesignConstants.cardSpacing,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _buildCategoryCard(categories[index]);
      },
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        image: DecorationImage(
          image: AssetImage(category['image'] as String),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.4),
            BlendMode.darken,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category['subtitle'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                                 FaIcon(
                   category['icon'] as IconData,
                   size: 24,
                   color: Colors.white,
                   shadows: const [
                     Shadow(
                       offset: Offset(1, 1),
                       blurRadius: 3,
                       color: Colors.black54,
                     ),
                   ],
                 ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              category['title'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 3,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category['description'],
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 3,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _navigateTo(context, '/explorar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Ver Produtos',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isMobile, bool isTablet, bool isDesktop) {
    return _buildConstrainedContent(
      isMobile: isMobile,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaria.withOpacity(0.1),
              AppColors.secundaria.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Por que escolher a Geek Arise?'),
            const SizedBox(height: 24),
            _buildFeaturesGrid(isMobile, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesGrid(bool isMobile, bool isTablet) {
    final features = [
      {
        'icon': FontAwesomeIcons.solidCircleCheck,
        'title': 'Produtos Originais',
        'description': '100% autênticos e licenciados',
      },
      {
        'icon': FontAwesomeIcons.truck,
        'title': 'Entrega Rápida',
        'description': 'Envio para todo o Brasil',
      },
      {
        'icon': FontAwesomeIcons.headset,
        'title': 'Suporte 24/7',
        'description': 'Atendimento especializado',
      },
      {
        'icon': FontAwesomeIcons.mapPin,
        'title': 'Loja Nacional',
        'description': 'Presença real no mercado otaku',
      },
    ];

    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 4);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: isMobile ? 4 : (isTablet ? 2.5 : 2.2),
        crossAxisSpacing: DesignConstants.cardSpacing,
        mainAxisSpacing: DesignConstants.cardSpacing,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaria.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                                 child: FaIcon(
                   feature['icon'] as IconData,
                   color: AppColors.primaria,
                   size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                                         Text(
                       feature['title'] as String,
                       style: const TextStyle(
                         fontWeight: FontWeight.bold,
                         fontSize: 14,
                         color: Colors.black87,
                       ),
                     ),
                     const SizedBox(height: 4),
                     Text(
                       feature['description'] as String,
                       style: const TextStyle(
                         fontSize: 12,
                         color: Colors.black54,
                       ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrendingSection(BuildContext context, bool isMobile, bool isTablet, bool isDesktop) {
    return _buildConstrainedContent(
      isMobile: isMobile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Em Alta'),
          const SizedBox(height: 24),
          _buildHorizontalCarousel(_getTrendingItems(), isMobile),
        ],
      ),
    );
  }

  Widget _buildNewsSection(BuildContext context, bool isMobile, bool isTablet, bool isDesktop) {
    return _buildConstrainedContent(
      isMobile: isMobile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Últimas Notícias'),
          const SizedBox(height: 24),
          _buildHorizontalCarousel(_getNewsItems(), isMobile),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildHorizontalCarousel(List<Map<String, String>> items, bool isMobile) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: isMobile ? 16.0 : 8.0, right: isMobile ? 16.0 : 8.0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: isMobile ? MediaQuery.of(context).size.width * 0.8 : 320,
            margin: const EdgeInsets.only(right: DesignConstants.cardSpacing),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              image: DecorationImage(
                image: AssetImage(item['image']!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item['tag']!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    item['title']!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['description']!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _navigateTo(context, '/produto'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Saiba Mais',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 3,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Map<String, String>> _getTrendingItems() {
    return [
      {
        'title': 'Novos Mangás',
        'description': 'Últimos lançamentos da temporada',
        'tag': 'Novo',
        'image': 'assets/images/emAlta2.webp',
      },
      {
        'title': 'Action Figures',
        'description': 'Coleções limitadas e exclusivas',
        'tag': 'Limitado',
        'image': 'assets/images/emAlta3.jpg',
      },
      {
        'title': 'Roupas Exclusivas',
        'description': 'Designs únicos para verdadeiros otakus',
        'tag': 'Exclusivo',
        'image': 'assets/images/emAlta4.jpg',
      },
      {
        'title': 'Acessórios',
        'description': 'Chaveiros, pins e muito mais',
        'tag': 'Popular',
        'image': 'assets/images/emalta5.png',
      },
    ];
  }

  List<Map<String, String>> _getNewsItems() {
    return [
      {
        'title': 'Nova Temporada de Kaiju N.° 8',
        'description': 'Episódio final já disponível',
        'tag': 'Anime',
        'image': 'assets/images/emAlta1.jpg',
      },
      {
        'title': 'Blue Lock PXG VS BASTARD MUNCHEN',
        'description': 'O volume final da série já chegou',
        'tag': 'Mangá',
        'image': 'assets/images/emAlta7.jpg',
      },
      {
        'title': 'Evento de Cosplay 2024',
        'description': 'Participe do maior evento otaku do ano',
        'tag': 'Evento',
        'image': 'assets/images/eventos.webp',
      },
      {
        'title': 'No Game No Life terá continuação?',
        'description': 'Rumores já estão circulando',
        'tag': 'Filme',
        'image': 'assets/images/nogame.webp',
      },
    ];
  }
}

// CustomSearchDelegate permanece igual
class CustomSearchDelegate extends SearchDelegate<String?> {
  final List<String> searchTerms = [
    "Naruto", "One Piece", "Action Figure", "Chaveiro", "Moletom", "Cosplay",
    "Attack on Titan", "Demon Slayer", "Jujutsu Kaisen", "Tokyo Ghoul"
  ];

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      scaffoldBackgroundColor: AppColors.lilasClaro,
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: AppColors.primaria,
        iconTheme: const IconThemeData(color: AppColors.texto),
        toolbarTextStyle: const TextStyle(color: AppColors.texto, fontSize: 20),
        titleTextStyle: const TextStyle(color: AppColors.texto, fontSize: 20),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: AppColors.texto.withAlpha(150)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.secundaria)),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.texto.withAlpha(100))),
      ),
      textTheme: theme.textTheme.copyWith(
        titleMedium: const TextStyle(color: AppColors.texto),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          tooltip: "Limpar",
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      tooltip: "Voltar",
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Digite algo para buscar.', style: TextStyle(color: AppColors.cinzaPadrao)));
    }
    
    final List<String> matchQuery = searchTerms
        .where((term) => term.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (matchQuery.isEmpty) {
      return Center(child: Text('Nenhum resultado para: "$query"', style: const TextStyle(color: AppColors.cinzaPadrao)));
    }

    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        final result = matchQuery[index];
        return ListTile(
          title: Text(result, style: const TextStyle(color: AppColors.primaria)),
          onTap: () {
            close(context, result);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<String> suggestionList = query.isEmpty
        ? searchTerms.take(5).toList()
        : searchTerms
            .where((term) => term.toLowerCase().startsWith(query.toLowerCase()))
            .toList();

    if (suggestionList.isEmpty && query.isNotEmpty) {
      return const Center(child: Text('Nenhuma sugestão encontrada.', style: TextStyle(color: AppColors.cinzaPadrao)));
    }
    
    if (query.isEmpty) {
      return const Center(child: Text('Digite para ver sugestões de produtos.', style: TextStyle(color: AppColors.cinzaPadrao)));
    }

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        final suggestion = suggestionList[index];
        return ListTile(
          title: Text(suggestion, style: const TextStyle(color: AppColors.primaria)),
          leading: const Icon(Icons.search, color: AppColors.cinzaPadrao),
          onTap: () {
            query = suggestion;
            showResults(context);
          },
        );
      },
    );
  }
}