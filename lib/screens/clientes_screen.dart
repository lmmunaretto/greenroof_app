import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../services/api_service.dart';
import '../widgets/role_menu.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  List<Map<String, dynamic>> clientes = [];
  List<Map<String, dynamic>> clientesComCompras = [];
  List<Map<String, dynamic>> clientesSemCompras = [];
  int currentPage = 1;
  final int itemsPerPage = 5;
  String selectedFilter = 'Todos';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);
    try {
      final clientesResponse = await ApiService.fetchClientes();
      final pedidosResponse = await ApiService.fetchPedidos();

      final Map<int, List<Pedido>> pedidosPorCliente = {};

      for (var pedido in pedidosResponse) {
        if (!pedidosPorCliente.containsKey(pedido.clienteId)) {
          pedidosPorCliente[pedido.clienteId] = [];
        }
        pedidosPorCliente[pedido.clienteId]?.add(pedido);
      }

      setState(() {
        clientes = clientesResponse
            .map((cliente) => {
                  'cliente': cliente,
                  'pedidosCount': pedidosPorCliente[cliente.id]?.length ?? 0,
                  'totalGasto': pedidosPorCliente[cliente.id]?.fold<double>(
                          0, (sum, pedido) => sum + (pedido.totalPedido)) ??
                      0,
                })
            .toList();

        clientesSemCompras = clientes.where((entry) {
          return entry['pedidosCount'] == 0;
        }).toList();

        clientesComCompras = clientes.where((entry) {
          return entry['pedidosCount'] > 0;
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _mascararCpf(String cpf) {
    return '***.***.${cpf.substring(cpf.length - 4)}';
  }

  String _mascararEmail(String email) {
    final parts = email.split('@');
    if (parts.length == 2) {
      return '${parts[0].substring(0, 2)}***@${parts[1]}';
    }
    return email;
  }

  String _mascararTelefone(String telefone) {
    return '****-****-${telefone.substring(telefone.length - 4)}';
  }

  String _mascararEndereco(String endereco) {
    return endereco.split(',').first;
  }

  Widget _buildClientesList(BoxConstraints constraints) {
    final listaAtual = selectedFilter == 'Todos'
        ? clientes
        : selectedFilter == 'Sem Compras'
            ? clientesSemCompras
            : clientesComCompras;

    final paginatedList = listaAtual
        .skip((currentPage - 1) * itemsPerPage)
        .take(itemsPerPage)
        .toList();

    if (paginatedList.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum cliente encontrado.',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      itemCount: paginatedList.length,
      itemBuilder: (context, index) {
        final entry = paginatedList[index];
        final cliente = entry['cliente'] as Cliente;
        final pedidosCount = entry['pedidosCount'] as int;
        final totalGasto = entry['totalGasto'] as double;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          color: Colors.green[50], // Card com fundo verde claro
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cliente.nome,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.green[800], // Fonte verde escura
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.email, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Email: ${_mascararEmail(cliente.email)}',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Telefone: ${_mascararTelefone(cliente.telefone)}',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.badge, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'CPF: ${_mascararCpf(cliente.cpf)}',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.home, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Endereço: ${_mascararEndereco(cliente.endereco)}',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(
                  color: Colors.green,
                  thickness: 1,
                  height: 20,
                ),
                Row(
                  children: [
                    const Icon(Icons.shopping_cart,
                        color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Pedidos Realizados: $pedidosCount',
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
                    const Icon(Icons.monetization_on,
                        color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Total Gasto: R\$ ${totalGasto.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 8.0,
      children: [
        FilterChip(
          label: const Text('Todos os Clientes'),
          selected: selectedFilter == 'Todos',
          onSelected: (isSelected) {
            if (isSelected) {
              setState(() {
                selectedFilter = 'Todos';
                currentPage = 1;
              });
            }
          },
        ),
        FilterChip(
          label: const Text('Com Compras'),
          selected: selectedFilter == 'Com Compras',
          onSelected: (isSelected) {
            if (isSelected) {
              setState(() {
                selectedFilter = 'Com Compras';
                currentPage = 1;
              });
            }
          },
        ),
        FilterChip(
          label: const Text('Sem Compras'),
          selected: selectedFilter == 'Sem Compras',
          onSelected: (isSelected) {
            if (isSelected) {
              setState(() {
                selectedFilter = 'Sem Compras';
                currentPage = 1;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildPagination() {
    final listaAtual = selectedFilter == 'Todos'
        ? clientes
        : selectedFilter == 'Sem Compras'
            ? clientesSemCompras
            : clientesComCompras;

    final totalPages = (listaAtual.length / itemsPerPage).ceil();

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
            'Clientes',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
      bottomNavigationBar: const RoleBasedMenu(role: 'Admin'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                _buildFilterChips(),
                const SizedBox(height: 16),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildClientesList(constraints),
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
