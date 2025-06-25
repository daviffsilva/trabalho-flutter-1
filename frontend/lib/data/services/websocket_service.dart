import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:entrega_app/data/models/localizacao.dart';
import '../../config/app_config.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  final StreamController<Localizacao> _locationController = StreamController<Localizacao>.broadcast();
  final StreamController<bool> _connectionStateController = StreamController<bool>.broadcast();
  final Map<String, StreamSubscription> _subscriptions = {};
  bool _isConnecting = false;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  
  Stream<Localizacao> get locationStream => _locationController.stream;
  Stream<bool> get connectionStateStream => _connectionStateController.stream;
  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnecting || _isConnected) {
      print('WebSocket already connecting or connected');
      return;
    }

    try {
      _isConnecting = true;
      final uri = Uri.parse(AppConfig.websocketUrl);
      _channel = WebSocketChannel.connect(uri);
      
      _channel!.stream.listen(
        (data) => _handleMessage(data),
        onError: (error) => _handleError(error),
        onDone: () => _handleDisconnect(),
      );
      
      await _sendStompConnect();
      
      print('WebSocket connected successfully');
    } catch (e) {
      print('Failed to connect to WebSocket: $e');
      _isConnecting = false;
      _scheduleReconnect();
      rethrow;
    }
  }

  Future<void> _sendStompConnect() async {
    if (_channel == null) return;
    
    final connectFrame = 'CONNECT\naccept-version:1.2\nheart-beat:10000,10000\n\n\x00';
    _channel!.sink.add(connectFrame);
  }

  void subscribeToPedidoLocation(int pedidoId) {
    if (!_isConnected) {
      print('WebSocket not connected, cannot subscribe');
      return;
    }

    final subscriptionId = 'sub-pedido-$pedidoId';
    final topic = '/topic/pedido/$pedidoId/location';
    
    final subscribeFrame = 'SUBSCRIBE\nid:$subscriptionId\ndestination:$topic\n\n\x00';
    _channel!.sink.add(subscribeFrame);
    
    print('Subscribed to pedido location updates: $topic');
  }

  void subscribeToDriverLocation(int driverId) {
    if (!_isConnected) {
      print('WebSocket not connected, cannot subscribe');
      return;
    }

    final subscriptionId = 'sub-driver-$driverId';
    final topic = '/topic/driver/$driverId/location';
    
    final subscribeFrame = 'SUBSCRIBE\nid:$subscriptionId\ndestination:$topic\n\n\x00';
    _channel!.sink.add(subscribeFrame);
    
    print('Subscribed to driver location updates: $topic');
  }

  void subscribeToGeneralLocationUpdates() {
    if (!_isConnected) {
      print('WebSocket not connected, cannot subscribe');
      return;
    }

    final subscriptionId = 'sub-general';
    final topic = '/topic/location-updates';
    
    final subscribeFrame = 'SUBSCRIBE\nid:$subscriptionId\ndestination:$topic\n\n\x00';
    _channel!.sink.add(subscribeFrame);
    
    print('Subscribed to general location updates: $topic');
  }

  void unsubscribe(String subscriptionId) {
    if (!_isConnected) {
      print('WebSocket not connected, cannot unsubscribe');
      return;
    }

    final unsubscribeFrame = 'UNSUBSCRIBE\nid:$subscriptionId\n\n\x00';
    _channel!.sink.add(unsubscribeFrame);
    
    print('Unsubscribed from: $subscriptionId');
  }

  void _handleMessage(dynamic data) {
    try {
      if (data is String) {
        if (data.startsWith('CONNECTED')) {
          print('STOMP connection established');
          _isConnecting = false;
          _isConnected = true;
          _connectionStateController.add(true);
          return;
        }
        
        if (data.startsWith('MESSAGE')) {
          final lines = data.split('\n');
          String jsonPayload = '';
          bool foundBody = false;
          
          for (String line in lines) {
            if (line.isEmpty && !foundBody) {
              foundBody = true;
              continue;
            }
            if (foundBody && line != '\x00') {
              jsonPayload += line;
            }
          }
          
          if (jsonPayload.isNotEmpty) {
            final jsonData = jsonDecode(jsonPayload.substring(0, jsonPayload.length - 1));
            
            if (jsonData['driverId'] != null || jsonData['pedidoId'] != null) {
              final localizacao = Localizacao.fromJson(jsonData);
              _locationController.add(localizacao);
            }
          }
        }
      }
    } catch (e) {
      print('Error handling WebSocket message: $e');
    }
  }

  void _handleError(dynamic error) {
    print('WebSocket error: $error');
    _isConnecting = false;
    _isConnected = false;
    _scheduleReconnect();
  }

  void _handleDisconnect() {
    print('WebSocket disconnected');
    _isConnecting = false;
    _isConnected = false;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected && !_isConnecting) {
        print('Attempting to reconnect...');
        connect();
      }
    });
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _isConnecting = false;
    _isConnected = false;
    _connectionStateController.add(false);
    
    if (_channel != null) {
      try {
        final disconnectFrame = 'DISCONNECT\n\n\x00';
        _channel!.sink.add(disconnectFrame);
        
        _channel!.sink.close(status.goingAway);
      } catch (e) {
        print('Error during disconnect: $e');
      }
      _channel = null;
    }
    
    _subscriptions.values.forEach((subscription) => subscription.cancel());
    _subscriptions.clear();
    print('WebSocket disconnected');
  }

  void dispose() {
    disconnect();
    _locationController.close();
    _connectionStateController.close();
  }
} 