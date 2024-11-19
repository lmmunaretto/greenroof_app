import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/produto.dart';
import '../services/api_service.dart';
import '../widgets/role_menu.dart';

class CadastroProducaoScreen extends StatefulWidget {
  const CadastroProducaoScreen({super.key});

  @override
  _CadastroProducaoScreenState createState() => _CadastroProducaoScreenState();
}

class _CadastroProducaoScreenState extends State<CadastroProducaoScreen> {
  List<Produto> produtos = [];
  Produto? produtoSelecionado;
  final TextEditingController quantidadeController = TextEditingController();
  DateTime? dataProducao;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  Future<void> _carregarProdutos() async {
    setState(() => _isLoading = true);
    try {
      produtos = await ApiService.fetchProdutos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar produtos: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cadastrarProducao() async {
    if (produtoSelecionado == null || quantidadeController.text.isEmpty || dataProducao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);
      await ApiService.cadastrarProducaoCultivo(
        produtoId: produtoSelecionado!.id,
        quantidadeProduzida: int.parse(quantidadeController.text),
        dataProducao: dataProducao!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produção cadastrada com sucesso!')),
      );
      Navigator.pushNamed(context, '/controle-producao');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar produção: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    setState(() {
      produtoSelecionado = null;
      quantidadeController.clear();
      dataProducao = null;
    });
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>(
      {required String label,
      required T? value,
      required List<T> items,
      required Function(T?) onChanged,
      required String Function(T) display}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DropdownButtonFormField<T>(
          value: value,
          items: items
              .map((item) =>
                  DropdownMenuItem(value: item, child: Text(display(item))))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.green, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          dropdownColor: Colors.white,
          isExpanded: true,
          menuMaxHeight: 300,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .headlineSmall
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
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
            'Cadastro de Produção',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: IconButton(
              tooltip: 'Limpar Campos',
              icon: const Icon(Icons.refresh, color: Colors.green),
              onPressed: _resetForm,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Cadastrar Produção',
        label: const Text('Cadastrar Produção'),
        backgroundColor: Colors.green,
        onPressed: _cadastrarProducao,
        icon: _isLoading
            ? const Center(
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 3))) 
            : const Icon(Icons.agriculture_outlined),
      ),
      bottomNavigationBar: const RoleBasedMenu(role: 'Admin'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: maxWidth > 600 ? 800 : maxWidth * 0.9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Dados da Produção'),
                    _buildDropdown<Produto>(
                      label: 'Produto',
                      value: produtoSelecionado,
                      items: produtos,
                      display: (produto) => produto.nome,
                      onChanged: (value) =>
                          setState(() => produtoSelecionado = value),
                    ),
                    _buildTextField(
                      'Quantidade Produzida',
                      quantidadeController,
                      Icons.line_weight,
                      isNumber: true,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 365 * 10)),
                          lastDate: DateTime.now(),
                          locale: const Locale('pt', 'BR'),
                        );
                        if (selectedDate != null) {
                          setState(() => dataProducao = selectedDate);
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: Text(dataProducao == null
                          ? 'Selecionar Data'
                          : 'Data Selecionada: ${DateFormat('dd/MM/yyyy', 'pt_BR').format(dataProducao!)}'),
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
