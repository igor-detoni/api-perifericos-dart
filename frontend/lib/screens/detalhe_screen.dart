import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../services/produto_service.dart';
import 'formulario_screen.dart';

class DetalheScreen extends StatefulWidget {
  final Produto produto;
  final String nomeMarca;

  const DetalheScreen({
    super.key,
    required this.produto,
    required this.nomeMarca,
  });

  @override
  State<DetalheScreen> createState() => _DetalheScreenState();
}

class _DetalheScreenState extends State<DetalheScreen> {
  final _produtoService = ProdutoService();
  late Produto _produto;
  late String _nomeMarca;

  @override
  void initState() {
    super.initState();
    _produto = widget.produto;
    _nomeMarca = widget.nomeMarca;
  }

  Future<void> _confirmarExclusao() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja excluir "${_produto.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    try {
      await _produtoService.remover(_produto.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto excluído com sucesso.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Produto'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
            onPressed: () async {
              final produtoAtualizado = await Navigator.push<Produto>(
                context,
                MaterialPageRoute(
                  builder: (_) => FormularioScreen(produto: _produto),
                ),
              );
              if (produtoAtualizado != null) {
                setState(() => _produto = produtoAtualizado);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Excluir',
            onPressed: _confirmarExclusao,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.deepPurpleAccent,
                child: const Icon(
                  Icons.computer,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _campo('Nome', _produto.nome),
            _campo('Marca', _nomeMarca),
            _campo('Categoria', _produto.categoria),
            _campo('Preço', 'R\$ ${_produto.preco.toStringAsFixed(2)}'),
            _campo('ID', _produto.id.toString()),
          ],
        ),
      ),
    );
  }

  Widget _campo(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
