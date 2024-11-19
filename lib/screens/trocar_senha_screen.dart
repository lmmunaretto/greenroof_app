import 'package:flutter/material.dart';
import 'package:greenroof_app/services/auth_service.dart';
import 'package:greenroof_app/widgets/outlined_text_field.dart';
import 'package:greenroof_app/widgets/primary_button.dart';

class TrocarSenhaScreen extends StatelessWidget {
  TrocarSenhaScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController novaSenhaController = TextEditingController();
  final TextEditingController senhaAtualController = TextEditingController();

  Future<void> handleTrocarSenha(BuildContext context) async {
    final email = emailController.text;
    final senhaAtual = senhaAtualController.text;
    final novaSenha = novaSenhaController.text;

    final sucesso = await AuthService.trocarSenha(
        email: email, senhaAtual: senhaAtual, novaSenha: novaSenha);

    if (sucesso) {
      Navigator.pushReplacementNamed(context, '/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Troca de senhas falhou.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: LayoutBuilder(builder: (context, constraints) {
          double width =
              constraints.maxWidth > 600 ? 400 : constraints.maxWidth * 0.9;

          return Center(
            child: Container(
              width: width,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Greenroof",
                    style: Theme.of(context).textTheme.headlineMedium
                  ),
                  const SizedBox(height: 40),
                  OutlinedTextField(controller: emailController, label: 'E-mail'),
                  const SizedBox(height: 16),
                  OutlinedTextField(controller: senhaAtualController, label: 'Senha Atual', isPassword: true),
                  const SizedBox(height: 16),
                  OutlinedTextField(controller: novaSenhaController, label: 'Nova Senha', isPassword: true),
                  const SizedBox(height: 32),
                  PrimaryButton(onPressed: () => handleTrocarSenha(context), text: 'Trocar Senha'),
                ],
              ),
            ),
          );
        }));
  }
}
