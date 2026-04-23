import 'package:shelf/shelf_io.dart' as io;
import 'package:backend/db/database.dart';
import 'package:backend/app.dart';

void main() async {
  try {
    await Database.conectar();
    
    final app = App();
    final server = await io.serve(app.handler, 'localhost', 8080);
    
    print('Servidor HTTP rodando em http://${server.address.host}:${server.port}');
  } catch (e) {
    print('Falha ao iniciar o sistema: $e');
  }
}