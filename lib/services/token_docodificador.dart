import 'dart:convert';

import 'package:greenroof_app/models/usuario.dart';

class TokenDecoder {
  static Usuario decodeToken(String token) {
    final parts = token.split('.');
    final payload =
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final decodedToken = json.decode(payload);
    return Usuario.fromDecodedToken(decodedToken);
  }
}
