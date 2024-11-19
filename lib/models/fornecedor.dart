class Fornecedor {
  Fornecedor({
    required this.id,
    required this.nome,
    required this.telefone,
    required this.email,
    required this.cnpj,
    required this.endereco,
    this.adminId,
  });

  factory Fornecedor.fromJson(Map<String, dynamic> json) {
    return Fornecedor(
      id: json['id'],
      nome: json['nome'],
      telefone: json['telefone'],
      email: json['email'],
      cnpj: json['cnpj'],
      endereco: json['endereco'],
      adminId: json['adminId'],
    );
  }

  final int id;
  final String nome;
  final String telefone;
  final String email;
  final String cnpj;
  final String endereco;
  final int? adminId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'telefone': telefone,
      'email': email,
      'cnpj': cnpj,
      'endereco': endereco,
      'adminId': adminId,
    };
  }
}

class ProdutosFornecedor {
  ProdutosFornecedor({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.quantidade,
    required this.preco,
    required this.tipo,
    required this.fornecedorId,
    required this.fornecedor,
  });

  factory ProdutosFornecedor.fromJson(Map<String, dynamic> json) {
    return ProdutosFornecedor(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      quantidade: json['quantidade'],
      preco: json['preco'].toDouble(),
      tipo: json['tipo'],
      fornecedorId: json['fornecedorId'],
      fornecedor: Fornecedor.fromJson(json['fornecedor']),
    );
  }

  final int id;
  final String nome;
  final String descricao;
  final int quantidade;
  final double preco;
  final String tipo;
  final int fornecedorId;
  final Fornecedor fornecedor;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'quantidade': quantidade,
      'preco': preco,
      'tipo': tipo,
      'fornecedorId': fornecedorId,
      'fornecedor': fornecedor.toJson(),
    };
  }
}
