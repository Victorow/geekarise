// lib/screens/explore_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;

import '../components/header.dart'; // Mantenha seus imports corretos
import '../models/product.dart';
import '../app_colors.dart';
import '../services/firestore_service.dart'; // Importa o serviço
import '../services/cart_service.dart'; // Importa o serviço de carrinho
import '../constants/design_constants.dart';

// REMOVIDO: 'package:cloud_firestore/cloud_firestore.dart' era desnecessário aqui.

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // --- DADOS E VARIÁVEIS ---
  final List<String> _categories = ['Manga', 'Comic', 'Novel', 'Funko Pop'];
  Map<String, List<Product>> _productsByCategory = {};
  final Map<String, ScrollController> _scrollControllers = {};
  final Map<String, int> _currentDotIndices = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  double? _minPrice;
  double? _maxPrice;

  // --- CONSTANTES DE LAYOUT PADRONIZADAS ---
  static const int _itemsPerCarouselPage = 4;
  static const double _productCardWidth = 180.0;
  static const double _productCardHorizontalSpacing = 16.0;
  static const double _arrowButtonWidth = 48.0;
  final int _dotsToDisplayFixedCount = 4;

  // --- FIREBASE ---
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<Product>> _loadProductsFuture;

  // --- MÉTODOS DE CICLO DE VIDA E LÓGICA ---
  @override
  void initState() {
    super.initState();
    _loadProductsFuture = _firestoreService.getProducts();
    _loadProductsFuture.then((products) {
        if (products.isEmpty && kDebugMode) {
          // Se não há produtos, importa os dados de teste
          _firestoreService.addTestProducts().then((_) {
            // Recarrega os produtos após a importação
            _loadProductsFuture = _firestoreService.getProducts();
            _loadProductsFuture.then((newProducts) {
              _processFetchedProducts(newProducts);
            });
          });
        } else {
          _processFetchedProducts(products);
        }
    });

    // CORRIGIDO: Inicializa controllers E adiciona listeners diretamente.
    for (final category in _categories) {
      _scrollControllers[category] = ScrollController();
      _currentDotIndices[category] = 0;
      // Adiciona o listener aqui. _updateDotIndicator já verifica se há produtos.
      _scrollControllers[category]!.addListener(() => _updateDotIndicator(category));
    }
  }

  // CORRIGIDO: Simplificado para apenas processar e chamar setState.
  void _processFetchedProducts(List<Product> allProducts) {
    
    Map<String, List<Product>> tempMap = {};
    for (var category in _categories) {
      tempMap[category] = allProducts
          .where((product) => product.category == category)
          .toList();
    }
    
    if (mounted) {
      setState(() {
        _productsByCategory = tempMap;
      });
    }
  }

  // _updateDotIndicator, dispose, _scrollCategory (mantidos como antes)
  void _updateDotIndicator(String category) {
    final controller = _scrollControllers[category];
    if (controller == null || !controller.hasClients || !mounted) return;

    final products = _productsByCategory[category] ?? [];
    if (products.isEmpty) return; // <-- Esta linha já garante a segurança

    int numLogicalPages = (products.length / _itemsPerCarouselPage).ceil();
    if (numLogicalPages <= 0) numLogicalPages = 1;

    int dotsToActuallyRender = math.min(numLogicalPages, _dotsToDisplayFixedCount);
    int newIndex = 0;

    if (controller.position.maxScrollExtent > 0 && dotsToActuallyRender > 1) {
      double pageFraction = controller.offset / controller.position.maxScrollExtent;
      newIndex = (pageFraction * (dotsToActuallyRender - 1)).round();
    }

    newIndex = newIndex.clamp(0, math.max(0, dotsToActuallyRender - 1));

    if (_currentDotIndices[category] != newIndex) {
      setState(() {
        _currentDotIndices[category] = newIndex;
      });
    }
  }

  @override
  void dispose() {
    _scrollControllers.forEach((_, controller) => controller.dispose());
    _searchController.dispose();
    super.dispose();
  }

  void _scrollCategory(String category, bool forward) {
      final controller = _scrollControllers[category];
      if (controller != null && controller.hasClients) {
          const double itemsToScrollPerPage = _itemsPerCarouselPage - 1;
          const double scrollAmount = (_productCardWidth + _productCardHorizontalSpacing) * itemsToScrollPerPage;

          final double currentOffset = controller.offset;
          final double maxScroll = controller.position.maxScrollExtent;
          double targetOffset = forward
              ? math.min(currentOffset + scrollAmount, maxScroll)
              : math.max(currentOffset - scrollAmount, 0.0);

          controller.animateTo(
              targetOffset,
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeInOutCubic,
          );
      }
  }

  List<Product> _getFilteredProducts(List<Product> products) {
    return products.where((product) {
      bool matchesSearch = _searchQuery.isEmpty || 
          product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesCategory = _selectedCategory == null || 
          product.category == _selectedCategory;
      bool matchesPrice = (_minPrice == null || product.price >= _minPrice!) &&
          (_maxPrice == null || product.price <= _maxPrice!);
      
      return matchesSearch && matchesCategory && matchesPrice;
    }).toList();
  }

  void _showFilterDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 16,
          insetPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16.0 : 40.0,
            vertical: 24.0,
          ),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxWidth: isSmallScreen ? double.infinity : 400,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: DesignConstants.primaryGradient,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    gradient: DesignConstants.primaryGradient,
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.filter_list_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Filtrar Produtos',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Categoria',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('Todas as categorias')),
                            ..._categories.map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            )),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedCategory = value);
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Faixa de Preço',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Preço Mínimo',
                                  border: InputBorder.none,
                                  prefixText: 'R\$ ',
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() => _minPrice = double.tryParse(value));
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Preço Máximo',
                                  border: InputBorder.none,
                                  prefixText: 'R\$ ',
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() => _maxPrice = double.tryParse(value));
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Actions - Melhor responsividade mobile
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isSmallScreen = constraints.maxWidth < 400;
                          
                          if (isSmallScreen) {
                            // Layout vertical para telas pequenas
                            return Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedCategory = null;
                                        _minPrice = null;
                                        _maxPrice = null;
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: AppColors.primaria),
                                      foregroundColor: AppColors.primaria,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Limpar Filtros',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      this.setState(() {});
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaria,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 4,
                                    ),
                                    child: const Text(
                                      'Aplicar Filtros',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            // Layout horizontal para telas maiores
                            return Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedCategory = null;
                                        _minPrice = null;
                                        _maxPrice = null;
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: AppColors.primaria),
                                      foregroundColor: AppColors.primaria,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Limpar Filtros',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      this.setState(() {});
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaria,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 4,
                                    ),
                                    child: const Text(
                                      'Aplicar Filtros',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS DE CONSTRUÇÃO ---

  @override
  Widget build(BuildContext context) {
      final size = MediaQuery.of(context).size;
      final isMobile = size.width < DesignConstants.mobileBreakpoint;

      return Scaffold(
          backgroundColor: Colors.grey[50],
          body: Column(
              children: [
                  const CustomHeader(showBackButton: true, title: null, showCartIcon: true),
                  Expanded(
                      child: Container(
                          width: double.infinity,
                          constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : DesignConstants.maxContentWidth),
                          padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 16.0 : 24.0,
                              vertical: 24.0,
                          ),
                          child: Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [
                                          DesignConstants.primaryCardColor,
                                          DesignConstants.secondaryCardColor.withOpacity(0.7),
                                      ],
                                  ),
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
                                  child: FutureBuilder<List<Product>>(
                                          future: _loadProductsFuture,
                                          builder: (context, snapshot) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                  return const Center(child: CircularProgressIndicator());
                                              }
                                              if (snapshot.hasError) {
                                                  return Center(child: Text('Erro ao carregar produtos: ${snapshot.error}'));
                                              }
                                              // Se não há dados, MAS _productsByCategory JÁ TEM (de uma carga anterior), mostra.
                                              // Se ambos estão vazios, mostra msg.
                                              bool hasLoadedData = _productsByCategory.values.any((list) => list.isNotEmpty);
                                              if ((!snapshot.hasData || snapshot.data!.isEmpty) && !hasLoadedData) {
                                                  return const Center(child: Text('Nenhum produto encontrado.'));
                                              }
                                              // Constrói a lista (seja com dados novos ou antigos)
                                              return _buildProductList(isMobile);
                                          },
                                      ),
                                  ),
                              ),
                          ),
                      ),
                  ],
              ),
          );
  }

  Widget _buildProductList(bool isMobile) {
    final horizontalPadding = isMobile ? 16.0 : 24.0;
    
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 16.0,
          ),
                        child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Explorar Produtos',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Pesquisar produtos...',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            prefixIcon: const Icon(Icons.search, color: AppColors.primaria),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: _showFilterDialog,
                        icon: const Icon(Icons.filter_list_rounded, size: 24),
                        color: AppColors.primaria,
                        tooltip: 'Filtros',
                      ),
                    ],
                  ),
                ],
              ),
        ),
        ..._categories.map((category) {
          final products = _getFilteredProducts(_productsByCategory[category] ?? []);
          if (products.isEmpty) return const SizedBox.shrink();
          return _buildCategorySection(category, horizontalPadding);
        }),
      ],
    );
  }

  Widget _buildArrowButton(String category, bool isRightArrow) {
      return Material(
          color: Colors.black.withOpacity(0.08),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: IconButton(
              icon: Icon(
                  isRightArrow ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_new_rounded,
                  color: AppColors.primaria.withOpacity(0.85),
                  size: 18,
              ),
              padding: EdgeInsets.zero,
              splashRadius: 20,
              constraints: const BoxConstraints(minWidth: _arrowButtonWidth, minHeight: _arrowButtonWidth),
              onPressed: () => _scrollCategory(category, isRightArrow),
              tooltip: isRightArrow ? 'Próximos' : 'Anteriores',
          ),
      );
  }

  Widget _buildCategorySection(String category, double horizontalContentPadding) {
      String displayCategory;
      switch (category) {
        case 'Manga':
          displayCategory = 'Mangas:';
          break;
        case 'Comic':
          displayCategory = 'Comics:';
          break;
        case 'Novel':
          displayCategory = 'Novels:';
          break;
        case 'Funko Pop':
          displayCategory = 'Action figure:';
          break;
        default:
          displayCategory = '$category:';
      }
      final products = _getFilteredProducts(_productsByCategory[category] ?? []);
      if (products.isEmpty) return const SizedBox.shrink();

      final scrollController = _scrollControllers[category]!;
      final currentDot = _currentDotIndices[category] ?? 0;
      int numLogicalPages = (products.length / _itemsPerCarouselPage).ceil();
      if (numLogicalPages <= 0) numLogicalPages = 1;
      final int dotsToActuallyRender = math.min(numLogicalPages, _dotsToDisplayFixedCount);
      bool showArrows = products.length > _itemsPerCarouselPage;

      return Container(
          margin: const EdgeInsets.only(bottom: DesignConstants.sectionSpacing),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalContentPadding, vertical: 16),
                      child: Text(
                          displayCategory, 
                          style: const TextStyle(
                              fontSize: 24, 
                              fontWeight: FontWeight.bold, 
                              color: Colors.black87
                          )
                      ),
                  ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                      if (showArrows)
                          _buildArrowButton(category, false)
                      else
                          const SizedBox(width: _arrowButtonWidth),
                      Expanded(
                          child: SizedBox(
                              height: 230,
                              child: ListView.builder(
                                  controller: scrollController,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: products.length,
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  itemBuilder: (context, index) => Padding(
                                      padding: EdgeInsets.only(left: index == 0 ? 0 : _productCardHorizontalSpacing),
                                      child: ProductCard(product: products[index]),
                                  ),
                              ),
                          ),
                      ),
                      if (showArrows)
                          _buildArrowButton(category, true)
                      else
                          const SizedBox(width: _arrowButtonWidth),
                  ],
              ),
              if (dotsToActuallyRender > 1)
                  Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 32),
                      child: Center(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(dotsToActuallyRender, (index) => Container(
                                  width: 9, height: 9,
                                  margin: const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: currentDot == index ? AppColors.primaria : AppColors.primaria.withOpacity(0.25),
                                  ),
                              )),
                          ),
                      ),
                  ),
              if (dotsToActuallyRender <= 1) const SizedBox(height: 32 + 16 + 9), // sum of paddings and dot height
              ],
          ),
      );
  }
}

