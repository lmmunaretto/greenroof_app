class ProducaoCultivo {
  ProducaoCultivo({
    required this.id,
    required this.produtoId,
    required this.produtoNome,
    required this.adminId,
    required this.dataProducao,
    required this.quantidadeProduzida,
  });

  factory ProducaoCultivo.fromJson(Map<String, dynamic> json) {
    return ProducaoCultivo(
      id: json['id'],
      produtoId: json['produtoId'],
      produtoNome: json['produtoNome'],
      adminId: json['adminId'],
      dataProducao: DateTime.parse(json['dataProducao']),
      quantidadeProduzida: json['quantidadeProduzida'],
    );
  }

  final int id;
  final int produtoId;
  final String produtoNome;
  final int adminId;
  final DateTime dataProducao;
  final int quantidadeProduzida;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'produtoId': produtoId,
      'produtoNome': produtoNome,
      'adminId': adminId,
      'dataProducao': dataProducao.toIso8601String(),
      'quantidadeProduzida': quantidadeProduzida,
    };
  }
}
