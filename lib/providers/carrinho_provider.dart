import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../models/pedido.dart';
import '../services/api_service.dart';

class CarrinhoProvider with ChangeNotifier {
  CarrinhoProvider() {
    _carregarPedidoEmAberto();
  }

  final Map<int, ProdutoRequest> _itensCarrinho = {};
  int? _pedidoId;

  Map<int, ProdutoRequest> get itensCarrinho => _itensCarrinho;

  double get totalCarrinho => _itensCarrinho.values.fold(
        0,
        (total, item) => total + (item.quantidade * item.precoUnitario),
      );

  int get totalProdutos => _itensCarrinho.values.fold(
        0,
        (total, item) => total + item.quantidade,
      );

  int? get pedidoId => _pedidoId;

  Future<void> adicionarAoCarrinho(Produto produto) async {
    try {
      if (_pedidoId == null) {
        await _criarPedido();
      }

      if (_itensCarrinho.containsKey(produto.id)) {
        // Atualizar quantidade do item já existente
        final itemAtual = _itensCarrinho[produto.id]!;
        itemAtual.quantidade++;
        await ApiService.atualizarItemDoPedido(itemAtual, _pedidoId!);
      } else {
        // Adicionar um novo item
        final novoItem = ProdutoRequest(
          itemPedidoId: 0, // Inicializamos com 0, pois não temos o ID ainda
          pedidoId: _pedidoId!,
          produtoId: produto.id,
          quantidade: 1,
          precoUnitario: produto.preco,
        );
        await ApiService.adicionarItemAoPedido(novoItem, _pedidoId!);
        await _recarregarItensDoPedido(); // Recarregar o pedido para atualizar os IDs
      }
      
      await _atualizarValorTotalPedido(); 
      notifyListeners();
    } catch (e) {
      developer.log("Erro ao adicionar ao carrinho: $e");
    }
  }

  Future<void> _recarregarItensDoPedido() async {
    try {
      final pedido = await ApiService.buscarPedidoPorId(_pedidoId!);
      _carregarItensDoPedido(pedido);
    } catch (e) {
      developer.log("Erro ao recarregar itens do pedido: $e");
    }
  }

  Future<void> removerDoCarrinho(Produto produto) async {
    try {
      if (!_itensCarrinho.containsKey(produto.id)) return;

      final itemAtual = _itensCarrinho[produto.id]!;

      if (itemAtual.quantidade > 1) {
        // Reduz a quantidade
        itemAtual.quantidade--;
        await ApiService.atualizarItemDoPedido(itemAtual, _pedidoId!);
      } else {
        // Remove o item do pedido
        await ApiService.deletarItemDoPedido(
            itemAtual.itemPedidoId, produto.id);
        _itensCarrinho.remove(produto.id);
      }

      await _atualizarValorTotalPedido(); // Sincronizar o total com o backend
      notifyListeners();
    } catch (e) {
      developer.log("Erro ao remover do carrinho: $e");
    }
  }

Future<void> _atualizarValorTotalPedido() async {
  try {
    if (_pedidoId == null) return;

    final totalPedido = _itensCarrinho.values.fold<double>(
      0,
      (total, item) => total + (item.quantidade * item.precoUnitario),
    );

    final pedidoAtual = await ApiService.buscarPedidoPorId(_pedidoId!);

    final pedidoAtualizado = Pedido(
      id: pedidoAtual.id,
      clienteId: pedidoAtual.clienteId,
      clienteNome: pedidoAtual.clienteNome,
      dataPedido: pedidoAtual.dataPedido,
      totalPedido: totalPedido,
      status: pedidoAtual.status,
      itensPedido: pedidoAtual.itensPedido, // Preserva os itens
    );

    await ApiService.atualizarPedido(pedidoAtualizado);

    _carregarItensDoPedido(pedidoAtual);

    notifyListeners();
  } catch (e) {
    developer.log("Erro ao atualizar valor total do pedido: $e");
  }
}


  Future<void> limparCarrinho() async {
    try {
      for (var item in _itensCarrinho.values) {
        await ApiService.deletarItemDoPedido(item.itemPedidoId, item.produtoId);
      }
      _itensCarrinho.clear();
      _pedidoId = null;
      notifyListeners();
    } catch (e) {
      developer.log("Erro ao limpar carrinho: $e");
    }
  }

  Future<void> _carregarPedidoEmAberto() async {
    try {
      _pedidoId = await ApiService.getPedidoAbertoId();
      if (_pedidoId != null) {
        final pedido = await ApiService.buscarPedidoPorId(_pedidoId!);
        _carregarItensDoPedido(pedido);
      }
    } catch (e) {
      developer.log("Erro ao carregar pedido em aberto: $e");
    }
  }

  void _carregarItensDoPedido(Pedido pedido) {
    for (var item in pedido.itensPedido) {
      _itensCarrinho[item.produtoId] = ProdutoRequest(
        itemPedidoId: item.id,
        pedidoId: pedido.id,
        produtoId: item.produtoId,
        quantidade: item.quantidade,
        precoUnitario: item.precoUnitario,
      );
    }
    notifyListeners();
  }

  Future<void> _criarPedido() async {
    try {
      _pedidoId =
          await ApiService.criarNovoPedido(_itensCarrinho.values.toList());
      notifyListeners();
    } catch (e) {
      developer.log("Erro ao criar novo pedido: $e");
    }
  }
}
