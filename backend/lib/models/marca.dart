class Marca {
  final int? id;
  final String nome;

  Marca({
    this.id, 
    required this.nome
    });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 
      'id': id,
      'nome': nome,
    };
  }

  factory Marca.fromJson(Map<String, dynamic> map) {
    return Marca(
      id: map['id'] as int,
      nome: map['nome'] as String,
    );
  }


}