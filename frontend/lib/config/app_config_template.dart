class AppConfig {
  static const String firebaseApiKeyAndroid = 'YOUR_ANDROID_API_KEY_HERE';
  static const String firebaseApiKeyIOS = 'YOUR_IOS_API_KEY_HERE';
  static const String firebaseAppIdAndroid = 'YOUR_ANDROID_APP_ID_HERE';
  static const String firebaseAppIdIOS = 'YOUR_IOS_APP_ID_HERE';
  static const String firebaseMessagingSenderId = 'YOUR_MESSAGING_SENDER_ID_HERE';
  static const String firebaseProjectId = 'YOUR_PROJECT_ID_HERE';
  static const String firebaseStorageBucket = 'YOUR_STORAGE_BUCKET_HERE';
  static const String firebaseIosBundleId = 'YOUR_IOS_BUNDLE_ID_HERE';
  
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY_HERE';
  
  static const String apiBaseUrl = 'http://localhost:8080';
  static String get authApiUrl => '$apiBaseUrl/api/auth';
  static String get pedidosApiUrl => '$apiBaseUrl/api/pedidos';
  
  static const String websocketBaseUrl = 'ws://localhost:8083';
  static String get websocketUrl => '$websocketBaseUrl/ws';
  
  static const String googleMapsBaseUrl = 'https://maps.googleapis.com/maps/api';
  
  static const bool enableDebugMode = true;
  static const String appVersion = '1.0.0';
}

/*
INSTRUÇÕES:
1. Copiar este arquivo para lib/config/app_config.dart
2. Substituir todos os valores de placeholder com suas configurações reais
3. Adicionar lib/config/app_config.dart ao seu .gitignore
4. Usar AppConfig.variableName para acessar valores de configuração em todo o app
*/ 