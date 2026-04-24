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

      Map<String, dynamic> data;

      try {
        data = jsonDecode(payload);
      } catch (e) {
        return Response(
          400, 
          body: jsonEncode({'erro': 'JSON mal formatado. Verifique se não há valores vazios, vírgulas sobrando ou aspas faltando.'}), 
          headers: {'content-type': 'application/json'}
        );
      }

      List<String> erros = [];
      
      if (!data.containsKey('nome') || data['nome'].toString().trim().isEmpty) erros.add('O campo "nome" é obrigatório.');
      if (!data.containsKey('categoria') || data['categoria'].toString().trim().isEmpty) erros.add('O campo "categoria" é obrigatório.');
      if (!data.containsKey('preco') || data['preco'] == null) erros.add('O campo "preco" é obrigatório.');
      if (!data.containsKey('marcaId') || data['marcaId'] == null) erros.add('O campo "marcaId" é obrigatório.');

      if (erros.isNotEmpty) {
        return Response(
          400, 
          body: jsonEncode({'erros': erros}), 
          headers: {'content-type': 'application/json'}
        );
      }
      
      final novoProduto = Produto.fromJson(data);
      final produtoCriado = await repository.criar(novoProduto);
      
      return Response(201, body: jsonEncode(produtoCriado.toJson()), headers: {'content-type': 'application/json'});
    });

    // 4. PUT /<id>
    r.put('/<id>', (Request request, String id) async {
      final payload = await request.readAsString();
      Map<String, dynamic> data;

      try {
        data = jsonDecode(payload);
      } catch (e) {
        return Response(
          400, 
          body: jsonEncode({'erro': 'JSON mal formatado. Verifique se não há valores vazios, vírgulas sobrando ou aspas faltando.'}), 
          headers: {'content-type': 'application/json'}
        );
      }

      List<String> erros = [];
      
      if (!data.containsKey('nome') || data['nome'].toString().trim().isEmpty) erros.add('O campo "nome" é obrigatório.');
      if (!data.containsKey('categoria') || data['categoria'].toString().trim().isEmpty) erros.add('O campo "categoria" é obrigatório.');
      if (!data.containsKey('preco') || data['preco'] == null) erros.add('O campo "preco" é obrigatório.');
      if (!data.containsKey('marcaId') || data['marcaId'] == null) erros.add('O campo "marcaId" é obrigatório.');

      if (erros.isNotEmpty) {
        return Response(
          400, 
          body: jsonEncode({'erros': erros}), 
          headers: {'content-type': 'application/json'}
        );
      }
      
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