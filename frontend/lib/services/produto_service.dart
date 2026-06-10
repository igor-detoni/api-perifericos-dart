import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/produto.dart';
import 'auth_service.dart';

class ProdutoService {
  static const String _baseUrl = 'http://localhost:8080';

  Future<List<Produto>> listarTodos() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/produtos'),
      headers: AuthService.headersPublic,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Produto.fromJson(json)).toList();
    }
    throw Exception('Erro ao listar produtos: ${response.statusCode}');
  }

  Future<Produto> criar(Produto produto) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/produtos'),
      headers: AuthService.headersAuth,
      body: jsonEncode(produto.toJson()),
    );
    if (response.statusCode == 201) {
      return Produto.fromJson(jsonDecode(response.body));
    }
    throw Exception('Erro ao criar produto: ${response.statusCode}');
  }

  Future<Produto> atualizar(int id, Produto produto) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/produtos/$id'),
      headers: AuthService.headersAuth,
      body: jsonEncode(produto.toJson()),
    );
    if (response.statusCode == 200) {
      return Produto.fromJson(jsonDecode(response.body));
    }
    throw Exception('Erro ao atualizar produto: ${response.statusCode}');
  }

  Future<void> remover(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/produtos/$id'),
      headers: AuthService.headersAuth,
    );
    if (response.statusCode != 204) {
      throw Exception('Erro ao remover produto: ${response.statusCode}');
    }
  }
}