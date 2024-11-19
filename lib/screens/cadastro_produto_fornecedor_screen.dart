import 'package:flutter/material.dart';
import 'package:greenroof_app/models/fornecedor.dart';
import 'package:greenroof_app/services/api_service.dart';
import 'package:greenroof_app/services/auth_service.dart';
import 'package:greenroof_app/widgets/role_menu.dart';

class CadastroProdutoFornecedorScreen extends StatefulWidget {
  const CadastroProdutoFornecedorScreen({super.key});

  @override
  State<CadastroProdutoFornecedorScreen> createState() =>
      _CadastroProdutoFornecedorScreenState();
}

class _CadastroProdutoFornecedorScreenState
    extends State<CadastroProdutoFornecedorScreen> {
  final TextEditingController descricaoController = TextEditingController();
  int? fornecedorSelecionado;
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController precoController = TextEditingController();
  final TextEditingController quantidadeController = TextEditingController();
  String? tipoSelecionado;

  final _formKey = GlobalKey<FormState>();
  List<Fornecedor> _fornecedores = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarFornecedores();
  }

  Future<void> _carregarFornecedores() async {
    try {
      final fornecedoresResponse = await ApiService.fetchFornecedores();
      setState(() {
        _fornecedores = fornecedoresResponse;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar fornecedores: $e')),
      );
    }
  }

  Future<void> _cadastrarProdutoFornecedor() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);

      await ApiService.cadastrarProdutoFornecedor(
        nome: nomeController.text.trim(),
        descricao: descricaoController.text.trim(),
        quantidade: int.parse(quantidadeController.text.trim()),
        preco: double.parse(precoController.text.trim()),
        tipo: tipoSelecionado!,
        fornecedorId: fornecedorSelecionado!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto cadastrado com sucesso!')),
      );
      Navigator.pushNamed(context, '/fornecedores');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao cadastrar produto.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Campo obrigatório';
          }
          if (isNumber && double.tryParse(value) == null) {
            return 'Insira um número válido';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) display,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(display(item)),
                ))
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
            'Cadastro de Produto do Fornecedor',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: IconButton(
              tooltip: 'Limpar Campos',
              icon: const Icon(Icons.refresh, color: Colors.green),
              onPressed: () {
                _formKey.currentState?.reset();
                nomeController.clear();
                descricaoController.clear();
                quantidadeController.clear();
                precoController.clear();
                setState(() {
                  tipoSelecionado = null;
                  fornecedorSelecionado = null;
                });
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Cadastrar produto do fornecedor',
        label: const Text('Cadastrar Produto'),
        backgroundColor: Colors.green,
        onPressed: _cadastrarProdutoFornecedor,
        icon: _isLoading
            ? const Center(
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 3)))
            : const Icon(Icons.add),
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Form(
                key: _formKey,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth > 600
                        ? 800
                        : constraints.maxWidth * 0.9,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Dados do Produto do Fornecedor'),
                      _buildTextField(
                        label: 'Nome do Produto',
                        controller: nomeController,
                        icon: Icons.text_fields,
                      ),
                      _buildTextField(
                        label: 'Descrição',
                        controller: descricaoController,
                        icon: Icons.description,
                      ),
                      _buildTextField(
                        label: 'Quantidade',
                        controller: quantidadeController,
                        icon: Icons.numbers,
                        isNumber: true,
                      ),
                      _buildTextField(
                        label: 'Preço',
                        controller: precoController,
                        icon: Icons.monetization_on,
                        isNumber: true,
                      ),
                      _buildDropdown<String>(
                        label: 'Tipo de Produto',
                        value: tipoSelecionado,
                        items: ['Fertilizante', 'Semente', 'Outro'],
                        display: (item) => item,
                        onChanged: (value) =>
                            setState(() => tipoSelecionado = value),
                      ),
                      _buildDropdown<int>(
                        label: 'Fornecedor',
                        value: fornecedorSelecionado,
                        items: _fornecedores.map((f) => f.id).toList(),
                        display: (id) =>
                            _fornecedores.firstWhere((f) => f.id == id).nome,
                        onChanged: (value) =>
                            setState(() => fornecedorSelecionado = value),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
