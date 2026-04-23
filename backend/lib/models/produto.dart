class Produto {
  final int? id;
  final String nome;
  final String categoria;
  final double preco;
  final int marcaId;

  Produto({
    this.id,
    required this.nome,
    required this.categoria,
    required this.preco,
    required this.marcaId,
  });

  Map<String, dynamic> toJson(){
    return{
      if (id != null) 
      'id': id,
      'nome': nome,
      'categoria': categoria,
      'preco': preco,
      'marcaId': marcaId,
    };
  }

  factory Produto.fromJson(Map<String, dynamic> map){
    return Produto(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      categoria: map['categoria'] as String,
      preco: double.parse(map['preco'].toString()),
      marcaId: (map['marcaid'] ?? map['marcaId']) as int,
    );
  }
}
