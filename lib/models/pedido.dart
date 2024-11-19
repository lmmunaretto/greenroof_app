class Pedido {
  Pedido({
    required this.id,
    required this.clienteId,
    required this.clienteNome,
    required this.dataPedido,
    required this.totalPedido,
    required this.status,
    required this.itensPedido,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'],
      clienteId: json['clienteId'],
      clienteNome: json['clienteNome'],
      dataPedido: DateTime.parse(json['dataPedido']),
      totalPedido: json['totalPedido'].toDouble(),
      status: json['status'],
      itensPedido: (json['itemPedido'] as List)
          .map((item) => ItemPedido.fromJson(item))
          .toList(),
    );
  }

  final int clienteId;
  final String clienteNome;
  final DateTime dataPedido;
  final int id;
  final List<ItemPedido> itensPedido;
  final String status;
  final double totalPedido;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clienteId': clienteId,
      'clienteNome': clienteNome,
      'dataPedido': dataPedido.toIso8601String(),
      'totalPedido': totalPedido,
      'status': status,
      'itemPedido': itensPedido.map((item) => item.toJson()).toList(),
    };
  }
}

class ItemPedido {
  ItemPedido({
    required this.id,
    required this.pedidoId,
    required this.produtoId,
    required this.produtoNome,
    required this.quantidade,
    required this.precoUnitario,
  });

  factory ItemPedido.fromJson(Map<String, dynamic> json) {
    return ItemPedido(
      id: json['id'],
      pedidoId: json['pedidoId'],
      produtoId: json['produtoId'],
      produtoNome: json['produtoNome'],
      quantidade: json['quantidade'],
      precoUnitario: json['precoUnitario'].toDouble(),
    );
  }

  final int id;
  final int pedidoId;
  final double precoUnitario;
  final int produtoId;
  final String produtoNome;
  final int quantidade;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pedidoId': pedidoId,
      'produtoId': produtoId,
      'produtoNome': produtoNome,
      'quantidade': quantidade,
      'precoUnitario': precoUnitario,
    };
  }
}

class Cliente {
  Cliente({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.cpf,
    required this.endereco,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      telefone: json['telefone'],
      cpf: json['cpf'],
      endereco: json['endereco'],
    );
  }

  final String cpf;
  final String email;
  final String endereco;
  final int id;
  final String nome;
  final String telefone;

    Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'cpf': cpf,
      'endereco': endereco,
    };
  }
}
