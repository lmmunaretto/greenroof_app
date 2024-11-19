import 'dart:convert';
import 'package:greenroof_app/models/fornecedor.dart';
import 'package:greenroof_app/models/producao_cultivo.dart';
import 'package:http/http.dart' as http;
import '../models/produto.dart';
import '../models/pedido.dart';
import 'auth_service.dart';
import 'dart:developer' as developer;

class ApiService {
  static const String apiUrl = "https://greenroofapi-production.up.railway.app";
  static const String geocodeApiKey = "5db5a96f174d46e389853c0ec12d44a2";

  static Future<List<Produto>> fetchProdutos() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$apiUrl/api/produtos'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final produtosJson = data as List;
      return produtosJson.map((json) => Produto.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao carregar produtos');
    }
  }

  static Future<Produto?> fetchProdutoById(int produtoId) async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$apiUrl/api/Produtos/$produtoId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Produto.fromJson(data);
    } else {
      throw Exception('Erro ao carregar o produto');
    }
  }

  static Future<List<Pedido>> fetchPedidos() async {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Token de autenticação não encontrado.');
    }

    final response = await http.get(
      Uri.parse('$apiUrl/api/Pedidos'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> pedidosJson = json.decode(response.body);
      return pedidosJson.map((json) => Pedido.fromJson(json)).toList();
    } else {
      throw Exception(
          'Erro ao buscar pedidos: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  static Future<int?> getPedidoAbertoId() async {
    try {
      final usuario = await AuthService.getUsuarioFromToken();
      final clienteId = usuario?.clienteId;

      if (clienteId == null || clienteId == "") {
        return null;
      }

      final response = await http.get(
        Uri.parse('$apiUrl/api/Pedidos'),
        headers: {
          'Authorization': 'Bearer ${await AuthService.getToken()}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final pedidos = jsonDecode(response.body);

        final pedidoAberto = (pedidos as List<dynamic>).firstWhere(
          (pedido) =>
              pedido['clienteId'] == int.parse(clienteId) &&
              pedido['status'] == "Aguardando Processamento",
          orElse: () => null,
        );

        return pedidoAberto != null ? pedidoAberto['id'] as int : null;
      }
    } catch (e) {
      developer.log("Erro ao obter o pedido em aberto: $e");
    }
    return null;
  }

  static Future<void> adicionarItemAoCarrinho(
      ProdutoRequest produtoRequest, String pedidoId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('$apiUrl/api/ItensPedido'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'pedidoId': pedidoId,
          'produtoId': produtoRequest.produtoId,
          'quantidade': produtoRequest.quantidade,
          'precoUnitario': produtoRequest.precoUnitario,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Erro ao adicionar item ao pedido");
      }
    } catch (e) {
      developer.log("Erro ao adicionar item ao pedido: $e");
    }
  }

  static Future<void> atualizarPedido(Pedido pedido) async {
    final token = await AuthService.getToken();

    final pedidoDTO = {
      'id': pedido.id,
      'clienteId': pedido.clienteId,
      'dataPedido': pedido.dataPedido.toIso8601String(),
      'totalPedido': pedido.totalPedido,
      'status': pedido.status,
    };

    final response = await http.put(
      Uri.parse('$apiUrl/api/Pedidos/${pedido.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(pedidoDTO),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar o pedido');
    }
  }

  static Future<void> atualizarItemDoPedido(
      ProdutoRequest produtoRequest, int pedidoId) async {
    final token = await AuthService.getToken();
    final response = await http.put(
      Uri.parse('$apiUrl/api/ItensPedido/${produtoRequest.itemPedidoId}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'pedidoId': pedidoId,
        'produtoId': produtoRequest.produtoId,
        'quantidade': produtoRequest.quantidade,
        'precoUnitario': produtoRequest.precoUnitario,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Erro ao atualizar item do pedido.");
    }
  }

  static Future<void> deletarItemDoPedido(
      int itemPedidoId, int produtoId) async {
    final token = await AuthService.getToken();
    final response = await http.delete(
      Uri.parse('$apiUrl/api/ItensPedido/$itemPedidoId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Erro ao deletar item do pedido.");
    }
  }

  static Future<void> adicionarItemAoPedido(
      ProdutoRequest produtoRequest, int pedidoId) async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse('$apiUrl/api/ItensPedido'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'pedidoId': pedidoId,
        'produtoId': produtoRequest.produtoId,
        'quantidade': produtoRequest.quantidade,
        'precoUnitario': produtoRequest.precoUnitario,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Erro ao adicionar item ao pedido.");
    }
  }

  static Future<int?> buscarPedidoAberto() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$apiUrl/api/Pedidos'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final pedidos = json.decode(response.body);
      final pedidoAberto = pedidos?.firstWhere(
        (pedido) => pedido['status'] == 'Aguardando Processamento',
        orElse: () => null,
      );
      return pedidoAberto?['id'];
    } else {
      throw Exception('Erro ao buscar pedido em aberto');
    }
  }

  static Future<int> criarNovoPedido(List<ProdutoRequest> itens) async {
    final token = await AuthService.getToken();
    final usuario = await AuthService.getUsuarioFromToken();

    final clienteId = int.tryParse(usuario?.clienteId ?? '');

    if (clienteId == null) {
      throw Exception('Cliente ID inválido.');
    }

    final pedidoDTO = {
      'clienteId': clienteId,
      'dataPedido': DateTime.now().toUtc().toIso8601String(),
      'status': 'Aguardando Processamento',
      'itensPedido': itens.map((item) {
        return {
          'produtoId': item.produtoId,
          'quantidade': item.quantidade,
          'precoUnitario': item.precoUnitario,
        };
      }).toList(),
    };

    final dataBody = json.encode(pedidoDTO);

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/api/Pedidos'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: dataBody,
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['id'];
      } else {
        final error = json.decode(response.body);
        throw Exception('Erro ao criar novo pedido: ${error['message']}');
      }
    } catch (e) {
      developer.log("Erro ao criar novo pedido: $e");
      rethrow;
    }
  }

  static Future<Pedido> buscarPedidoPorId(int pedidoId) async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$apiUrl/api/Pedidos/$pedidoId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Pedido.fromJson(data);
    } else {
      throw Exception('Erro ao carregar pedido');
    }
  }

  static Future<Map<String, dynamic>?> obterInformacoesNutricionais(
      int produtoId) async {
    try {
      final response =
          await http.get(Uri.parse('$apiUrl/api/InformacoesNutricionais'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final infoList = data as List<dynamic>;
        final info = infoList.firstWhere(
            (element) => element['produtoId'] == produtoId,
            orElse: () => null);
        return info as Map<String, dynamic>?;
      }
    } catch (error) {
      developer.log("Erro ao obter informações nutricionais: $error");
    }
    return null;
  }

  static Future<bool> concluirPagamento(
      {required int pedidoId,
      required String metodoPagamento,
      required double valorPagamento}) async {
    final response = await http.post(
      Uri.parse('$apiUrl/api/Pagamentos'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'pedidoId': pedidoId,
        'metodoPagamento': metodoPagamento,
        'valorPagamento': valorPagamento,
        'dataPagamento': DateTime.now().toIso8601String(),
        'statusPagamento': 'Concluído'
      }),
    );

    return response.statusCode == 200;
  }

  static Future<void> atualizarStatusPedido(int pedidoId, String status) async {
    await http.put(
      Uri.parse('$apiUrl/api/Pedidos/$pedidoId/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(status),
    );
  }

  static Future<void> atualizarEstoqueProdutos(int pedidoId) async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$apiUrl/api/Pedidos/all/$pedidoId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final pedido = jsonDecode(response.body);
      for (var item in pedido['itemPedido']) {
        await _atualizarProduto(item['produtoId'], item['quantidade']);
      }
    }
  }

  static Future<void> cadastrarCliente(
    String nome,
    String email,
    String telefone,
    String endereco,
    String cpf,
  ) async {
    final token = await AuthService.getToken();
    final clienteDTO = {
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'endereco': endereco,
      'cpf': cpf,
    };

    final response = await http.post(
      Uri.parse('$apiUrl/api/clientes'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(clienteDTO),
    );

    if (response.statusCode != 201) {
      final error = json.decode(response.body);
      throw Exception('Erro ao cadastrar cliente: ${error['message']}');
    }
  }

  static Future<List<Cliente>> fetchClientes() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('$apiUrl/api/Clientes'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((clienteJson) => Cliente.fromJson(clienteJson)).toList();
    } else {
      throw Exception('Erro ao buscar clientes: ${response.reasonPhrase}');
    }
  }

  static Future<void> cadastrarFornecedor(String nome, String cnpj,
      String telefone, String email, String endereco) async {
    final token = await AuthService.getToken();
    final fornecedorDTO = {
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'cnpj': cnpj,
      'endereco': endereco,
    };

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/api/fornecedores'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(fornecedorDTO),
      );

      if (response.statusCode != 201) {
        final error = json.decode(response.body);
        throw Exception('Erro ao cadastrar fornecedor: ${error['message']}');
      }
    } catch (e) {
      developer.log('Erro ao cadastrar fornecedor: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> obterVendasMensais() async {
    final token = await AuthService.getToken();

    try {
      final response = await http.get(
        Uri.parse('$apiUrl/api/pedidos'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final vendas = data as List;
        return vendas.map((venda) => venda as Map<String, dynamic>).toList();
      } else {
        throw Exception('Erro ao obter vendas mensais');
      }
    } catch (e) {
      developer.log('Erro ao obter vendas mensais: $e');
      rethrow;
    }
  }

  static Future<String?> obterCidade(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://api.opencagedata.com/geocode/v1/json?q=$latitude+$longitude&key=$geocodeApiKey&language=pt');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final cidade = data['results'][0]['components']['city'] ??
              data['results'][0]['components']['town'] ??
              data['results'][0]['components']['village'];
          return cidade;
        }
        return null;
      } else {
        developer.log('Erro ao obter cidade: ${response.body}');
        return null;
      }
    } catch (e) {
      developer.log('Erro ao obter cidade: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> obterSugestoesCultivo(
      double latitude, double longitude, String epocaAno) async {
    final token = await AuthService.getToken();
    final cidade = await obterCidade(latitude, longitude);

    if (cidade == null) {
      throw Exception('Não foi possível determinar a cidade.');
    }

    final url = Uri.parse(
        '$apiUrl/api/inteligencia/sugestoes-cultivo?latitude=$latitude&longitude=$longitude&cidade=$cidade&epocaAno=$epocaAno');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception('Erro ao obter sugestões: ${error['message']}');
      }
    } catch (e) {
      throw Exception('Erro ao obter sugestões de cultivo: $e');
    }
  }

  static Future<void> cadastrarProducaoCultivo({
    required int produtoId,
    required int quantidadeProduzida,
    required DateTime dataProducao,
  }) async {
    final token = await AuthService.getToken();

    final producaoData = {
      'produtoId': produtoId,
      'quantidadeProduzida': quantidadeProduzida,
      'dataProducao': dataProducao.toUtc().toIso8601String(),
    };

    final response = await http.post(
      Uri.parse('$apiUrl/api/producaoCultivo'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(producaoData),
    );

    if (response.statusCode != 201) {
      throw Exception('Erro ao cadastrar produção: ${response.body}');
    }
  }

  static Future<List<ProducaoCultivo>> fetchProducoesCultivo() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$apiUrl/api/producaoCultivo'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => ProducaoCultivo.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao buscar produções: ${response.body}');
    }
  }

  static Future<void> _atualizarProduto(int produtoId, int quantidade) async {
    await http.put(
      Uri.parse('$apiUrl/api/Produtos/$produtoId/estoque'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(quantidade),
    );
  }

  static Future<List<Fornecedor>> fetchFornecedores() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$apiUrl/api/Fornecedores'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Fornecedor.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao carregar fornecedores');
    }
  }

  static Future<void> cadastrarProdutoFornecedor({
    required String nome,
    required String descricao,
    required int quantidade,
    required double preco,
    required String tipo,
    required int fornecedorId,
  }) async {
    final token = await AuthService.getToken();
    final produtoFornecedorDTO = {
      'nome': nome,
      'descricao': descricao,
      'quantidade': quantidade,
      'preco': preco,
      'tipo': tipo,
      'fornecedorId': fornecedorId,
    };

    final response = await http.post(
      Uri.parse('$apiUrl/api/ProdutosFornecedor'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(produtoFornecedorDTO),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Erro ao cadastrar produto do fornecedor');
    }
  }

  static Future<List<ProdutosFornecedor>> fetchProdutosFornecedor() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$apiUrl/api/ProdutosFornecedor'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao carregar produtos do fornecedor');
    }

    final data = json.decode(response.body) as List;
    return data.map((json) => ProdutosFornecedor.fromJson(json)).toList();
  }

  static Future<Map<String, dynamic>> cadastrarProduto(
      String nome, String descricao, int quantidade, double preco,
      {required int limiteEstoque, required String tipo}) async {
    final token = await AuthService.getToken();
    final produtoDTO = {
      'nome': nome,
      'descricao': descricao,
      'quantidade': quantidade,
      'limiteMinimoEstoque': limiteEstoque,
      'preco': preco,
      'tipo': tipo.toLowerCase()
    };

    final response = await http.post(
      Uri.parse('$apiUrl/api/produtos'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(produtoDTO),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      final error = json.decode(response.body);
      throw Exception('Erro ao cadastrar produto: ${error['message']}');
    }
  }

  static Future<void> cadastrarInformacoesNutricionais({
    required int produtoId,
    required double calorias,
    required double carboidratos,
    required double proteinas,
    required double gorduras,
    required double fibras,
  }) async {
    final token = await AuthService.getToken();
    final informacoesDTO = {
      'produtoId': produtoId,
      'calorias': calorias,
      'carboidratos': carboidratos,
      'proteinas': proteinas,
      'gorduras': gorduras,
      'fibras': fibras,
    };

    final response = await http.post(
      Uri.parse('$apiUrl/api/InformacoesNutricionais'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(informacoesDTO),
    );

    if (response.statusCode != 201) {
      final error = json.decode(response.body);
      throw Exception(
          'Erro ao cadastrar informações nutricionais: ${error['message']}');
    }
  }

  static void handleError(http.Response response) {
    final error = json.decode(response.body);
    throw Exception('Erro: ${error['message'] ?? 'Erro desconhecido'}');
  }
}
