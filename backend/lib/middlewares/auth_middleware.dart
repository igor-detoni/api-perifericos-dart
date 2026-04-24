import 'package:shelf/shelf.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dotenv/dotenv.dart';

Middleware authMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      if (request.method == 'GET' || request.url.path == 'auth/login') {
        return innerHandler(request);
      }
      final authHeader = request.headers['authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.forbidden('Acesso negado: Token ausente ou mal formatado. Use "Bearer <token>".');
      }

      final token = authHeader.substring(7); 
      
      var env = DotEnv(includePlatformEnvironment: true)..load();
      final secret = env['JWT_SECRET'];

      if (secret == null) {
        return Response.internalServerError(body: 'Erro no servidor: JWT_SECRET não configurado.');
      }

      try {
        JWT.verify(token, SecretKey(secret));
        
        return innerHandler(request);
      } catch (e) {
        return Response.forbidden('Acesso negado: Token inválido ou expirado.');
      }
    };
  };
}