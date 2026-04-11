import 'package:backend/db/database.dart';

void main() async {
  try {
    await Database.conectar();
    
  } catch (e) {
    print('Falha ao iniciar o servidor devido a erro no banco: $e');
  }
}