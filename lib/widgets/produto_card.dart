import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/produto.dart';
import '../providers/carrinho_provider.dart';
import '../services/api_service.dart';

class ProdutoCard extends StatefulWidget {
  const ProdutoCard({super.key, required this.produto, required this.userRole});

  final Produto produto;
  final String userRole;

  @override
  _ProdutoCardState createState() => _ProdutoCardState();
}

class _ProdutoCardState extends State<ProdutoCard> {
  InformacoesNutricionais? _informacoesNutricionais;
  bool _mostrarInfoNutricional = false;

  @override
  void initState() {
    super.initState();
    _carregarInformacoesNutricionais();
  }

  Future<void> _carregarInformacoesNutricionais() async {
    final infoMap =
        await ApiService.obterInformacoesNutricionais(widget.produto.id);
    if (!mounted) return;
    setState(() {
      _informacoesNutricionais =
          infoMap != null ? InformacoesNutricionais.fromJson(infoMap) : null;
    });
  }

  String _formatarValor(double valor) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(valor);
  }

  @override
  Widget build(BuildContext context) {
    final carrinhoProvider = Provider.of<CarrinhoProvider>(context);
    final int quantidadeNoCarrinho =
        carrinhoProvider.itensCarrinho[widget.produto.id]?.quantidade ?? 0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      if (mounted) {
                        setState(() {
                          _mostrarInfoNutricional = !_mostrarInfoNutricional;
                        });
                      }
                    },
                    child: Image.asset(
                      widget.produto.imagemUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
                if (_mostrarInfoNutricional && _informacoesNutricionais != null)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                        ),
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Informações Nutricionais',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                  'Calorias: ${_informacoesNutricionais!.calorias} kcal',
                                  style: const TextStyle(color: Colors.white)),
                              Text(
                                  'Carboidratos: ${_informacoesNutricionais!.carboidratos} g',
                                  style: const TextStyle(color: Colors.white)),
                              Text(
                                  'Proteínas: ${_informacoesNutricionais!.proteinas} g',
                                  style: const TextStyle(color: Colors.white)),
                              Text(
                                  'Gorduras: ${_informacoesNutricionais!.gorduras} g',
                                  style: const TextStyle(color: Colors.white)),
                              Text(
                                  'Fibras: ${_informacoesNutricionais!.fibras} g',
                                  style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      if (mounted) {
                        setState(() {
                          _mostrarInfoNutricional = !_mostrarInfoNutricional;
                        });
                      }
                    },
                    child: Icon(
                      Icons.info_outline,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: Colors.black54,
                    child: Text(
                      'Disponível: ${widget.produto.quantidade}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.produto.nome,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'R\$ ${_formatarValor(widget.produto.preco)}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: widget.userRole !=
                          'Admin'
                      ? [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (quantidadeNoCarrinho > 0) {
                                carrinhoProvider
                                    .removerDoCarrinho(widget.produto);
                              }
                            },
                          ),
                          Text(
                            '$quantidadeNoCarrinho',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              carrinhoProvider
                                  .adicionarAoCarrinho(widget.produto);
                            },
                          ),
                        ]
                      : [
                          const SizedBox(height: 2),
                        ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
