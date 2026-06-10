import 'package:flutter/material.dart';
import '../models/marca.dart';
import '../models/produto.dart';
import '../services/marca_service.dart';
import '../services/produto_service.dart';
import 'detalhe_screen.dart';
import 'formulario_screen.dart';

class ListaScreen extends StatefulWidget {
  const ListaScreen({super.key});

  @override
  State<ListaScreen> createState() => _ListaScreenState();
}

class _ListaScreenState extends State<ListaScreen> {
  final _produtoService = ProdutoService();
  final _marcaService = MarcaService();

  List<Produto> _todosProdutos = [];
  List<Produto> _produtosFiltrados = [];
  Map<int, String> _marcas = {};
  bool _carregando = true;
  String _erro = '';

  final _buscaController = TextEditingController();
  String? _filtroCategoria;
  int? _filtroMarcaId;
  double _precoMin = 0;
  double _precoMax = 10000;
  double _precoMaxGlobal = 10000;

  @override
  void initState() {
    super.initState();
    _carregarDados();
    _buscaController.addListener(_aplicarFiltros);
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _carregando = true;
      _erro = '';
    });

    try {
      final resultados = await Future.wait([
        _produtoService.listarTodos(),
        _marcaService.listarTodas(),
      ]);

      final produtos = resultados[0] as List<Produto>;
      final marcas = resultados[1] as List<Marca>;

      final maxPreco = produtos.isEmpty
          ? 10000.0
          : produtos.map((p) => p.preco).reduce((a, b) => a > b ? a : b);

      setState(() {
        _todosProdutos = produtos;
        _marcas = {for (var m in marcas) m.id: m.nome};
        _precoMaxGlobal = maxPreco;
        _precoMax = maxPreco;
        _carregando = false;
      });

      _aplicarFiltros();
    } catch (e) {
      setState(() {
        _erro = 'Falha ao carregar dados: $e';
        _carregando = false;
      });
    }
  }

  void _aplicarFiltros() {
    final termo = _buscaController.text.toLowerCase();
    setState(() {
      _produtosFiltrados = _todosProdutos.where((p) {
        final nomeOk =
            termo.isEmpty || p.nome.toLowerCase().contains(termo);
        final categoriaOk =
            _filtroCategoria == null || p.categoria == _filtroCategoria;
        final marcaOk =
            _filtroMarcaId == null || p.marcaId == _filtroMarcaId;
        final precoOk = p.preco >= _precoMin && p.preco <= _precoMax;
        return nomeOk && categoriaOk && marcaOk && precoOk;
      }).toList();
    });
  }

  void _limparFiltros() {
    setState(() {
      _buscaController.clear();
      _filtroCategoria = null;
      _filtroMarcaId = null;
      _precoMin = 0;
      _precoMax = _precoMaxGlobal;
    });
    _aplicarFiltros();
  }

  bool get _temFiltrosAtivos =>
      _buscaController.text.isNotEmpty ||
      _filtroCategoria != null ||
      _filtroMarcaId != null ||
      _precoMin > 0 ||
      _precoMax < _precoMaxGlobal;

  void _abrirFiltros() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filtros',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      _limparFiltros();
                      Navigator.pop(context);
                    },
                    child: const Text('Limpar tudo'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Categoria',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _filtroCategoria,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Todas',
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todas')),
                  ...['Mouse', 'Teclado', 'Headset', 'Microfone', 'Mousepad']
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c))),
                ],
                onChanged: (v) {
                  setModalState(() => _filtroCategoria = v);
                  _aplicarFiltros();
                },
              ),
              const SizedBox(height: 16),
              const Text('Marca',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _filtroMarcaId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Todas',
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todas')),
                  ..._marcas.entries.map((e) =>
                      DropdownMenuItem(value: e.key, child: Text(e.value))),
                ],
                onChanged: (v) {
                  setModalState(() => _filtroMarcaId = v);
                  _aplicarFiltros();
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Faixa de preço',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    'R\$ ${_precoMin.toStringAsFixed(0)} – R\$ ${_precoMax.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.deepPurple),
                  ),
                ],
              ),
              RangeSlider(
                values: RangeValues(_precoMin, _precoMax),
                min: 0,
                max: _precoMaxGlobal,
                divisions: 20,
                activeColor: Colors.deepPurple,
                labels: RangeLabels(
                  'R\$ ${_precoMin.toStringAsFixed(0)}',
                  'R\$ ${_precoMax.toStringAsFixed(0)}',
                ),
                onChanged: (v) {
                  setModalState(() {
                    _precoMin = v.start;
                    _precoMax = v.end;
                  });
                  _aplicarFiltros();
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconeCategoria(String categoria) {
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
        title: const Text('Produtos'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_temFiltrosAtivos
                ? Icons.filter_alt
                : Icons.filter_alt_outlined),
            tooltip: 'Filtros',
            onPressed: _abrirFiltros,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormularioScreen()),
          );
          _carregarDados();
        },
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_erro,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarDados,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            controller: _buscaController,
            decoration: InputDecoration(
              hintText: 'Buscar por nome...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: _buscaController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _buscaController.clear,
                    )
                  : null,
            ),
          ),
        ),
        if (_temFiltrosAtivos)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 14, color: Colors.deepPurple),
                const SizedBox(width: 4),
                Text(
                  '${_produtosFiltrados.length} de ${_todosProdutos.length} produto(s)',
                  style: const TextStyle(
                      fontSize: 12, color: Colors.deepPurple),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _limparFiltros,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Limpar filtros',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        Expanded(
          child: _produtosFiltrados.isEmpty
              ? const Center(child: Text('Nenhum produto encontrado.'))
              : RefreshIndicator(
                  onRefresh: _carregarDados,
                  child: ListView.builder(
                    itemCount: _produtosFiltrados.length,
                    itemBuilder: (context, index) {
                      final produto = _produtosFiltrados[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepPurpleAccent,
                            child: Icon(
                                _iconeCategoria(produto.categoria),
                                color: Colors.white),
                          ),
                          title: Text(produto.nome,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              '${_marcas[produto.marcaId] ?? 'Desconhecida'} • ${produto.categoria}'),
                          trailing: Text(
                            'R\$ ${produto.preco.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 16),
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetalheScreen(
                                  produto: produto,
                                  nomeMarca:
                                      _marcas[produto.marcaId] ??
                                          'Desconhecida',
                                ),
                              ),
                            );
                            _carregarDados();
                          },
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}