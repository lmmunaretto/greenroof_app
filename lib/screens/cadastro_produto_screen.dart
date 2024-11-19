import 'package:flutter/material.dart';
import 'package:greenroof_app/services/api_service.dart';
import 'package:greenroof_app/services/auth_service.dart';
import 'package:greenroof_app/widgets/role_menu.dart';

class CadastroProdutoScreen extends StatefulWidget {
  const CadastroProdutoScreen({super.key});

  @override
  _CadastroProdutoScreenState createState() => _CadastroProdutoScreenState();
}

class _CadastroProdutoScreenState extends State<CadastroProdutoScreen> {
  final TextEditingController caloriasController = TextEditingController();
  final TextEditingController carboidratosController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController fibrasController = TextEditingController();
  final TextEditingController gordurasController = TextEditingController();
  final TextEditingController limiteMinimoController = TextEditingController();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController precoController = TextEditingController();
  final TextEditingController proteinasController = TextEditingController();
  final TextEditingController quantidadeController = TextEditingController();
  String? tipoSelecionado;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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

  Widget _buildDropdown(String label, String? value, List<String> items,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),
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

  Future<void> _cadastrarProduto() async {
    if (nomeController.text.isEmpty ||
        descricaoController.text.isEmpty ||
        quantidadeController.text.isEmpty ||
        precoController.text.isEmpty ||
        limiteMinimoController.text.isEmpty ||
        caloriasController.text.isEmpty ||
        carboidratosController.text.isEmpty ||
        proteinasController.text.isEmpty ||
        gordurasController.text.isEmpty ||
        fibrasController.text.isEmpty ||
        tipoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      double calorias = double.tryParse(caloriasController.text.trim()) ?? -1;
      double carboidratos =
          double.tryParse(carboidratosController.text.trim()) ?? -1;
      double proteinas = double.tryParse(proteinasController.text.trim()) ?? -1;
      double gorduras = double.tryParse(gordurasController.text.trim()) ?? -1;
      double fibras = double.tryParse(fibrasController.text.trim()) ?? -1;

      if (calorias < 0 ||
          carboidratos < 0 ||
          proteinas < 0 ||
          gorduras < 0 ||
          fibras < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, insira valores válidos.')),
        );
        return;
      }

      final produto = await ApiService.cadastrarProduto(
        nomeController.text.trim(),
        descricaoController.text.trim(),
        int.parse(quantidadeController.text.trim()),
        double.parse(precoController.text
            .trim()
            .replaceAll(',', '.')),
        limiteEstoque: int.parse(limiteMinimoController.text.trim()),
        tipo: tipoSelecionado!,
      );

      await ApiService.cadastrarInformacoesNutricionais(
        produtoId: produto['id'],
        calorias: calorias,
        carboidratos: carboidratos,
        proteinas: proteinas,
        gorduras: gorduras,
        fibras: fibras,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto cadastrado com sucesso!')),
      );
      Navigator.pushNamed(context, '/produtos');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao cadastrar produto.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    nomeController.clear();
    descricaoController.clear();
    quantidadeController.clear();
    limiteMinimoController.clear();
    precoController.clear();
    caloriasController.clear();
    carboidratosController.clear();
    proteinasController.clear();
    gordurasController.clear();
    fibrasController.clear();
    setState(() {
      tipoSelecionado = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.all(17.0),
          child: Text(
            'Cadastro de Produto',
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
        tooltip: 'Cadastrar Produto',
        label: const Text('Cadastrar Produto'),
        backgroundColor: Colors.green,
        onPressed: _cadastrarProduto,
        icon: _isLoading
            ? const Center(
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 3)))
            : const Icon(Icons.list),
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
                    _buildSectionHeader('Dados do Produto'),
                    _buildTextField(
                        'Nome do Produto', nomeController, Icons.text_fields),
                    _buildTextField(
                        'Descrição', descricaoController, Icons.description),
                    Row(
                      children: [
                        Expanded(
                            child: _buildTextField('Quantidade',
                                quantidadeController, Icons.numbers,
                                isNumber: true)),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _buildTextField('Limite Estoque',
                                limiteMinimoController, Icons.warning,
                                isNumber: true)),
                      ],
                    ),
                    _buildTextField(
                        'Preço', precoController, Icons.monetization_on,
                        isNumber: true),
                    _buildDropdown('Tipo de Produto', tipoSelecionado,
                        ['Hortaliça', 'Fruta', 'Legume', 'Vegetal'], (value) {
                      setState(() => tipoSelecionado = value);
                    }),
                    const SizedBox(height: 16),
                    _buildSectionHeader('Informações Nutricionais'),
                    Row(
                      children: [
                        Expanded(
                            child: _buildTextField('Calorias',
                                caloriasController, Icons.local_fire_department,
                                isNumber: true)),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _buildTextField('Carboidratos',
                                carboidratosController, Icons.cookie,
                                isNumber: true)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: _buildTextField('Proteínas',
                                proteinasController, Icons.restaurant,
                                isNumber: true)),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _buildTextField(
                                'Gorduras', gordurasController, Icons.opacity,
                                isNumber: true)),
                      ],
                    ),
                    _buildTextField('Fibras', fibrasController, Icons.grass,
                        isNumber: true),
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
