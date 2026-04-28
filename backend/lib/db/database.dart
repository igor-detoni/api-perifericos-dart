import 'package:postgres/postgres.dart';
import 'package:dotenv/dotenv.dart';

class Database {
  static late Connection connection;

  static Future<void> conectar() async {
    var env = DotEnv(includePlatformEnvironment: true)..load();
    final dbUrl = env['DATABASE_URL'];

    if (dbUrl == null || dbUrl.isEmpty) {
      throw Exception('DATABASE_URL não encontrada no arquivo .env');
    }

    final uri = Uri.parse(dbUrl);
    
    final isLocal = uri.host == 'localhost' || uri.host == '127.0.0.1';

    try {
      print('Tentando conectar ao banco de dados (${uri.host})...');
      connection = await Connection.open(
        Endpoint(
          host: uri.host,
          database: uri.pathSegments.first,
          username: uri.userInfo.split(':')[0],
          password: uri.userInfo.split(':')[1],
          port: uri.port != 0 ? uri.port : 5432,
        ),
        settings: ConnectionSettings(
          sslMode: isLocal ? SslMode.disable : SslMode.require,
          connectTimeout: Duration(seconds: 30),
        ),
      );
      print('Conexão com o banco de dados estabelecida com sucesso!');

      await inicializarTabelas();
      
    } catch (e) {
      print('Erro ao conectar no banco de dados: $e');
      rethrow;
    }
  }

  static Future<void> inicializarTabelas() async {
    print('Verificando banco de dados...');

    try {
      await connection.execute('''
        CREATE TABLE IF NOT EXISTS marcas (
          id SERIAL PRIMARY KEY,
          nome VARCHAR(255) NOT NULL
        );
      ''');

      await connection.execute('''
        CREATE TABLE IF NOT EXISTS produtos (
          id SERIAL PRIMARY KEY,
          nome VARCHAR(255) NOT NULL,
          categoria VARCHAR(255) NOT NULL,
          preco NUMERIC(10,2) NOT NULL,
          marcaId INT NOT NULL,
          CONSTRAINT fk_marca 
            FOREIGN KEY(marcaId) 
            REFERENCES marcas(id)
        );
      ''');

      print('Tabelas inicializadas com sucesso!');
    } catch (e) {
      print('Erro ao criar tabelas: $e');
      rethrow;
    }
  }
}