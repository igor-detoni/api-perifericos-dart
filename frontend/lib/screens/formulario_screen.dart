import 'package:flutter/material.dart';
import '../models/marca.dart';
import '../models/produto.dart';
import '../services/marca_service.dart';
import '../services/produto_service.dart';

const _categorias = ['Mouse', 'Teclado', 'Headset', 'Microfone', 'Mousepad'];

class FormularioScreen extends StatefulWidget {
  final Produto? produto;

  const FormularioScreen({super.key, this.produto});

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _precoController = TextEditingController();

  final _produtoService = ProdutoService();
  final _marcaService = MarcaService();

  List<Marca> _marcas = [];
  int? _marcaSelecionada;
  String? _categoriaSelecionada;
  bool _carregando = false;
  bool _carregandoMarcas = true;
  String _erro = '';

  bool get _modoEdicao => widget.produto != null;

  @override
  void initState() {
    super.initState();
    _carregarMarcas();

    if (_modoEdicao) {
      final p = widget.produto!;
      _nomeController.text = p.nome;
      _categoriaSelecionada = p.categoria;
      _precoController.text = p.preco.toStringAsFixed(2);
      _marcaSelecionada = p.marcaId;
    }
  }

  Future<void> _carregarMarcas() async {
    try {
      final marcas = await _marcaService.listarTodas();
      setState(() {
        _marcas = marcas;
        _carregandoMarcas = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar marcas: $e';
        _carregandoMarcas = false;
      });
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_marcaSelecionada == null) {
      setState(() => _erro = 'Selecione uma marca.');
      return;
    }

    setState(() {
      _carregando = true;
      _erro = '';
    });

    try {
      final produto = Produto(
        id: widget.produto?.id ?? 0,
        nome: _nomeController.text.trim(),
        categoria: _categoriaSelecionada!,
        preco: double.parse(_precoController.text.trim().replaceAll(',', '.')),
        marcaId: _marcaSelecionada!,
      );

      Produto resultado;

      if (_modoEdicao) {
        resultado = await _produtoService.atualizar(produto.id, produto);
      } else {
        resultado = await _produtoService.criar(produto);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _modoEdicao
                  ? 'Produto atualizado com sucesso!'
                  : 'Produto criado com sucesso!',
            ),
          ),
        );
        Navigator.pop(context, resultado);
      }
    } catch (e) {
      setState(() {
        _erro = 'Erro ao salvar: $e';
        _carregando = false;
      });
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modoEdicao ? 'Editar Produto' : 'Novo Produto'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _carregandoMarcas
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Campo obrigatório'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _categoriaSelecionada,
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        border: OutlineInputBorder(),
                      ),
                      items: _categorias
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _categoriaSelecionada = v),
                      validator: (v) =>
                          v == null ? 'Selecione uma categoria' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _precoController,
                      decoration: const InputDecoration(
                        labelText: 'Preço',
                        border: OutlineInputBorder(),
                        prefixText: 'R\$ ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Campo obrigatório';
                        final parsed = double.tryParse(
                          v.trim().replaceAll(',', '.'),
                        );
                        if (parsed == null) return 'Valor inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _marcaSelecionada,
                      decoration: const InputDecoration(
                        labelText: 'Marca',
                        border: OutlineInputBorder(),
                      ),
                      items: _marcas
                          .map(
                            (m) => DropdownMenuItem(
                              value: m.id,
                              child: Text(m.nome),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _marcaSelecionada = v),
                      validator: (v) =>
                          v == null ? 'Selecione uma marca' : null,
                    ),
                    const SizedBox(height: 8),
                    if (_erro.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          _erro,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _carregando
                                ? null
                                : () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _carregando ? null : _salvar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                            ),
                            child: _carregando
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(_modoEdicao ? 'Salvar' : 'Criar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
