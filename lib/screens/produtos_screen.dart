import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/produto_provider.dart';
import '../providers/carrinho_provider.dart';
import '../widgets/produto_card.dart';
import '../widgets/outlined_text_field.dart';
import '../widgets/role_menu.dart';
import '../services/auth_service.dart';

class ProdutosScreen extends StatefulWidget {
  const ProdutosScreen({super.key});

  @override
  State<ProdutosScreen> createState() => _ProdutosScreenState();
}

class _ProdutosScreenState extends State<ProdutosScreen> {
  final TextEditingController _searchController = TextEditingController();
  String userRole = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProdutoProvider>(context, listen: false).carregarProdutos();
    });
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final usuario = await AuthService.getUsuarioFromToken();
    setState(() {
      userRole = usuario?.role ?? '';
    });
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService.logout(); // Remove os tokens
    Navigator.pushNamedAndRemoveUntil(
        context, '/', (route) => false); // Vai para a tela de login
  }

  @override
  Widget build(BuildContext context) {
    final produtoProvider = Provider.of<ProdutoProvider>(context);
    final carrinhoProvider = Provider.of<CarrinhoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.all(17.0),
          child: Text(
            'Greenroof',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: IconButton(
              tooltip: 'Sair',
              icon: const Icon(Icons.logout, weight: 700, color: Colors.green),
              onPressed: () => _logout(context),
            ),
          ),
        ],
      ),
    floatingActionButton: userRole == 'Cliente'
        ? FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(context, '/carrinho'),
            label: Text('${carrinhoProvider.totalProdutos} itens no carrinho'),
            icon: const Icon(Icons.shopping_cart),
          )
        : null,
    bottomNavigationBar: userRole == 'Admin'
        ? RoleBasedMenu(role: userRole)
        : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Barra de busca
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: OutlinedTextField(
                controller: _searchController,
                label: 'Buscar produtos',
                onChanged: (query) => produtoProvider.filtrarProdutos(query),
              ),
            ),
            const SizedBox(height: 16),
            // Exibição de produtos
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Ajuste do número de colunas baseado no tamanho da tela
                  int crossAxisCount = constraints.maxWidth > 1200
                      ? 4
                      : constraints.maxWidth > 800
                          ? 3
                          : constraints.maxWidth > 600
                              ? 2
                              : 1;

                  return produtoProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : GridView.builder(
                          padding: const EdgeInsets.all(16.0),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: produtoProvider.produtos.length,
                          itemBuilder: (context, index) {
                            final produto = produtoProvider.produtos[index];
                            return ProdutoCard(produto: produto, userRole: userRole );
                          },
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
