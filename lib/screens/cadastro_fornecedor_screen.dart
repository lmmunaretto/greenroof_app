import 'package:flutter/material.dart';
import 'package:greenroof_app/services/api_service.dart';
import 'package:greenroof_app/services/auth_service.dart';
import 'package:greenroof_app/widgets/role_menu.dart';

class CadastroFornecedorScreen extends StatefulWidget {
  const CadastroFornecedorScreen({super.key});

  @override
  State<CadastroFornecedorScreen> createState() =>
      _CadastroFornecedorScreenState();
}

class _CadastroFornecedorScreenState extends State<CadastroFornecedorScreen> {
  final TextEditingController cnpjController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();

  bool _isLoading = false;

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

  Future<void> _cadastrarFornecedor() async {
    if (nomeController.text.isEmpty ||
        cnpjController.text.isEmpty ||
        telefoneController.text.isEmpty ||
        emailController.text.isEmpty ||
        enderecoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      await ApiService.cadastrarFornecedor(
        nomeController.text.trim(),
        cnpjController.text.trim(),
        telefoneController.text.trim(),
        emailController.text.trim(),
        enderecoController.text.trim()
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fornecedor cadastrado com sucesso!')),
      );
      Navigator.pushNamed(context, '/fornecedores');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao cadastrar fornecedor.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    nomeController.clear();
    cnpjController.clear();
    telefoneController.clear();
    emailController.clear();
    enderecoController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.all(17.0),
          child: Text(
            'Cadastro de Fornecedor',
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
        tooltip: 'Cadastrar Fornecedor',
        label: const Text('Cadastrar Fornecedor'),
        backgroundColor: Colors.green,
        onPressed: _cadastrarFornecedor,
        icon: _isLoading
            ? const Center(
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 3)),
              )
            : const Icon(Icons.person_add),
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
                    _buildSectionHeader('Dados do Fornecedor'),
                    _buildTextField('Nome', nomeController, Icons.business),
                    _buildTextField(
                        'CNPJ', cnpjController, Icons.badge, isNumber: true),
                    _buildTextField('Telefone', telefoneController,
                        Icons.phone, isNumber: true),
                    _buildTextField('E-mail', emailController, Icons.email),
                    _buildTextField(
                        'Endereço', enderecoController, Icons.location_on),
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
