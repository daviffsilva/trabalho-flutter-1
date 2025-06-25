import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification.dart';
import '../models/usuario.dart';
import 'usuario_service.dart';
import 'http_service.dart';

class FirebaseNotificationService {
  static final FirebaseNotificationService _instance = FirebaseNotificationService._internal();
  factory FirebaseNotificationService() => _instance;
  FirebaseNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final UsuarioService _usuarioService = UsuarioService();
  final HttpService _httpService = HttpService();

  Function(AppNotification)? onNotificationReceived;
  Function(AppNotification)? onNotificationTapped;

  bool _isInitialized = false;
  String? _fcmToken;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _requestPermissions();
      await _initializeLocalNotifications();
      await _setupFirebaseHandlers();
      await _getFCMToken();

      _isInitialized = true;
      print('Firebase Notification Service inicializado com sucesso');
    } catch (e) {
      print('Erro ao inicializar Firebase Notification Service: $e');
    }
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permissões de notificação concedidas');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('Permissões provisórias de notificação concedidas');
    } else {
      print('Permissões de notificação negadas');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    if (Platform.isAndroid) {
      await _createNotificationChannel();
    }
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'entrega_app_channel',
      'Entrega App Notifications',
      description: 'Canal para notificações do app de entregas',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _setupFirebaseHandlers() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensagem recebida em primeiro plano: ${message.messageId}');
      _handleForegroundMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Mensagem aberta: ${message.messageId}');
      _handleNotificationTapped(message);
    });
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('App aberto por notificação: ${initialMessage.messageId}');
      _handleNotificationTapped(initialMessage);
    }
  }

  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        print('FCM Token: $_fcmToken');
        await _saveFCMToken(_fcmToken!);
        //await _sendTokenToServer(_fcmToken!);
      }

      _firebaseMessaging.onTokenRefresh.listen((String token) {
        print('FCM Token atualizado: $token');
        _fcmToken = token;
        _saveFCMToken(token);
        //_sendTokenToServer(token);
      });
    } catch (e) {
      print('Erro ao obter FCM token: $e');
    }
  }

  Future<void> _saveFCMToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
    } catch (e) {
      print('Erro ao salvar FCM token: $e');
    }
  }

  /*Future<void> _sendTokenToServer(String token) async {
    try {
      final usuario = await _usuarioService.getCurrentUser();
      if (usuario != null) {
        await _httpService.post('/api/users/${usuario.id}/fcm-token', {
          'token': token,
          'platform': Platform.isAndroid ? 'android' : 'ios',
        });
      }
    } catch (e) {
      print('Erro ao enviar token para o servidor: $e');
    }
  }*/

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = _createAppNotification(message);
    
    _showLocalNotification(notification);
    onNotificationReceived?.call(notification);
    _saveNotification(notification);
  }

  void _handleNotificationTapped(RemoteMessage message) {
    final notification = _createAppNotification(message);
    onNotificationTapped?.call(notification);
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      final notificationData = jsonDecode(response.payload!);
      final notification = AppNotification.fromJson(notificationData);
      onNotificationTapped?.call(notification);
    }
  }

  AppNotification _createAppNotification(RemoteMessage message) {
    final data = message.data;
    
    return AppNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? data['title'] ?? 'Nova notificação',
      body: message.notification?.body ?? data['body'] ?? '',
      type: _getNotificationType(data['type']),
      data: data,
      timestamp: DateTime.now(),
    );
  }

  NotificationType _getNotificationType(String? type) {
    if (type == null) return NotificationType.geral;
    
    try {
      return NotificationType.values.firstWhere((e) => e.name == type);
    } catch (e) {
      return NotificationType.geral;
    }
  }

  Future<void> _showLocalNotification(AppNotification notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'entrega_app_channel',
      'Entrega App Notifications',
      channelDescription: 'Canal para notificações do app de entregas',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      notification.id.hashCode,
      notification.title,
      notification.body,
      platformChannelSpecifics,
      payload: jsonEncode(notification.toJson()),
    );
  }

  Future<void> _saveNotification(AppNotification notification) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = await getStoredNotifications();
      notifications.insert(0, notification);
      
      if (notifications.length > 50) {
        notifications.removeRange(50, notifications.length);
      }
      
      final notificationsJson = notifications.map((n) => n.toJson()).toList();
      await prefs.setString('stored_notifications', jsonEncode(notificationsJson));
    } catch (e) {
      print('Erro ao salvar notificação: $e');
    }
  }

  Future<List<AppNotification>> getStoredNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString('stored_notifications');
      
      if (notificationsJson != null) {
        final notificationsList = jsonDecode(notificationsJson) as List;
        return notificationsList
            .map((json) => AppNotification.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Erro ao carregar notificações: $e');
    }
    
    return [];
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final notifications = await getStoredNotifications();
      final index = notifications.indexWhere((n) => n.id == notificationId);
      
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        
        final prefs = await SharedPreferences.getInstance();
        final notificationsJson = notifications.map((n) => n.toJson()).toList();
        await prefs.setString('stored_notifications', jsonEncode(notificationsJson));
      }
    } catch (e) {
      print('Erro ao marcar notificação como lida: $e');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Inscrito no tópico: $topic');
    } catch (e) {
      print('Erro ao se inscrever no tópico $topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Inscrição removida do tópico: $topic');
    } catch (e) {
      print('Erro ao remover inscrição do tópico $topic: $e');
    }
  }

  Future<void> setupUserTopics() async {
    final usuario = await _usuarioService.getCurrentUser();
    if (usuario != null) {
      await subscribeToTopic('all_users');
      await subscribeToTopic('user_${usuario.id}');
      
      if (usuario.tipo == TipoUsuario.cliente) {
        await subscribeToTopic('clientes');
        await unsubscribeFromTopic('motoristas');
      } else if (usuario.tipo == TipoUsuario.motorista) {
        await subscribeToTopic('motoristas');
        await unsubscribeFromTopic('clientes');
      }
    }
  }

  Future<void> removeAllTopicSubscriptions() async {
    final usuario = await _usuarioService.getCurrentUser();
    if (usuario != null) {
      await unsubscribeFromTopic('all_users');
      await unsubscribeFromTopic('user_${usuario.id}');
      await unsubscribeFromTopic('clientes');
      await unsubscribeFromTopic('motoristas');
    }
  }

  String? get fcmToken => _fcmToken;

  Future<void> clearAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('stored_notifications');
      await _localNotifications.cancelAll();
    } catch (e) {
      print('Erro ao limpar notificações: $e');
    }
  }

  void dispose() {
  }
}

 