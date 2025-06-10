import 'package:flutter/foundation.dart';

class EnderecoService extends ChangeNotifier {
  static final EnderecoService _instance = EnderecoService._internal();
  factory EnderecoService() => _instance;
  EnderecoService._internal();

  final List<Map<String, String>> _enderecos = [];
  String? _enderecoSelecionado;

  List<Map<String, String>> get enderecos => List.unmodifiable(_enderecos);
  String? get enderecoSelecionado => _enderecoSelecionado;

  List<Map<String, String>> getEnderecos() {
    return List.unmodifiable(_enderecos);
  }

  String adicionarEndereco(Map<String, String> endereco) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final enderecoComId = {
      'id': id,
      ...endereco,
    };
    _enderecos.add(enderecoComId);
    notifyListeners();
    return id;
  }

  void removerEndereco(String id) {
    _enderecos.removeWhere((endereco) => endereco['id'] == id);
    if (_enderecoSelecionado == id) {
      _enderecoSelecionado = null;
    }
    notifyListeners();
  }

  void setEnderecoSelecionado(String id) {
    _enderecoSelecionado = id;
    notifyListeners();
  }

  Map<String, String>? getEnderecoById(String id) {
    try {
      return _enderecos.firstWhere((endereco) => endereco['id'] == id);
    } catch (e) {
      return null;
    }
  }

  Map<String, String>? getEnderecoAtual() {
    if (_enderecoSelecionado == null) return null;
    return getEnderecoById(_enderecoSelecionado!);
  }

  String formatarEndereco(Map<String, String> endereco) {
    final rua = endereco['rua'] ?? '';
    final numero = endereco['numero'] ?? '';
    final complemento = endereco['complemento'] ?? '';
    final bairro = endereco['bairro'] ?? '';
    final cidade = endereco['cidade'] ?? '';
    final estado = endereco['estado'] ?? '';
    final cep = endereco['cep'] ?? '';

    String enderecoFormatado = '$rua, $numero';
    if (complemento.isNotEmpty) {
      enderecoFormatado += ', $complemento';
    }
    enderecoFormatado += ', $bairro - $cidade/$estado - CEP: $cep';

    return enderecoFormatado;
  }
} 