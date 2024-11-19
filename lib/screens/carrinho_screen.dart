import 'package:flutter/material.dart';
import 'package:greenroof_app/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../providers/carrinho_provider.dart';
import '../providers/produto_provider.dart';
import '../widgets/role_menu.dart';

class CarrinhoScreen extends StatelessWidget {
  const CarrinhoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final carrinhoProvider = Provider.of<CarrinhoProvider>(context);
    final produtoProvider =
        Provider.of<ProdutoProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.all(17.0),
          child: Text(
            'Carrinho',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 30),
        child: FloatingActionButton(
          tooltip: 'Finalizar Compra',
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 3, color: Colors.green),
            borderRadius: BorderRadius.circular(100),
          ),
          onPressed: () {
            if (carrinhoProvider.totalProdutos > 0) {
              Navigator.pushNamed(
                context,
                '/pagamento',
                arguments: carrinhoProvider.pedidoId,
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Carrinho está vazio.')),
              );
            }
          },
          child: const Icon(
            Icons.shopping_cart_checkout,
            color: Colors.green,
            size: 30
          ),
        ),
      ),
      bottomNavigationBar: FutureBuilder<String?>(
        future: AuthService.getRole(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: 60,
              child: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const RoleBasedMenu(role: 'Cliente');
          }
          return RoleBasedMenu(role: snapshot.data!);
        },
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width =
              constraints.maxWidth > 600 ? 500 : constraints.maxWidth * 0.9;
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: carrinhoProvider.itensCarrinho.length,
                  itemBuilder: (context, index) {
                    final item =
                        carrinhoProvider.itensCarrinho.values.elementAt(index);
                    final produto = produtoProvider.produtos
                        .firstWhere((p) => p.id == item.produtoId);
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            child: Text('${item.quantidade}x',
                                style:
                                    const TextStyle(color: Colors.white)),
                          ),
                          title: Text(
                            produto.nome,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 1,
                          ),
                          subtitle: Text(
                            'R\$${item.precoUnitario.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: width,
                  child: Column(
                    children: [
                      Text(
                        'Total: R\$${carrinhoProvider.totalCarrinho.toStringAsFixed(2)}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
