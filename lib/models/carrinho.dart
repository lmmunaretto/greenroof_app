import 'produto.dart';

class Carrinho {
  Carrinho({required this.itens});

  factory Carrinho.fromJson(Map<String, dynamic> json) {
    return Carrinho(
      itens: (json['itens'] as List)
          .map((itemJson) => ItemCarrinho.fromJson(itemJson))
          .toList(),
    );
  }

  final List<ItemCarrinho> itens;

  double get totalCarrinho {
    return itens.fold(0, (total, item) => total + (item.produto.preco * item.quantidade));
  }

  int get quantidadeTotal {
    return itens.fold(0, (total, item) => total + item.quantidade);
  }
}

class ItemCarrinho {
  ItemCarrinho({required this.produto, required this.quantidade});

  factory ItemCarrinho.fromJson(Map<String, dynamic> json) {
    return ItemCarrinho(
      produto: Produto.fromJson(json['produto']),
      quantidade: json['quantidade'],
    );
  }

  final Produto produto;
  int quantidade;

  double get totalItem => produto.preco * quantidade;

  Map<String, dynamic> toJson() {
    return {
      'produto': produto.toJson(),
      'quantidade': quantidade,
    };
  }
}
