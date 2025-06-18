import 'auth_models.dart';

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
      id: json['id'] ?? json['userId'],
      nome: json['nome'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      tipo: _parseTipoUsuario(json['tipo'] ?? json['userType']),
    );
  }

  static TipoUsuario _parseTipoUsuario(String? tipo) {
    if (tipo == null) return TipoUsuario.cliente;
    
    switch (tipo.toUpperCase()) {
      case 'CLIENT':
      case 'CLIENTE':
        return TipoUsuario.cliente;
      case 'DRIVER':
      case 'MOTORISTA':
        return TipoUsuario.motorista;
      default:
        return TipoUsuario.cliente;
    }
  }

  factory Usuario.fromAuthResponse(AuthResponse authResponse) {
    return Usuario(
      id: authResponse.userId ?? 0,
      nome: authResponse.name ?? '',
      email: authResponse.email ?? '',
      tipo: authResponse.userType == UserType.DRIVER 
          ? TipoUsuario.motorista 
          : TipoUsuario.cliente,
    );
  }
} 