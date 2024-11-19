import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/role_menu.dart';

class ControleVendasScreen extends StatefulWidget {
  const ControleVendasScreen({super.key});

  @override
  State<ControleVendasScreen> createState() => _ControleVendasScreenState();
}

class _ControleVendasScreenState extends State<ControleVendasScreen> {
  int currentPage = 1;
  String? filtroAno;
  String? filtroMes;
  final int itemsPerPage = 4;
  double totalVendas = 0.0;
  List<Map<String, dynamic>> vendas = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarVendas();
  }

  Future<void> _carregarVendas() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.obterVendasMensais();
      final List<Map<String, dynamic>> vendasFiltradas =
          response.where((venda) {
        final dataVenda = DateTime.parse(venda['dataPedido']);
        final filtroAnoValido =
            filtroAno == null || dataVenda.year.toString() == filtroAno;
        final filtroMesValido = filtroMes == null ||
            (dataVenda.month.toString() ==
                ([
                          'Janeiro',
                          'Fevereiro',
                          'Março',
                          'Abril',
                          'Maio',
                          'Junho',
                          'Julho',
                          'Agosto',
                          'Setembro',
                          'Outubro',
                          'Novembro',
                          'Dezembro'
                        ].indexOf(filtroMes!) +
                        1)
                    .toString());
        return filtroAnoValido && filtroMesValido;
      }).toList();

      final double total = vendasFiltradas.fold(
        0.0,
        (sum, venda) => sum + (venda['totalPedido'] ?? 0.0),
      );

      setState(() {
        vendas = vendasFiltradas;
        totalVendas = total;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar vendas.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatarData(String data) {
    final DateTime parsedData = DateTime.parse(data);
    return DateFormat('dd/MM/yy').format(parsedData);
  }

  String _formatarValor(double valor) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(valor);
  }

  Widget _buildFilters() {
    final anos = List.generate(10, (index) => DateTime.now().year - index);
    final meses = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: DropdownButtonFormField<String>(
              value: filtroAno,
              items: anos
                  .map((ano) => DropdownMenuItem<String>(
                        value: ano.toString(),
                        child: Text(ano.toString()),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => filtroAno = value);
                _carregarVendas();
              },
              decoration: InputDecoration(
                labelText: 'Ano',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.green, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              dropdownColor: Colors.white,
              isExpanded: true,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: DropdownButtonFormField<String>(
              value: filtroMes,
              items: ['Todos', ...meses]
                  .map((mes) => DropdownMenuItem<String>(
                        value: mes == 'Todos' ? null : mes,
                        child: Text(mes),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => filtroMes = value);
                _carregarVendas();
              },
              decoration: InputDecoration(
                labelText: 'Mês',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.green, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              dropdownColor: Colors.white,
              isExpanded: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVendasList(BoxConstraints constraints) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (vendas.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma venda encontrada.',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    final vendasPagina = vendas
        .skip((currentPage - 1) * itemsPerPage)
        .take(itemsPerPage)
        .toList();

    return ListView.builder(
      itemCount: vendasPagina.length,
      itemBuilder: (context, index) {
        final venda = vendasPagina[index];
        List<dynamic> itens =
            venda['itemPedido'] is List ? venda['itemPedido'] : [];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Card(
            color: Colors.green[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dados do Pedido
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pedido: ${venda['id']}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.green[800],
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        _formatarData(venda['dataPedido']),
                        style: TextStyle(
                          color: Colors.green[800],
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Cliente: ${venda['clienteNome']}',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.attach_money,
                          color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Total: ${_formatarValor(venda['totalPedido'])}',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    color: Colors.green,
                    thickness: 1,
                    height: 20,
                  ),

                  // Itens do Pedido
                  Text(
                    'Itens:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: itens.map((item) {
                      return Row(
                        children: [
                          const Icon(Icons.circle,
                              color: Colors.green, size: 8),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${item['produtoNome']}',
                              style: TextStyle(
                                color: Colors.green[800],
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            'Qtd: ${item['quantidade']}',
                            style: TextStyle(
                              color: Colors.green[800],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatarValor(item['precoUnitario']),
                            style: TextStyle(
                              color: Colors.green[800],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),

                  const Divider(
                    color: Colors.green,
                    thickness: 1,
                    height: 20,
                  ),
                  const SizedBox(height: 15),
                  // Status do Pedido
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: venda['status'],
                          items: [
                            'Aguardando Processamento',
                            'Em Processamento',
                            'Concluído',
                            'Cancelado'
                          ]
                              .map((status) => DropdownMenuItem<String>(
                                    value: status,
                                    child: Text(status),
                                  ))
                              .toList(),
                          onChanged: venda['status'] == 'Concluído'
                              ? null
                              : (value) async {
                                  await ApiService.atualizarStatusPedido(
                                      venda['id'], value!);
                                  _carregarVendas();
                                },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.green[800]!,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.green[800]!,
                                width: 2,
                              ),
                            ),
                          ),
                          dropdownColor: Colors.white,
                          isExpanded: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPagination() {
    final totalPages = (vendas.length / itemsPerPage).ceil();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: currentPage > 1
              ? () {
                  setState(() => currentPage--);
                }
              : null,
        ),
        Text(
          'Página $currentPage de $totalPages',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: currentPage < totalPages
              ? () {
                  setState(() => currentPage++);
                }
              : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.all(17.0),
          child: Text(
            'Controle de Vendas',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
      bottomNavigationBar: FutureBuilder<String?>(
        future: AuthService.getRole(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LinearProgressIndicator();
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const RoleBasedMenu(role: 'Cliente');
          }
          return RoleBasedMenu(role: snapshot.data!);
        },
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35.0),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildFilters(),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildVendasList(constraints),
                ),
                const SizedBox(height: 16),
                Text(
                  'Lucro Total: ${_formatarValor(totalVendas)}',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: Colors.green, fontSize: 20),
                ),
                _buildPagination(),
              ],
            ),
          );
        },
      ),
    );
  }
}
