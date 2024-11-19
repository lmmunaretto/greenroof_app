import 'package:greenroof_app/models/usuario.dart';

class LoginResult {
  LoginResult({required this.sucesso, this.usuario});

  final bool sucesso;
  final Usuario? usuario;
}