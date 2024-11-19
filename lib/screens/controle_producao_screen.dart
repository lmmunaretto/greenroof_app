import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/producao_cultivo.dart';
import '../services/api_service.dart';
import '../widgets/role_menu.dart';

class ControleProducaoScreen extends StatefulWidget {
  const ControleProducaoScreen({super.key});

  @override
  _ControleProducaoScreenState createState() => _ControleProducaoScreenState();
}

class _ControleProducaoScreenState extends State<ControleProducaoScreen> {
  int currentPage = 1;
  int? filtroAno;
  DateTime? filtroDataProducao;
  int? filtroMes;
  final int itemsPerPage = 4;
  List<ProducaoCultivo> producoes = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarProducoes();
  }

  Future<void> _carregarProducoes() async {
    setState(() => _isLoading = true);
    try {
      producoes = await ApiService.fetchProducoesCultivo();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar produções: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildFiltros() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Ano',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.green, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    value: filtroAno,
                    items: List.generate(10, (index) {
                      int year = DateTime.now().year - index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        filtroAno = value;
                        _carregarProducoes();
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Mês',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.green, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    value: filtroMes,
                    items: List.generate(12, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text(DateFormat.MMMM('pt_BR')
                            .format(DateTime(0, index + 1))),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        filtroMes = value;
                        _carregarProducoes();
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListaProducoes() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (producoes.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma produção encontrada.',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    // Filtrar as produções de acordo com os filtros aplicados
    List<ProducaoCultivo> producoesFiltradas = producoes.where((producao) {
      if (filtroAno != null && producao.dataProducao.year != filtroAno) {
        return false;
      }
      if (filtroMes != null && producao.dataProducao.month != filtroMes) {
        return false;
      }
      if (filtroDataProducao != null &&
          DateFormat('yyyy-MM-dd').format(producao.dataProducao) !=
              DateFormat('yyyy-MM-dd').format(filtroDataProducao!)) {
        return false;
      }
      return true;
    }).toList();

    // Obter apenas os itens da página atual
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage < producoesFiltradas.length)
        ? startIndex + itemsPerPage
        : producoesFiltradas.length;
    final producoesPagina = producoesFiltradas.sublist(startIndex, endIndex);

    return ListView.builder(
      itemCount: producoesPagina.length,
      itemBuilder: (context, index) {
        final producao = producoesPagina[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          color: Colors.green[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Produto: ${producao.produtoNome}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.green[800], fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Data da Produção: ${DateFormat('dd/MM/yyyy', 'pt_BR').format(producao.dataProducao)}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Quantidade Produzida: ${producao.quantidadeProduzida}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaginacao() {
    final totalPages = (producoes.length / itemsPerPage).ceil();

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

  Future<void> _selecionarData() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (selectedDate != null) {
      setState(() {
        currentPage = 1;
        filtroDataProducao = selectedDate;
      });
    }
  }

  void _limparFiltros() {
    setState(() {
      filtroAno = null;
      filtroMes = null;
      filtroDataProducao = null;
      currentPage = 1;
    });
    _carregarProducoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.all(17.0),
          child: Text('Controle de Produção',
              style: Theme.of(context).textTheme.headlineMedium),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Limpar Filtros',
                  icon: const Icon(Icons.refresh, color: Colors.green),
                  onPressed: _limparFiltros,
                ),
                IconButton(
                  tooltip: filtroDataProducao == null
                      ? 'Selecionar Data'
                      : 'Data: ${DateFormat('dd/MM/yyyy', 'pt_BR').format(filtroDataProducao!)}',
                  icon: const Icon(Icons.calendar_today, color: Colors.green),
                  onPressed: _selecionarData,
                ),
              ],
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                _buildFiltros(), // Método para filtros de data, mês e ano
                Expanded(
                  child:
                      _buildListaProducoes(), // Lista das produções com paginação
                ),
                _buildPaginacao(), // Controles de paginação
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const RoleBasedMenu(role: 'Admin'),
    );
  }
}
