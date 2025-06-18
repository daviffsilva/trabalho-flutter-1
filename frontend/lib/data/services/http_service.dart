import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class HttpService {
  static const String _baseUrl = 'http://localhost:8080';
  final AuthService _authService = AuthService();
  final http.Client _client = http.Client();

  Future<http.Response> get(String endpoint) async {
    final headers = await _authService.getAuthHeaders();
    final response = await _client.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
    );

    if (response.statusCode == 401) {
      final refreshResult = await _authService.refreshToken();
      if (refreshResult.isSuccess) {
        final newHeaders = await _authService.getAuthHeaders();
        return await _client.get(
          Uri.parse('$_baseUrl$endpoint'),
          headers: newHeaders,
        );
      }
    }

    return response;
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final headers = await _authService.getAuthHeaders();
    final response = await _client.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      final refreshResult = await _authService.refreshToken();
      if (refreshResult.isSuccess) {
        final newHeaders = await _authService.getAuthHeaders();
        return await _client.post(
          Uri.parse('$_baseUrl$endpoint'),
          headers: newHeaders,
          body: jsonEncode(body),
        );
      }
    }

    return response;
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final headers = await _authService.getAuthHeaders();
    final response = await _client.put(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      final refreshResult = await _authService.refreshToken();
      if (refreshResult.isSuccess) {
        final newHeaders = await _authService.getAuthHeaders();
        return await _client.put(
          Uri.parse('$_baseUrl$endpoint'),
          headers: newHeaders,
          body: jsonEncode(body),
        );
      }
    }

    return response;
  }

  Future<http.Response> delete(String endpoint) async {
    final headers = await _authService.getAuthHeaders();
    final response = await _client.delete(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
    );

    if (response.statusCode == 401) {
      final refreshResult = await _authService.refreshToken();
      if (refreshResult.isSuccess) {
        final newHeaders = await _authService.getAuthHeaders();
        return await _client.delete(
          Uri.parse('$_baseUrl$endpoint'),
          headers: newHeaders,
        );
      }
    }

    return response;
  }

  Future<http.Response> getUnauthenticated(String endpoint) async {
    return await _client.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> postUnauthenticated(String endpoint, Map<String, dynamic> body) async {
    return await _client.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  Map<String, dynamic> parseResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw HttpException(
        'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        response.statusCode,
      );
    }
  }

  bool isAuthError(http.Response response) {
    return response.statusCode == 401;
  }

  void dispose() {
    _client.close();
    _authService.dispose();
  }
}

class HttpException implements Exception {
  final String message;
  final int statusCode;

  HttpException(this.message, this.statusCode);

  @override
  String toString() => 'HttpException: $message';
} 