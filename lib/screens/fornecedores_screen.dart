import 'package:flutter/material.dart';
import 'package:greenroof_app/models/fornecedor.dart';
import 'package:greenroof_app/widgets/primary_button.dart';
import '../services/api_service.dart';
import '../widgets/role_menu.dart';

class FornecedoresScreen extends StatefulWidget {
  const FornecedoresScreen({super.key});

  @override
  State<FornecedoresScreen> createState() => _FornecedoresScreenState();
}

class _FornecedoresScreenState extends State<FornecedoresScreen> {
  int currentPage = 1;
  List<Fornecedor> fornecedores = [];
  final int itemsPerPage = 4;
  List<ProdutosFornecedor> produtos = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);
    try {
      final fornecedoresResponse = await ApiService.fetchFornecedores();
      final produtosResponse = await ApiService.fetchProdutosFornecedor();
      setState(() {
        fornecedores = fornecedoresResponse;
        produtos = produtosResponse;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _abrirModalProdutos(int fornecedorId) {
    final produtosDoFornecedor = produtos
        .where((produto) => produto.fornecedorId == fornecedorId)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite controlar o tamanho do modal
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.6, // Define o modal para ocupar 60% da altura da tela
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: produtosDoFornecedor.isEmpty
                ? const Center(
                    child: Text(
                      'Ainda não há produtos cadastrados para este fornecedor.',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
                    itemCount: produtosDoFornecedor.length,
                    itemBuilder: (context, index) {
                      final produto = produtosDoFornecedor[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            produto.nome,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Quantidade: ${produto.quantidade} | Tipo: ${produto.tipo}',
                          ),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget _buildFornecedoresList(BoxConstraints constraints) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (fornecedores.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum fornecedor encontrado.',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    final fornecedoresPagina = fornecedores
        .skip((currentPage - 1) * itemsPerPage)
        .take(itemsPerPage)
        .toList();

    return ListView.builder(
      itemCount: fornecedoresPagina.length,
      itemBuilder: (context, index) {
        final fornecedor = fornecedoresPagina[index];
        final produtosDoFornecedor = produtos
            .where((produto) => produto.fornecedorId == fornecedor.id)
            .toList();

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          color: Colors.green[50], // Fundo do card com verde claro
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fornecedor.nome,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.green[800], // Fonte verde escura
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Telefone: ${fornecedor.telefone}',
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
                    const Icon(Icons.email, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Email: ${fornecedor.email}',
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
                    const Icon(Icons.business, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'CNPJ: ${fornecedor.cnpj}',
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
                    const Icon(Icons.location_on,
                        color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Endereço: ${fornecedor.endereco}',
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
                    const Icon(Icons.list, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Produtos cadastrados: ${produtosDoFornecedor.length}',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                PrimaryButton(onPressed: () => _abrirModalProdutos(fornecedor.id), text: 'Ver Produtos')

              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPagination() {
    final totalPages = (fornecedores.length / itemsPerPage).ceil();
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
            'Fornecedores',
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
                Expanded(
                  child: _buildFornecedoresList(constraints),
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
