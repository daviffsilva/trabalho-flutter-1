import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';

class AuthService {
  static const String _baseUrl = 'http://localhost:8080';
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  final http.Client _client = http.Client();

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(LoginRequest(
          email: email,
          password: password,
        ).toJson()),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
        if (authResponse.token != null) {
          await _saveAuthData(authResponse);
        }
        return authResponse;
      } else {
        return AuthResponse.error();
      }
    } catch (e) {
      return AuthResponse.error();
    }
  }

  Future<AuthResponse> register(String email, String password, String name, UserType userType) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/api/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(RegisterRequest(
          email: email,
          password: password,
          name: name,
          userType: userType,
        ).toJson()),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
        if (authResponse.token != null) {
          await _saveAuthData(authResponse);
        }
        return authResponse;
      } else {
        return AuthResponse.error();
      }
    } catch (e) {
      return AuthResponse.error();
    }
  }

  Future<TokenValidationResponse> validateToken() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return TokenValidationResponse(valid: false, message: 'No token found');
      }

      final response = await _client.post(
        Uri.parse('$_baseUrl/api/auth/validate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return TokenValidationResponse.fromJson(jsonDecode(response.body));
      } else {
        return TokenValidationResponse(valid: false, message: 'Token validation failed');
      }
    } catch (e) {
      return TokenValidationResponse(valid: false, message: 'Network error: ${e.toString()}');
    }
  }

  Future<AuthResponse> refreshToken() async {
    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null) {
        return AuthResponse.error();
      }

      final response = await _client.post(
        Uri.parse('$_baseUrl/api/auth/refresh'),
        headers: {
          'Authorization': 'Bearer $refreshToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
        if (authResponse.token != null) {
          await _saveAuthData(authResponse);
        }
        return authResponse;
      } else {
        return AuthResponse.error();
      }
    } catch (e) {
      return AuthResponse.error();
    }
  }

  Future<bool> checkHealth() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/api/auth/health'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveAuthData(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (authResponse.token != null) {
      await prefs.setString(_tokenKey, authResponse.token!);
    }
    
    if (authResponse.refreshToken != null) {
      await prefs.setString(_refreshTokenKey, authResponse.refreshToken!);
    }

    final userData = {
      'userId': authResponse.userId,
      'email': authResponse.email,
      'name': authResponse.name,
      'userType': authResponse.userType?.name,
    };
    await prefs.setString(_userDataKey, jsonEncode(userData));
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }

  Future<bool> isAuthenticated() async {
    final token = await _getToken();
    if (token == null) return false;

    final validation = await validateToken();
    if (!validation.valid) {
      final refreshResult = await refreshToken();
      return refreshResult.token != null;
    }
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userDataKey);
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await _getToken();
    if (token != null) {
      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
    }
    return {
      'Content-Type': 'application/json',
    };
  }

  void dispose() {
    _client.close();
  }
} 