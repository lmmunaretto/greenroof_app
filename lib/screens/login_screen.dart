import 'package:flutter/material.dart';
import 'package:greenroof_app/widgets/outlined_text_field.dart';
import 'package:greenroof_app/widgets/primary_button.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  Future<void> handleLogin(BuildContext context) async {
    final email = emailController.text;
    final senha = senhaController.text;

    final result = await AuthService.login(email, senha);
    final usuario = result.usuario;

    if (result.sucesso && usuario != null && !usuario.deveTrocarSenha) {
      Navigator.pushReplacementNamed(context, '/produtos');
    } else if (result.sucesso && usuario != null && usuario.deveTrocarSenha) {
      Navigator.pushReplacementNamed(context, '/trocar-senha');
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Login falhou.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
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
                    'Greenroof',
                    style: Theme.of(context).textTheme.headlineMedium
                  ),
                  const SizedBox(height: 40),
                  OutlinedTextField(controller: emailController, label: 'Email'),
                  const SizedBox(height: 16),
                  OutlinedTextField(controller: senhaController, label: 'Senha', isPassword: true),
                  const SizedBox(height: 32),
                  PrimaryButton(onPressed: () => handleLogin(context), text: 'Entrar'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
