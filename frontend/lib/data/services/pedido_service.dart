import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pedido.dart';
import 'auth_service.dart';
import '../../config/api_config.dart';

class PedidoService {
  static const String _baseUrl = ApiConfig.pedidosBaseUrl;
  final AuthService _authService = AuthService();
  final http.Client _client = http.Client();

  Future<List<Pedido>> getAvailablePedidos() async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await _client.get(
        Uri.parse('$_baseUrl/api/pedidos/available'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Pedido.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load available pedidos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading available pedidos: $e');
    }
  }

  Future<List<Pedido>> getPedidosByStatus(StatusPedido status) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await _client.get(
        Uri.parse('$_baseUrl/api/pedidos/status/${status.name}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Pedido.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load pedidos by status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading pedidos by status: $e');
    }
  }

  Future<List<Pedido>> getPedidosByMotorista(int motoristaId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await _client.get(
        Uri.parse('$_baseUrl/api/pedidos/motorista/$motoristaId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Pedido.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load pedidos by motorista: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading pedidos by motorista: $e');
    }
  }

  Future<List<Pedido>> getPedidosByCliente(String email) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await _client.get(
        Uri.parse('$_baseUrl/api/pedidos/cliente/$email'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Pedido.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load pedidos by cliente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading pedidos by cliente: $e');
    }
  }

  Future<List<Pedido>> getPedidosByClienteId(int clienteId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await _client.get(
        Uri.parse('$_baseUrl/api/pedidos/cliente/id/$clienteId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Pedido.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load pedidos by cliente ID: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading pedidos by cliente ID: $e');
    }
  }

  Future<Pedido?> getPedidoById(int id) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await _client.get(
        Uri.parse('$_baseUrl/api/pedidos/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Pedido.fromJson(json);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load pedido: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading pedido: $e');
    }
  }

  Future<Pedido> createPedido(CreatePedidoRequest request) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final requestBody = jsonEncode(request.toJson());
      
      final response = await _client.post(
        Uri.parse('$_baseUrl/api/pedidos'),
        headers: headers,
        body: requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return Pedido.fromJson(json);
      } else {
        String errorMessage = 'Failed to create pedido (Status: ${response.statusCode})';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error'] ?? errorData['message'] ?? errorMessage;
        } catch (e) {
          errorMessage += ' - Response: ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Error parsing response from server: $e');
      }
      throw Exception('Error creating pedido: $e');
    }
  }

  Future<Pedido> updatePedidoStatus(int id, UpdatePedidoStatusRequest request) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await _client.put(
        Uri.parse('$_baseUrl/api/pedidos/$id/status'),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Pedido.fromJson(json);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to update pedido status');
      }
    } catch (e) {
      throw Exception('Error updating pedido status: $e');
    }
  }

  Future<Pedido> claimPedido(int id, ClaimPedidoRequest request) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await _client.put(
        Uri.parse('$_baseUrl/api/pedidos/$id/claim'),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Pedido.fromJson(json);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to claim pedido');
      }
    } catch (e) {
      throw Exception('Error claiming pedido: $e');
    }
  }

  Future<void> deletePedido(int id) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await _client.delete(
        Uri.parse('$_baseUrl/api/pedidos/$id'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to delete pedido');
      }
    } catch (e) {
      throw Exception('Error deleting pedido: $e');
    }
  }

  Future<List<Pedido>> getPedidosForCurrentUser() async {
    try {
      final userData = await _authService.getUserData();
      if (userData == null) {
        throw Exception('User not authenticated');
      }

      final userType = userData['userType'];
      final userId = userData['userId'];

      if (userType == 'DRIVER') {
        return await getPedidosByMotorista(userId);
      } else {
        return await getPedidosByClienteId(userId);
      }
    } catch (e) {
      throw Exception('Error loading pedidos for current user: $e');
    }
  }

  Future<List<Pedido>> getPedidosByStatusForCurrentUser(StatusPedido status) async {
    try {
      final allPedidos = await getPedidosForCurrentUser();
      return allPedidos.where((pedido) => pedido.status == status).toList();
    } catch (e) {
      throw Exception('Error loading pedidos by status for current user: $e');
    }
  }

  void dispose() {
    _client.close();
    _authService.dispose();
  }
} 