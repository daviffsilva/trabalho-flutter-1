import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:entrega_app/data/models/usuario.dart';

class UsuarioService {
  static const String _usuarioKey = 'usuario';

  Future<void> salvarUsuario(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioJson = jsonEncode(usuario.toJson());
    await prefs.setString(_usuarioKey, usuarioJson);
  }

  Future<Usuario?> obterUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioJson = prefs.getString(_usuarioKey);
    
    if (usuarioJson == null) return null;
    
    final Map<String, dynamic> usuarioMap = jsonDecode(usuarioJson);
    return Usuario.fromJson(usuarioMap);
  }

  Future<void> removerUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usuarioKey);
  }

  Future<bool> usuarioEstaLogado() async {
    final usuario = await obterUsuario();
    return usuario != null;
  }
} 