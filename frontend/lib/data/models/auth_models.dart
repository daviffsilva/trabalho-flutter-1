enum UserType {
  CLIENT,
  DRIVER,
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String name;
  final UserType userType;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
    required this.userType,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'userType': userType.name,
    };
  }
}

class AuthResponse {
  final String? token;
  final String? refreshToken;
  final String? tokenType;
  final int? userId;
  final String? email;
  final String? name;
  final UserType? userType;
  final int? expiresIn;

  AuthResponse({
    this.token,
    this.refreshToken,
    this.tokenType,
    this.userId,
    this.email,
    this.name,
    this.userType,
    this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      refreshToken: json['refreshToken'],
      tokenType: json['tokenType'],
      userId: json['userId'],
      email: json['email'],
      name: json['name'],
      userType: json['userType'] != null 
          ? UserType.values.firstWhere(
              (e) => e.name == json['userType'],
              orElse: () => UserType.CLIENT,
            )
          : null,
      expiresIn: json['expiresIn'],
    );
  }

  bool get isSuccess => token != null;

  factory AuthResponse.error() {
    return AuthResponse();
  }
}

class ErrorResponse {
  final String error;
  final String status;

  ErrorResponse({
    required this.error,
    required this.status,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      error: json['error'] ?? 'Erro desconhecido',
      status: json['status'] ?? 'error',
    );
  }
}

class ValidationErrorResponse {
  final String status;
  final String message;
  final Map<String, String> fieldErrors;

  ValidationErrorResponse({
    required this.status,
    required this.message,
    required this.fieldErrors,
  });

  factory ValidationErrorResponse.fromJson(Map<String, dynamic> json) {
    final fieldErrorsMap = json['fieldErrors'] as Map<String, dynamic>? ?? {};
    final fieldErrors = Map<String, String>.from(fieldErrorsMap);
    
    return ValidationErrorResponse(
      status: json['status'] ?? 'error',
      message: json['message'] ?? 'Erro de validação',
      fieldErrors: fieldErrors,
    );
  }

  String getFieldError(String fieldName) {
    return fieldErrors[fieldName] ?? '';
  }

  bool hasFieldError(String fieldName) {
    return fieldErrors.containsKey(fieldName);
  }
}

class TokenValidationResponse {
  final bool valid;
  final String? message;
  final Map<String, dynamic>? userData;

  TokenValidationResponse({
    required this.valid,
    this.message,
    this.userData,
  });

  factory TokenValidationResponse.fromJson(Map<String, dynamic> json) {
    return TokenValidationResponse(
      valid: json['valid'] ?? false,
      message: json['message'],
      userData: json['userData'],
    );
  }
} 