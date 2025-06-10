import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Product>> getProducts() async {
    try {
      if (kDebugMode) {
        debugPrint('FirestoreService: Iniciando busca no Firestore...');
      }
      
      final QuerySnapshot snapshot = await _firestore
          .collection('produtos')
          .get()
          .timeout(const Duration(seconds: 10));
      
      if (kDebugMode) {
        debugPrint('FirestoreService: Documentos encontrados: ${snapshot.docs.length}');
      }
      
      if (snapshot.docs.isEmpty) {
        if (kDebugMode) {
          debugPrint('FirestoreService: Nenhum documento encontrado na coleção "products"');
        }
        return [];
      }

      List<Product> products = [];
      
      for (var doc in snapshot.docs) {
        try {
          if (kDebugMode) {
            debugPrint('FirestoreService: Processando documento: ${doc.id}');
          }
          
          final data = doc.data() as Map<String, dynamic>;
          
          // Verifica se os campos necessários existem
          if (!_hasRequiredFields(data, doc.id)) {
            continue;
          }
          
          // Gera o caminho da imagem baseado no nome do produto
          final productName = data['name']?.toString() ?? '';
          final imagePath = _getImagePath(productName);
          
          // Adiciona o caminho da imagem aos dados
          final productData = Map<String, dynamic>.from(data);
          productData['image'] = imagePath;
          
          final product = Product.fromFirestore(productData, doc.id);
          products.add(product);
          
          if (kDebugMode) {
            debugPrint('FirestoreService: Produto adicionado: ${product.name} - ${product.category} - ${product.image}');
          }
          
        } catch (e) {
          if (kDebugMode) {
            debugPrint('FirestoreService: Erro ao processar documento ${doc.id}: $e');
          }
        }
      }
      
      if (kDebugMode) {
        debugPrint('FirestoreService: Total de produtos processados: ${products.length}');
      }
      
      return products;
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FirestoreService: Erro ao buscar produtos: $e');
        if (e is FirebaseException) {
          debugPrint('FirestoreService: Código do erro Firebase: ${e.code}');
          debugPrint('FirestoreService: Mensagem do erro Firebase: ${e.message}');
        }
      }
      throw Exception('Erro ao carregar produtos do Firebase: $e');
    }
  }

  bool _hasRequiredFields(Map<String, dynamic> data, String docId) {
    final requiredFields = ['name', 'price', 'category'];
    
    for (String field in requiredFields) {
      if (!data.containsKey(field)) {
        if (kDebugMode) {
          debugPrint('FirestoreService: Campo "$field" não encontrado no documento $docId');
        }
        return false;
      }
    }
    return true;
  }

  String _getImagePath(String productName) {
    // Mapeamento de nomes de produtos para arquivos de imagem
    final Map<String, String> imageMap = {
      'Demon Slayer: Koyoharu Gotouge e O tempo': 'assets/images/products/Demon Slayer Koyoharu Gotouge e O tempo.jpg',
      'ELDEN RING Become Lord': 'assets/images/products/ELDEN RING Become Lord.webp',
      'Dragon Ball Vol. 1': 'assets/images/products/Dragon Ball Vol. 1.jpg',
      'Sakamoto Days 16': 'assets/images/products/Sakamoto Days 16.webp',
      'Mashle: Magia E Músculos Vol. 2': 'assets/images/products/Mashle Magia E Músculos Vol. 2.jpg',
      'Mashle: Magia E Músculos Vol. 3': 'assets/images/products/Mashle Magia E Músculos Vol. 3.jpg',
      'Pokémon Red, Green & Blue 02': 'assets/images/products/Pokémon Red, Green & Blue 02.jpg',
      'Pokémon FireRed E LeafGreen Vol. 1': 'assets/images/products/Pokémon FireRed E LeafGreen Vol. 1.jpg',
      'Wild Strawberry 01': 'assets/images/products/Wild Strawberry 01.jpg',
      'O Verão Em Que Hikaru Morreu 01': 'assets/images/products/O Verão Em Que Hikaru Morreu 01.jpg',
      'O Verão Em Que Hikaru Morreu 02': 'assets/images/products/O Verão Em Que Hikaru Morreu 02.jpg',
      'Katana Beast 01': 'assets/images/products/Katana Beast 01.jpg',
      'Solo Leveling 02': 'assets/images/products/Solo Leveling 02.jpg',
      'Frieren E A Jornada Para O Além Vol. 6': 'assets/images/products/Frieren E A Jornada Para O Além Vol. 6.jpg',
      'Frieren E A Jornada Para O Além Vol. 2': 'assets/images/products/Frieren E A Jornada Para O Além Vol. 2.jpg',
      'Frieren E A Jornada Para O Além Vol. 1': 'assets/images/products/Frieren E A Jornada Para O Além Vol. 1.jpg',
      'Os Vingadores 21/78': 'assets/images/products/Os Vingadores 21-78.jpg',
      'Ultimate Homem-Aranha (2024) Vol 1': 'assets/images/products/Ultimate Homem-Aranha (2024) Vol 1.jpg',
      'Gwen-Aranha Esmaga': 'assets/images/products/Gwen-Aranha Esmaga.jpg',
      'Aventuras Marvel 14': 'assets/images/products/Aventuras Marvel 14.jpg',
      'Garoto-Aranha Vol. 2': 'assets/images/products/Garoto-Aranha Vol. 2.jpg',
      'Batman: Morte Em Família - Robin Vive!': 'assets/images/products/Batman Morte Em Família - Robin Vive!.jpg',
      'Mushoku Tensei: Uma Segunda Chance Vol. 6 - Retorno': 'assets/images/products/Mushoku Tensei Uma Segunda Chance Vol. 6 - Retorno.jpg',
      'Solo Leveling Novel 02': 'assets/images/products/Solo Leveling Novel 02.jpg',
      'Solo Leveling Novel 03': 'assets/images/products/Solo Leveling Novel 03.jpg',
      'CAITLYN ARCANE LEAGUE OF LEGENDS RIOT FUNKO POP': 'assets/images/products/CAITLYN ARCANE LEAGUE OF LEGENDS RIOT FUNKO POP.jpg',
      'Funko pop Silco league of legends': 'assets/images/products/Funko pop Silco league of legends.jpg',
      'Funko Pop Arcane League Of Legends Vi': 'assets/images/products/Thunder 3 Vol.7.jpg',
      'Funko Pop Arcane MEL': 'assets/images/products/Funko Pop Arcane MEL.jpg',
      'Funko Pop Capitão américa': 'assets/images/products/Funko Pop Capitão américa.jpg',
      'Funko Pop Toy Story Jessie': 'assets/images/products/Funko Pop Toy Story Jessie.jpg',
      'Funko Pop Toy Story E. T.': 'assets/images/products/Funko Pop Toy Story E. T.jpg',
    };
    
    return imageMap[productName] ?? '';
  }

  // Método para testar a conexão
  Future<bool> testConnection() async {
    try {
      if (kDebugMode) {
        debugPrint('FirestoreService: Testando conexão com Firestore...');
      }
      await _firestore.collection('test').limit(1).get();
      if (kDebugMode) {
        debugPrint('FirestoreService: Conexão com Firestore OK');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FirestoreService: Erro na conexão com Firestore: $e');
      }
      return false;
    }
  }

  // Método para adicionar produtos de teste
  Future<void> addTestProducts() async {
    if (!kDebugMode) return;
    
    try {
             // Lista de produtos baseada no JSON original
       final List<Map<String, dynamic>> produtos = [
         {"name": "Demon Slayer: Koyoharu Gotouge e O tempo", "price": 49.90, "category": "Manga"},
         {"name": "ELDEN RING Become Lord", "price": 299.90, "category": "Game"},
         {"name": "Dragon Ball Vol. 1", "price": 34.90, "category": "Manga"},
         {"name": "Sakamoto Days 16", "price": 29.90, "category": "Manga"},
         {"name": "Mashle: Magia E Músculos Vol. 2", "price": 32.90, "category": "Manga"},
         {"name": "Mashle: Magia E Músculos Vol. 3", "price": 32.90, "category": "Manga"},
         {"name": "Pokémon Red, Green & Blue 02", "price": 39.90, "category": "Manga"},
         {"name": "Pokémon FireRed E LeafGreen Vol. 1", "price": 39.90, "category": "Manga"},
         {"name": "Wild Strawberry 01", "price": 27.90, "category": "Manga"},
         {"name": "O Verão Em Que Hikaru Morreu 01", "price": 31.90, "category": "Manga"},
         {"name": "O Verão Em Que Hikaru Morreu 02", "price": 31.90, "category": "Manga"},
         {"name": "Katana Beast 01", "price": 29.90, "category": "Manga"},
         {"name": "Solo Leveling 02", "price": 45.90, "category": "Manga"},
         {"name": "Frieren E A Jornada Para O Além Vol. 6", "price": 33.90, "category": "Manga"},
         {"name": "Frieren E A Jornada Para O Além Vol. 2", "price": 33.90, "category": "Manga"},
         {"name": "Frieren E A Jornada Para O Além Vol. 1", "price": 33.90, "category": "Manga"},
         {"name": "Os Vingadores 21/78", "price": 25.90, "category": "Comic"},
         {"name": "Ultimate Homem-Aranha (2024) Vol 1", "price": 28.90, "category": "Comic"},
         {"name": "Gwen-Aranha Esmaga", "price": 30.90, "category": "Comic"},
         {"name": "Aventuras Marvel 14", "price": 22.90, "category": "Comic"},
         {"name": "Garoto-Aranha Vol. 2", "price": 27.90, "category": "Comic"},
         {"name": "Batman: Morte Em Família - Robin Vive!", "price": 59.90, "category": "Comic"},
         {"name": "Mushoku Tensei: Uma Segunda Chance Vol. 6 - Retorno", "price": 42.90, "category": "Manga"},
         {"name": "Solo Leveling Novel 02", "price": 55.90, "category": "Novel"},
         {"name": "Solo Leveling Novel 03", "price": 55.90, "category": "Novel"},
         {"name": "CAITLYN ARCANE LEAGUE OF LEGENDS RIOT FUNKO POP", "price": 129.90, "category": "Funko Pop"},
         {"name": "Funko pop Silco league of legends", "price": 139.90, "category": "Funko Pop"},
         {"name": "Funko Pop Arcane League Of Legends Vi", "price": 129.90, "category": "Funko Pop"},
         {"name": "Funko Pop Arcane MEL", "price": 119.90, "category": "Funko Pop"},
         {"name": "Funko Pop Capitão américa", "price": 99.90, "category": "Funko Pop"},
         {"name": "Funko Pop Toy Story Jessie", "price": 89.90, "category": "Funko Pop"},
         {"name": "Funko Pop Toy Story E. T.", "price": 94.90, "category": "Funko Pop"}
       ];
      
      debugPrint('FirestoreService: Iniciando importação de ${produtos.length} produtos...');
      
      // Adicionar produtos em lotes
      final batch = _firestore.batch();
      int count = 0;
      
      for (var produto in produtos) {
        final docRef = _firestore.collection('produtos').doc();
        batch.set(docRef, {
          ...produto,
          'description': 'Produto da loja Geek Arise',
          'createdAt': FieldValue.serverTimestamp(),
        });
        count++;
        
        // Processar em lotes de 500 (limite do Firestore)
        if (count % 500 == 0 || count == produtos.length) {
          await batch.commit();
          debugPrint('FirestoreService: $count produtos processados...');
        }
      }
      
      debugPrint('FirestoreService: Importação concluída com sucesso!');
      
    } catch (e) {
      debugPrint('FirestoreService: Erro ao adicionar produtos: $e');
    }
  }
}