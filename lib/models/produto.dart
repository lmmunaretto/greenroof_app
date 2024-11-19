class Produto {
  Produto({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.quantidade,
    required this.preco,
    required this.tipo,
    this.limiteMinimoEstoque = 0,
    this.informacoesNutricionais,
    this.imagemUrl = 'assets/images/default.jpg',
  }) {
    imagemUrl = _getAssetImagePath(nome) ?? imagemUrl;
  }

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      quantidade: json['quantidade'],
      preco: json['preco'].toDouble(),
      tipo: json['tipo'],
      limiteMinimoEstoque: json['limiteMinimoEstoque'] ?? 0,
      informacoesNutricionais: json['informacoesNutricionais'] != null
          ? InformacoesNutricionais.fromJson(json['informacoesNutricionais'])
          : null,
      imagemUrl: json['imagemUrl'] ?? 'assets/images/default.jpg',
    );
  }

  final String descricao;
  final int id;
  String imagemUrl;
  final InformacoesNutricionais? informacoesNutricionais;
  final int limiteMinimoEstoque;
  final String nome;
  final double preco;
  final int quantidade;
  final String tipo;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'quantidade': quantidade,
      'preco': preco,
      'tipo': tipo,
      'limiteMinimoEstoque': limiteMinimoEstoque,
      'informacoesNutricionais': informacoesNutricionais?.toJson(),
      'imagemUrl': imagemUrl,
    };
  }

  static String? _getAssetImagePath(String productName) {
    final firstWord = productName.split(' ')[0].toLowerCase();
    final assetImages = {
      'maracujá': 'assets/images/maracuja.jpg',
      'maçã': 'assets/images/maca.jpg',
      'manga': 'assets/images/manga.jpg',
      'banana': 'assets/images/banana.jpg',
      'cenoura': 'assets/images/cenoura.jpg',
      'berinjela': 'assets/images/berinjela.jpg',
      'limão': 'assets/images/limao.jpg',
      'tomate': 'assets/images/tomate.jpg',
      'alface': 'assets/images/alface.jpg',
      'couve': 'assets/images/couve.jpg',
      'morango': 'assets/images/morango.jpg',
      'melancia': 'assets/images/melancia.jpg',
      'laranja': 'assets/images/laranja.jpg',
      'ameixa': 'assets/images/ameixa.jpg',
      'kiwi': 'assets/images/kiwi.jpg',
      'melão': 'assets/images/melao.jpg',
      'uva': 'assets/images/uva.jpg'
    };
    return assetImages[firstWord];
  }
}

class InformacoesNutricionais {
  InformacoesNutricionais({
    required this.id,
    required this.calorias,
    required this.proteinas,
    required this.carboidratos,
    required this.gorduras,
    required this.fibras,
    required this.produtoId,
  });

  factory InformacoesNutricionais.fromJson(Map<String, dynamic> json) {
    return InformacoesNutricionais(
      id: json['id'],
      calorias: json['calorias'].toDouble(),
      proteinas: json['proteinas'].toDouble(),
      carboidratos: json['carboidratos'].toDouble(),
      gorduras: json['gorduras'].toDouble(),
      fibras: json['fibras'].toDouble(),
      produtoId: json['produtoId'],
    );
  }

  final double calorias;
  final double carboidratos;
  final double fibras;
  final double gorduras;
  final int id;
  final int produtoId;
  final double proteinas;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'calorias': calorias,
      'proteinas': proteinas,
      'carboidratos': carboidratos,
      'gorduras': gorduras,
      'fibras': fibras,
      'produtoId': produtoId,
    };
  }
}

class ProdutoRequest {
  ProdutoRequest({
    required this.itemPedidoId,
    required this.pedidoId,
    required this.produtoId,
    required this.quantidade,
    required this.precoUnitario,
  });

  factory ProdutoRequest.fromJson(Map<String, dynamic> json) {
    return ProdutoRequest(
      itemPedidoId: json['id'],
      pedidoId: json['pedidoId'],
      produtoId: json['produtoId'],
      quantidade: json['quantidade'],
      precoUnitario: (json['precoUnitario'] as num).toDouble(),
    );
  }

  final int itemPedidoId;
  final int pedidoId;
  final int produtoId;
  int quantidade;
  final double precoUnitario;

  Map<String, dynamic> toJson() {
    return {
      'id': itemPedidoId,
      'pedidoId': pedidoId,
      'produtoId': produtoId,
      'quantidade': quantidade,
      'precoUnitario': precoUnitario,
    };
  }

  ProdutoRequest copyWith({
    int? itemPedidoId,
    int? pedidoId,
    int? produtoId,
    int? quantidade,
    double? precoUnitario,
  }) {
    return ProdutoRequest(
      itemPedidoId: itemPedidoId ?? this.itemPedidoId,
      pedidoId: pedidoId ?? this.pedidoId,
      produtoId: produtoId ?? this.produtoId,
      quantidade: quantidade ?? this.quantidade,
      precoUnitario: precoUnitario ?? this.precoUnitario,
    );
  }
}

