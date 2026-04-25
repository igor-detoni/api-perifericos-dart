import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/produto.dart';

class ProdutosPage extends StatefulWidget {
  const ProdutosPage({super.key});

  @override
  State<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {
  List<Produto> _itens = [];
  Map<int, String> _marcas = {};
  bool carregando = true;
  String mensagemErro = '';

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final urlProdutos = Uri.parse('http://localhost:8080/produtos');
      final urlMarcas = Uri.parse('http://localhost:8080/marcas');

      final responses = await Future.wait([
        http.get(urlProdutos),
        http.get(urlMarcas),
      ]);

      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        final List<dynamic> jsonProdutos = jsonDecode(responses[0].body);
        final List<dynamic> jsonMarcas = jsonDecode(responses[1].body);

        Map<int, String> mapaMarcas = {};
        for (var marca in jsonMarcas) {
          mapaMarcas[marca['id']] = marca['nome'];
        }

        setState(() {
          _marcas = mapaMarcas;
          _itens = jsonProdutos.map((json) => Produto.fromJson(json)).toList();
          carregando = false;
        });
      } else {
        setState(() {
          mensagemErro = 'Erro ao carregar dados. Verifique a API.';
          carregando = false;
        });
      }
    } catch (e) {
      setState(() {
        mensagemErro = 'Falha na conexão com a API: $e';
        carregando = false;
      });
    }
  }

  IconData _obterIconePorCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'mouse':
        return Icons.mouse;
      case 'teclado':
        return Icons.keyboard;
      case 'headset':
        return Icons.headset_mic;
      case 'microfone':
        return Icons.mic;
      case 'mousepad':
        return Icons.crop_landscape;
      default:
        return Icons.computer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos Periféricos'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (mensagemErro.isNotEmpty) {
      return Center(
        child: Text(
          mensagemErro, 
          style: const TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_itens.isEmpty) {
      return const Center(child: Text('Nenhum produto cadastrado.'));
    }

    return ListView.builder(
      itemCount: _itens.length,
      itemBuilder: (context, index) {
        final produto = _itens[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurpleAccent,
              child: Icon(_obterIconePorCategoria(produto.categoria), color: Colors.white),
            ),
            title: Text(produto.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${_marcas[produto.marcaId] ?? 'Desconhecida'} • ${produto.categoria}'),
            trailing: Text(
              'R\$ ${produto.preco.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
            ),
          ),
        );
      },
    );
  }
}