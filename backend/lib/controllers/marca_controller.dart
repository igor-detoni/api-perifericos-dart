import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:backend/repositories/marca_repository.dart';
import 'package:backend/models/marca.dart';
import 'package:backend/repositories/produto_repository.dart';

class MarcaController {
  final MarcaRepository repository = MarcaRepository();

  Router get router {
    final r = Router();

    // 1. GET /
    r.get('/', (Request request) async {
      final marcas = await repository.listarTodas();
      final body = jsonEncode(marcas.map((m) => m.toJson()).toList());
      return Response.ok(body, headers: {'content-type': 'application/json'});
    });

    // 2. GET /<id>
    r.get('/<id>', (Request request, String id) async {
      final marca = await repository.buscarPorId(int.parse(id));
      if (marca == null) {
        return Response.notFound(jsonEncode({'erro': 'Marca não encontrada'})); // Status 404
      }
      return Response.ok(jsonEncode(marca.toJson()), headers: {'content-type': 'application/json'});
    });

    // 3. POST /
    r.post('/', (Request request) async {
      final payload = await request.readAsString();
      final data = jsonDecode(payload);

      if (!data.containsKey('nome') || data['nome'].toString().trim().isEmpty) {
        return Response(
          400, 
          body: jsonEncode({'erro': 'O campo "nome" é obrigatório e não pode estar vazio.'}), 
          headers: {'content-type': 'application/json'}
        );
      }
      
      final novaMarca = Marca.fromJson(data);
      final marcaCriada = await repository.criar(novaMarca);
      
      return Response(201, body: jsonEncode(marcaCriada.toJson()), headers: {'content-type': 'application/json'});
    });

    // 4. PUT /<id>
    r.put('/<id>', (Request request, String id) async {
      final payload = await request.readAsString();
      final data = jsonDecode(payload);

      if (!data.containsKey('nome') || data['nome'].toString().trim().isEmpty) {
        return Response(
          400, 
          body: jsonEncode({'erro': 'O campo "nome" é obrigatório e não pode estar vazio.'}), 
          headers: {'content-type': 'application/json'}
        );
      }
      
      final marcaAtualizada = await repository.atualizar(int.parse(id), Marca.fromJson(data));
      if (marcaAtualizada == null) {
        return Response.notFound(jsonEncode({'erro': 'Marca não encontrada'}));
      }
      return Response.ok(jsonEncode(marcaAtualizada.toJson()), headers: {'content-type': 'application/json'});
    });

    // 5. DELETE /<id>
    r.delete('/<id>', (Request request, String id) async {
      try {
        final removido = await repository.remover(int.parse(id));
        if (!removido) {
          return Response.notFound(jsonEncode({'erro': 'Marca não encontrada'}));
        }
        return Response(204); 
      } catch (e) {
        if (e.toString().contains('23503') || e.toString().contains('violates foreign key constraint')) {
          return Response(
            400,
            body: jsonEncode({'erro': 'Não é possível excluir esta marca porque existem produtos vinculados a ela.'}), 
            headers: {'content-type': 'application/json'}
          );
        }
        return Response.internalServerError(
          body: jsonEncode({'erro': 'Erro interno ao tentar remover a marca.'}),
          headers: {'content-type': 'application/json'}
        );
      }
    });

    // ROTA EXTRA GET /marcas/<id>/produtos
    r.get('/<id>/produtos', (Request request, String id) async {
      final produtos = await ProdutoRepository().listarPorMarca(int.parse(id));
      return Response.ok(jsonEncode(produtos.map((p) => p.toJson()).toList()), headers: {'content-type': 'application/json'});
    });

    return r;
  }
}