import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/marca.dart';
import 'auth_service.dart';

class MarcaService {
  static const String _baseUrl = 'http://localhost:8080';

  Future<List<Marca>> listarTodas() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/marcas'),
      headers: AuthService.headersPublic,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Marca.fromJson(json)).toList();
    }
    throw Exception('Erro ao listar marcas: ${response.statusCode}');
  }

  Future<Marca> criar(Marca marca) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/marcas'),
      headers: AuthService.headersAuth,
      body: jsonEncode(marca.toJson()),
    );
    if (response.statusCode == 201) {
      return Marca.fromJson(jsonDecode(response.body));
    }
    throw Exception('Erro ao criar marca: ${response.statusCode}');
  }

  Future<Marca> atualizar(int id, Marca marca) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/marcas/$id'),
      headers: AuthService.headersAuth,
      body: jsonEncode(marca.toJson()),
    );
    if (response.statusCode == 200) {
      return Marca.fromJson(jsonDecode(response.body));
    }
    throw Exception('Erro ao atualizar marca: ${response.statusCode}');
  }

  Future<void> remover(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/marcas/$id'),
      headers: AuthService.headersAuth,
    );
    if (response.statusCode != 204) {
      throw Exception('Erro ao remover marca: ${response.statusCode}');
    }
  }
}