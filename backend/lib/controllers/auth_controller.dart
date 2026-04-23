import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dotenv/dotenv.dart';

class AuthController {
  Router get router {
    final r = Router();

    r.post('/login', (Request request) async {
      final payload = await request.readAsString();
      final data = jsonDecode(payload);

      if (data['usuario'] == 'admin' && data['senha'] == '1234') {
        var env = DotEnv(includePlatformEnvironment: true)..load();
        final secret = env['JWT_SECRET'] ?? '';

        final jwt = JWT(
          {
            'id': 1,
            'role': 'admin',
          },
        );

        final token = jwt.sign(SecretKey(secret), expiresIn: Duration(hours: 1));

        return Response.ok(
          jsonEncode({'token': token}),
          headers: {'content-type': 'application/json'},
        );
      }

      return Response.forbidden(jsonEncode({'erro': 'Credenciais inválidas'}));
    });

    return r;
  }
}