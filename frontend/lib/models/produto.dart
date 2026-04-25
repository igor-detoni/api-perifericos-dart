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
      id: json['id'],
      nome: json['nome'],
      categoria: json['categoria'],
      preco: double.parse(json['preco'].toString()),
      marcaId: json['marcaId'],
    );
  }
}