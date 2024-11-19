import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/carrinho_provider.dart';

class RoleBasedMenu extends StatelessWidget {
  const RoleBasedMenu({super.key, required this.role});

  final String role;

  List<Widget> _buildMenuItems(BuildContext context, String? currentRoute) {
    final carrinhoProvider = Provider.of<CarrinhoProvider>(context);

    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.home_outlined,
        'route': '/produtos',
        'roles': ['Admin', 'Cliente'],
        'requiresArgument': false,
        'tooltip': 'Produtos',
      },
      {
        'icon': Icons.people_outline,
        'route': '/clientes',
        'roles': ['Admin'],
        'requiresArgument': false,
        'tooltip': 'Clientes',
      },
      {
        'icon': Icons.storefront_outlined,
        'route': '/fornecedores',
        'roles': ['Admin'],
        'requiresArgument': false,
        'tooltip': 'Fornecedores',
      },
      {
        'icon': Icons.person_add_outlined,
        'route': '/cadastro-cliente',
        'roles': ['Admin'],
        'requiresArgument': false,
        'tooltip': 'Cadastro de Cliente',
      },
      {
        'icon': Icons.shopping_cart_outlined,
        'route': '/carrinho',
        'roles': ['Cliente'],
        'requiresArgument': false,
        'tooltip': 'Carrinho',
      },
      {
        'icon': Icons.attach_money_outlined,
        'route': '/pagamento',
        'roles': ['Cliente'],
        'requiresArgument': true,
        'tooltip': 'Pagamento',
      },
      {
        'icon': Icons.admin_panel_settings_outlined,
        'route': '/cadastro-produto',
        'roles': ['Admin'],
        'requiresArgument': false,
        'tooltip': 'Cadastro de Produtos',
      },
      {
        'icon': Icons.business_outlined,
        'route': '/cadastro-fornecedor',
        'roles': ['Admin'],
        'requiresArgument': false,
        'tooltip': 'Cadastro de Fornecedor',
      },
      {
        'icon': Icons.inventory_2_outlined,
        'route': '/cadastro-produtos-fornecedor',
        'roles': ['Admin'],
        'requiresArgument': false,
        'tooltip': 'Cadastro de Produtos Fornecedor',
      },
      {
        'icon': Icons.agriculture_outlined,
        'route': '/cadastro-producao',
        'roles': ['Admin'],
        'requiresArgument': false,
        'tooltip': 'Cadastro de Cultivo',
      },
      {
        'icon': Icons.bar_chart_outlined,
        'route': '/controle-vendas',
        'roles': ['Admin'],
        'requiresArgument': false,
        'tooltip': 'Controle de Vendas',
      },
      {
        'icon': Icons.list_alt_outlined,
        'route': '/controle-producao',
        'roles': ['Admin'],
        'requiresArgument': false,
        'tooltip': 'Controle de Cultivo',
      },
      {
        'icon': Icons.eco_outlined,
        'route': '/sugestoes-cultivo',
        'roles': ['Admin'],
        'requiresArgument': false,
        'tooltip': 'Sugestões de Cultivo',
      },
    ];

    final filteredItems = menuItems.where((item) {
      final isRoleAllowed = item['roles'].contains(role);
      final isNotCurrentRoute = item['route'] != currentRoute;
      return isRoleAllowed && isNotCurrentRoute;
    }).toList();

    return filteredItems.map((item) {
      return Expanded(
        child: Tooltip(
          message: item['tooltip'],
          child: InkWell(
            onTap: () {
              if (item['requiresArgument'] == true) {
                final pedidoId = carrinhoProvider.pedidoId;

                if (pedidoId != null) {
                  Navigator.pushNamed(
                    context,
                    item['route'],
                    arguments: pedidoId,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nenhum pedido em aberto.')),
                  );
                }
              } else {
                Navigator.pushNamed(context, item['route']);
              }
            },
            child: Center(
              child: Icon(
                item['icon'],
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return BottomAppBar(
      elevation: 0.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 60,
          color: Theme.of(context).colorScheme.primary,
          child: Row(
            children: _buildMenuItems(context, currentRoute),
          ),
        ),
      ),
    );
  }
}
