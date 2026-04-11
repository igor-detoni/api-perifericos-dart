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

    try {
      print('Tentando conectar ao NeonDB...');
      connection = await Connection.open(
        Endpoint(
          host: uri.host,
          database: uri.pathSegments.first,
          username: uri.userInfo.split(':')[0],
          password: uri.userInfo.split(':')[1],
          port: uri.port != 0 ? uri.port : 5432,
        ),
        settings: ConnectionSettings(sslMode: SslMode.require),
      );
      print('Conexão com o NeonDB estabelecida com sucesso!');
    } catch (e) {
      print('Erro ao conectar no banco de dados: $e');
      rethrow;
    }
  }
}