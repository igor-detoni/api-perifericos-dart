import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:backend/repositories/produto_repository.dart';
import 'package:backend/models/produto.dart';

class ProdutoController {
  final ProdutoRepository repository = ProdutoRepository();

  Router get router {
    final r = Router();

    // 1. GET /
    r.get('/', (Request request) async {
      final produtos = await repository.listarTodos();
      final body = jsonEncode(produtos.map((p) => p.toJson()).toList());
      return Response.ok(body, headers: {'content-type': 'application/json'});
    });

    // 2. GET /<id>
    r.get('/<id>', (Request request, String id) async {
      final produto = await repository.buscarPorId(int.parse(id));
      if (produto == null) {
        return Response.notFound(jsonEncode({'erro': 'Produto não encontrado'}));
      }
      return Response.ok(jsonEncode(produto.toJson()), headers: {'content-type': 'application/json'});
    });

    // 3. POST /
    r.post('/', (Request request) async {
      final payload = await request.readAsString();
      final data = jsonDecode(payload);
      
      final novoProduto = Produto.fromJson(data);
      final produtoCriado = await repository.criar(novoProduto);
      
      return Response(201, body: jsonEncode(produtoCriado.toJson()), headers: {'content-type': 'application/json'});
    });

    // 4. PUT /<id>
    r.put('/<id>', (Request request, String id) async {
      final payload = await request.readAsString();
      final data = jsonDecode(payload);
      
      final produtoAtualizado = await repository.atualizar(int.parse(id), Produto.fromJson(data));
      if (produtoAtualizado == null) {
        return Response.notFound(jsonEncode({'erro': 'Produto não encontrado'}));
      }
      return Response.ok(jsonEncode(produtoAtualizado.toJson()), headers: {'content-type': 'application/json'});
    });

    // 5. DELETE /<id>
    r.delete('/<id>', (Request request, String id) async {
      final removido = await repository.remover(int.parse(id));
      if (!removido) {
        return Response.notFound(jsonEncode({'erro': 'Produto não encontrado'}));
      }
      return Response(204);
    });

    return r;
  }
}