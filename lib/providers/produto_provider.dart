import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../services/api_service.dart';
import 'dart:developer' as developer;

class ProdutoProvider with ChangeNotifier {
  List<Produto> _produtos = [];
  List<Produto> _produtosFiltrados = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Produto> get produtos =>
      _produtosFiltrados.isEmpty ? _produtos : _produtosFiltrados;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> carregarProdutos() async {
    _isLoading = true;
    notifyListeners();

    try {
      developer.log("Carregando produtos...");
      _produtos = await ApiService.fetchProdutos();
      _produtos.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
      _produtosFiltrados = _produtos;
    } catch (e) {
      developer.log("Erro ao carregar produtos: $e");
      _errorMessage = "Erro ao carregar produtos";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filtro de produtos com base em uma string de busca
  void filtrarProdutos(String query) {
    if (query.isEmpty) {
      _produtosFiltrados = _produtos;
    } else {
      _produtosFiltrados = _produtos
          .where((produto) =>
              produto.nome.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // Método para resetar o filtro
  void resetarFiltro() {
    _produtosFiltrados = _produtos;
    notifyListeners();
  }
}
