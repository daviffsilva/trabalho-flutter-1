import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:entrega_app/data/models/usuario.dart';
import 'package:entrega_app/data/models/auth_models.dart';
import 'auth_service.dart';

class UsuarioService {
  static const String _usuarioKey = 'usuario';
  final AuthService _authService = AuthService();

  Future<void> salvarUsuario(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioJson = jsonEncode(usuario.toJson());
    await prefs.setString(_usuarioKey, usuarioJson);
  }

  Future<Usuario?> obterUsuario() async {
    final userData = await _authService.getUserData();
    if (userData != null) {
      return Usuario.fromJson(userData);
    }
    final prefs = await SharedPreferences.getInstance();
    final usuarioJson = prefs.getString(_usuarioKey);
    if (usuarioJson == null) return null;
    final Map<String, dynamic> usuarioMap = jsonDecode(usuarioJson);
    return Usuario.fromJson(usuarioMap);
  }

  Future<void> removerUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usuarioKey);
    await _authService.logout();
  }

  Future<bool> usuarioEstaLogado() async {
    return await _authService.isAuthenticated();
  }

  Future<void> salvarUsuarioFromAuth(AuthResponse authResponse) async {
    if (authResponse.isSuccess && authResponse.userId != null) {
      final usuario = Usuario.fromAuthResponse(authResponse);
      await salvarUsuario(usuario);
    }
  }

  Future<Usuario?> getCurrentUser() async {
    if (await usuarioEstaLogado()) {
      return await obterUsuario();
    }
    return null;
  }

  Future<bool> isDriver() async {
    final usuario = await getCurrentUser();
    return usuario?.tipo == TipoUsuario.motorista;
  }

  Future<bool> isClient() async {
    final usuario = await getCurrentUser();
    return usuario?.tipo == TipoUsuario.cliente;
  }

  void dispose() {
    _authService.dispose();
  }
} 