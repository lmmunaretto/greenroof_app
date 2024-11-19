class Usuario {
  Usuario({
    required this.nome,
    required this.email,
    required this.role,
    required this.usuarioId,
    required this.deveTrocarSenha,
    required this.clienteId,
  });

  factory Usuario.fromDecodedToken(Map<String, dynamic> decodedToken) {
    return Usuario(
      nome: decodedToken['sub'],
      email: decodedToken['email'],
      role: decodedToken['role'],
      usuarioId: decodedToken['usuarioId'],
      deveTrocarSenha: decodedToken['deveTrocarSenha'] == "True",
      clienteId: decodedToken['clienteId'],
    );
  }

  final String clienteId;
  final bool deveTrocarSenha;
  final String email;
  final String nome;
  final String role;
  final String usuarioId;
}
