import 'package:backend/db/database.dart';
import 'package:backend/models/marca.dart';
import 'package:postgres/postgres.dart';

class MarcaRepository {
  // 1. Listar todos (GET)
  Future<List<Marca>> listarTodas() async {
    final result = await Database.connection.execute('SELECT * FROM marcas ORDER BY id ASC');
    
    return result.map((row) => Marca.fromJson(row.toColumnMap())).toList();
  }

  Future<Marca?> buscarPorId(int id) async {
    final result = await Database.connection.execute(
      Sql.named('SELECT * FROM marcas WHERE id = @id'),
      parameters: {'id': id},
    );

    if (result.isEmpty) return null;
    return Marca.fromJson(result.first.toColumnMap());
  }

  Future<Marca> criar(Marca marca) async {
    final result = await Database.connection.execute(
      Sql.named('INSERT INTO marcas (nome) VALUES (@nome) RETURNING id, nome'),
      parameters: {'nome': marca.nome},
    );

    return Marca.fromJson(result.first.toColumnMap());
  }

  Future<Marca?> atualizar(int id, Marca marca) async {
    final result = await Database.connection.execute(
      Sql.named('UPDATE marcas SET nome = @nome WHERE id = @id RETURNING id, nome'),
      parameters: {
        'nome': marca.nome,
        'id': id,
      },
    );

    if (result.isEmpty) return null;
    return Marca.fromJson(result.first.toColumnMap());
  }

  Future<bool> remover(int id) async {
    final result = await Database.connection.execute(
      Sql.named('DELETE FROM marcas WHERE id = @id'),
      parameters: {'id': id},
    );

    return result.affectedRows > 0;
  }
}