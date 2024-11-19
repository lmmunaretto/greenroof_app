import 'package:flutter/material.dart';
import 'package:greenroof_app/providers/carrinho_provider.dart';
import 'package:greenroof_app/providers/produto_provider.dart';
import 'package:greenroof_app/services/api_service.dart';
import 'package:greenroof_app/services/auth_service.dart';
import 'package:greenroof_app/widgets/role_menu.dart';
import 'package:provider/provider.dart';

class PagamentoScreen extends StatefulWidget {
  const PagamentoScreen({super.key, required this.pedidoId});

  final int pedidoId;

  @override
  _PagamentoScreenState createState() => _PagamentoScreenState();
}

class _PagamentoScreenState extends State<PagamentoScreen> {
  final TextEditingController _dataPagamentoController =
      TextEditingController();

  String _metodoPagamento = 'credito';
  final TextEditingController _valorPagamentoController =
      TextEditingController();

  @override
  void dispose() {
    _valorPagamentoController.dispose();
    _dataPagamentoController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _carregarDadosPagamento();
  }

  Future<void> _carregarDadosPagamento() async {
    final pedido = await ApiService.buscarPedidoPorId(widget.pedidoId);
    setState(() {
      _valorPagamentoController.text = pedido.totalPedido.toStringAsFixed(2);
    });
    }

Future<void> _processarPagamento(
    BuildContext context, int pedidoId, String metodoPagamento, double valor) async {
  if (metodoPagamento.isEmpty || valor <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preencha todos os campos.')),
    );
    return;
  }

  try {
    final sucesso = await ApiService.concluirPagamento(
      pedidoId: pedidoId,
      metodoPagamento: metodoPagamento,
      valorPagamento: valor,
    );

    if (sucesso) {
      await _atualizarStatusPedido(pedidoId);
      await _atualizarEstoqueProdutos(pedidoId);

      Provider.of<CarrinhoProvider>(context, listen: false).limparCarrinho();
      await Provider.of<ProdutoProvider>(context, listen: false).carregarProdutos();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pagamento concluído com sucesso!')),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/produtos', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao processar pagamento.')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erro ao conectar-se ao servidor.')),
    );
  }
}

  Future<void> _atualizarStatusPedido(int pedidoId) async {
    await ApiService.atualizarStatusPedido(pedidoId, 'Concluído');
  }

  Future<void> _atualizarEstoqueProdutos(int pedidoId) async {
    await ApiService.atualizarEstoqueProdutos(pedidoId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
        padding: const EdgeInsets.all(17.0),
          child: Text(
            'Pagamento',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 30),
        child: FloatingActionButton(
          tooltip: 'Confirmar Pagamento',
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 3, color: Colors.green),
            borderRadius: BorderRadius.circular(100),
          ),
          onPressed: () {
            _processarPagamento(
              context,
              widget.pedidoId,
              _metodoPagamento,
              double.tryParse(_valorPagamentoController.text) ?? 0
            );
          },
          child: const Icon(
            Icons.done,
            color: Colors.green,
            size: 30,
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

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: width,
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalhes do Pedido',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      readOnly: true,
                      initialValue: widget.pedidoId.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Pedido ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _metodoPagamento,
                      items: const [
                        DropdownMenuItem(
                            value: 'credito', child: Text('Cartão de Crédito')),
                        DropdownMenuItem(
                            value: 'debito', child: Text('Cartão de Débito')),
                        DropdownMenuItem(value: 'pix', child: Text('Pix')),
                        DropdownMenuItem(
                            value: 'boleto', child: Text('Boleto Bancário')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _metodoPagamento = value ?? 'credito';
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Escolha o método de pagamento',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _valorPagamentoController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Valor do Pagamento',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
