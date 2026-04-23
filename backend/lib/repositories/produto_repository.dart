import 'package:backend/db/database.dart';
import 'package:backend/models/produto.dart';
import 'package:postgres/postgres.dart';

class ProdutoRepository {
  Future<List<Produto>> listarTodos() async {
    final result = await Database.connection.execute('SELECT * FROM produtos ORDER BY id ASC');
    return result.map((row) => Produto.fromJson(row.toColumnMap())).toList();
  }

  Future<Produto?> buscarPorId(int id) async {
    final result = await Database.connection.execute(
      Sql.named('SELECT * FROM produtos WHERE id = @id'),
      parameters: {'id': id},
    );

    if (result.isEmpty) return null;
    return Produto.fromJson(result.first.toColumnMap());
  }

  Future<List<Produto>> listarPorMarca(int marcaId) async {
    final result = await Database.connection.execute(
      Sql.named('SELECT * FROM produtos WHERE marcaId = @marcaId ORDER BY id ASC'),
      parameters: {'marcaId': marcaId},
    );

    return result.map((row) => Produto.fromJson(row.toColumnMap())).toList();
  }

  Future<Produto> criar(Produto produto) async {
    final result = await Database.connection.execute(
      Sql.named('''
        INSERT INTO produtos (nome, categoria, preco, marcaId) 
        VALUES (@nome, @categoria, @preco, @marcaId) 
        RETURNING id, nome, categoria, preco, marcaId
      '''),
      parameters: {
        'nome': produto.nome,
        'categoria': produto.categoria,
        'preco': produto.preco,
        'marcaId': produto.marcaId,
      },
    );

    return Produto.fromJson(result.first.toColumnMap());
  }

  Future<Produto?> atualizar(int id, Produto produto) async {
    final result = await Database.connection.execute(
      Sql.named('''
        UPDATE produtos 
        SET nome = @nome, categoria = @categoria, preco = @preco, marcaId = @marcaId 
        WHERE id = @id 
        RETURNING id, nome, categoria, preco, marcaId
      '''),
      parameters: {
        'id': id,
        'nome': produto.nome,
        'categoria': produto.categoria,
        'preco': produto.preco,
        'marcaId': produto.marcaId,
      },
    );

    if (result.isEmpty) return null;
    return Produto.fromJson(result.first.toColumnMap());
  }

  Future<bool> remover(int id) async {
    final result = await Database.connection.execute(
      Sql.named('DELETE FROM produtos WHERE id = @id'),
      parameters: {'id': id},
    );

    return result.affectedRows > 0;
  }
}