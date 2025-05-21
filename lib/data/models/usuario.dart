enum TipoUsuario {
  cliente,
  motorista,
}

class Usuario {
  final int id;
  final String nome;
  final String email;
  final TipoUsuario tipo;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.tipo,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'tipo': tipo.toString().split('.').last,
    };
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      tipo: TipoUsuario.values.firstWhere(
        (e) => e.toString().split('.').last == json['tipo'],
      ),
    );
  }
} 