// --- CLASSE ProductCard (Sem alterações significativas na estrutura, apenas o _addToCart completo) ---
class ProductCard extends StatelessWidget {
    final Product product;

    const ProductCard({super.key, required this.product});

    @override
    Widget build(BuildContext context) {
        return SizedBox(
            width: _ExploreScreenState._productCardWidth, // Acessando a constante estática
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    Expanded(
                        child: Container(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [
                                        DesignConstants.primaryCardColor,
                                        DesignConstants.secondaryCardColor.withOpacity(0.8),
                                    ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                    ),
                                ],
                            ),
                            child: Stack(
                                fit: StackFit.expand,
                                children: [
                                    Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: ClipRRect(
                                            borderRadius: BorderRadius.circular(6.0),
                                            child: product.image.isNotEmpty
                                                ? (product.image.startsWith('http')
                                                    ? Image.network(
                                                        product.image,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_, __, ___) => const Icon(
                                                            Icons.broken_image_outlined,
                                                            size: 36, color: AppColors.lightGreyishPurple),
                                                      )
                                                    : Image.asset(
                                                        product.image,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_, __, ___) => const Icon(
                                                            Icons.broken_image_outlined,
                                                            size: 36, color: AppColors.lightGreyishPurple),
                                                      )
                                                  )
                                                : const Icon(Icons.image_not_supported_outlined,
                                                    size: 36, color: AppColors.lightGreyishPurple),
                                        ),
                                    ),
                                    Positioned(
                                        top: 12, right: 12,
                                        child: Container(
                                            decoration: BoxDecoration(
                                                color: AppColors.primaria,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.black.withOpacity(0.2),
                                                        blurRadius: 4,
                                                        offset: const Offset(0, 2),
                                                    ),
                                                ],
                                            ),
                                            child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                    customBorder: const CircleBorder(),
                                                    onTap: () => _addToCart(context, product),
                                                    child: Container(
                                                        width: 36, height: 36,
                                                        alignment: Alignment.center,
                                                        child: const Icon(Icons.add_rounded, size: 20, color: Colors.white),
                                                    ),
                                                ),
                                            ),
                                        ),
                                    ),
                                    Positioned(
                                        bottom: 0, left: 0, right: 0,
                                        child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.75),
                                                borderRadius: const BorderRadius.only(
                                                    bottomLeft: Radius.circular(11),
                                                    bottomRight: Radius.circular(11),
                                                ),
                                            ),
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                    Text(product.name,
                                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5),
                                                        maxLines: 2, overflow: TextOverflow.ellipsis),
                                                    const SizedBox(height: 2),
                                                    Text('R\$${product.price.toStringAsFixed(2)}',
                                                        style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
                                                ],
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

    void _addToCart(BuildContext context, Product product) {
        final cartService = CartService();
        cartService.addProduct(product);
        
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('${product.name} adicionado ao carrinho!'),
                backgroundColor: AppColors.primaria,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignConstants.borderRadius)),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 2),
                action: SnackBarAction(
                  label: 'Ver Carrinho',
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pushNamed('/carrinho');
                  },
                ),
            ),
        );
    }
}