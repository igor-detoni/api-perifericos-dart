class Produto {
  final int id;
  final String nome;
  final String categoria;
  final double preco;
  final int marcaId;

  Produto({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.preco,
    required this.marcaId,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'] as int,
      nome: json['nome'] as String,
      categoria: json['categoria'] as String,
      preco: double.parse(json['preco'].toString()),
      marcaId: (json['marcaid'] ?? json['marcaId']) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'categoria': categoria,
      'preco': preco,
      'marcaId': marcaId,
    };
  }
}