import 'dart:async';
import 'package:entrega_app/data/models/localizacao.dart';
import 'package:entrega_app/data/models/rastreamento.dart';
import 'package:entrega_app/data/services/websocket_service.dart';
import 'package:entrega_app/data/services/rastreamento_service.dart';

class LiveTrackingService {
  static final LiveTrackingService _instance = LiveTrackingService._internal();
  factory LiveTrackingService() => _instance;
  LiveTrackingService._internal();

  final WebSocketService _webSocketService = WebSocketService();
  final RastreamentoService _rastreamentoService = RastreamentoService();
  
  final Map<int, StreamController<Rastreamento>> _pedidoTrackingControllers = {};
  final Map<int, StreamController<Rastreamento>> _driverTrackingControllers = {};
  final Set<int> _pendingPedidoSubscriptions = {};
  final Set<int> _pendingDriverSubscriptions = {};
  final Map<int, Timer> _mockDataTimers = {};
  StreamSubscription<bool>? _connectionStateSubscription;

  Future<void> initialize() async {
    try {
      await _webSocketService.connect();
      
      _webSocketService.locationStream.listen((localizacao) {
        _handleLocationUpdate(localizacao);
      });
      
      _connectionStateSubscription = _webSocketService.connectionStateStream.listen((isConnected) {
        if (isConnected) {
          _processPendingSubscriptions();
        }
      });
      
      print('Live tracking service initialized');
    } catch (e) {
      print('Failed to initialize live tracking service: $e');
      print('Running in fallback mode with mock data');
    }
  }

  void _processPendingSubscriptions() {
    for (final pedidoId in _pendingPedidoSubscriptions) {
      _webSocketService.subscribeToPedidoLocation(pedidoId);
    }
    _pendingPedidoSubscriptions.clear();
    
    for (final driverId in _pendingDriverSubscriptions) {
      _webSocketService.subscribeToDriverLocation(driverId);
    }
    _pendingDriverSubscriptions.clear();
  }

  Stream<Rastreamento> startPedidoTracking(int pedidoId) {
    if (!_pedidoTrackingControllers.containsKey(pedidoId)) {
      _pedidoTrackingControllers[pedidoId] = StreamController<Rastreamento>.broadcast();
      
      if (_webSocketService.isConnected) {
        _webSocketService.subscribeToPedidoLocation(pedidoId);
      } else {
        print('WebSocket not connected, adding to pending subscriptions');
        _pendingPedidoSubscriptions.add(pedidoId);
        _startMockDataGeneration(pedidoId, null);
      }
      
      _loadInitialPedidoData(pedidoId);
    }
    
    return _pedidoTrackingControllers[pedidoId]!.stream;
  }

  Stream<Rastreamento> startDriverTracking(int driverId) {
    if (!_driverTrackingControllers.containsKey(driverId)) {
      _driverTrackingControllers[driverId] = StreamController<Rastreamento>.broadcast();
      
      if (_webSocketService.isConnected) {
        _webSocketService.subscribeToDriverLocation(driverId);
      } else {
        print('WebSocket not connected, adding to pending subscriptions');
        _pendingDriverSubscriptions.add(driverId);
        _startMockDataGeneration(null, driverId);
      }
      
      _loadInitialDriverData(driverId);
    }
    
    return _driverTrackingControllers[driverId]!.stream;
  }

  void stopPedidoTracking(int pedidoId) {
    final controller = _pedidoTrackingControllers.remove(pedidoId);
    if (controller != null) {
      controller.close();
      _webSocketService.unsubscribe('sub-pedido-$pedidoId');
    }
    
    final timer = _mockDataTimers.remove(pedidoId);
    timer?.cancel();
  }

  void stopDriverTracking(int driverId) {
    final controller = _driverTrackingControllers.remove(driverId);
    if (controller != null) {
      controller.close();
      _webSocketService.unsubscribe('sub-driver-$driverId');
    }
    
    final timer = _mockDataTimers.remove(driverId);
    timer?.cancel();
  }

  void _handleLocationUpdate(Localizacao localizacao) {
    final rastreamento = _convertLocalizacaoToRastreamento(localizacao);
    
    if (localizacao.pedidoId != null) {
      final pedidoController = _pedidoTrackingControllers[localizacao.pedidoId];
      if (pedidoController != null && !pedidoController.isClosed) {
        pedidoController.add(rastreamento);
      }
    }
    
    if (localizacao.driverId != null) {
      final driverController = _driverTrackingControllers[localizacao.driverId];
      if (driverController != null && !driverController.isClosed) {
        driverController.add(rastreamento);
      }
    }
  }

  Future<void> _loadInitialPedidoData(int pedidoId) async {
    try {
      final ultimoRastreamento = await _rastreamentoService.getUltimoRastreamento(pedidoId);
      if (ultimoRastreamento != null) {
        final controller = _pedidoTrackingControllers[pedidoId];
        if (controller != null && !controller.isClosed) {
          controller.add(ultimoRastreamento);
        }
      }
    } catch (e) {
      print('Error loading initial pedido data: $e');
    }
  }

  Future<void> _loadInitialDriverData(int driverId) async {
    try {
      final mockRastreamento = Rastreamento(
        id: 0,
        entregaId: 0,
        latitude: -23.550520,
        longitude: -46.633308,
        dataAtualizacao: DateTime.now(),
        status: 'Em trânsito',
        observacao: 'Localização inicial do motorista',
      );
      
      final controller = _driverTrackingControllers[driverId];
      if (controller != null && !controller.isClosed) {
        controller.add(mockRastreamento);
      }
    } catch (e) {
      print('Error loading initial driver data: $e');
    }
  }

  Rastreamento _convertLocalizacaoToRastreamento(Localizacao localizacao) {
    return Rastreamento(
      id: localizacao.id ?? 0,
      entregaId: localizacao.pedidoId ?? 0,
      latitude: localizacao.latitude ?? 0.0,
      longitude: localizacao.longitude ?? 0.0,
      dataAtualizacao: localizacao.timestamp ?? DateTime.now(),
      status: _determineStatus(localizacao),
      observacao: _generateObservacao(localizacao),
    );
  }

  String _determineStatus(Localizacao localizacao) {
    if (localizacao.speed != null && localizacao.speed! > 0) {
      return 'Em trânsito';
    } else if (localizacao.isActive == true) {
      return 'Parado';
    } else {
      return 'Inativo';
    }
  }

  String _generateObservacao(Localizacao localizacao) {
    final parts = <String>[];
    
    if (localizacao.speed != null) {
      final speedKmh = (localizacao.speed! * 3.6).round();
      parts.add('Velocidade: ${speedKmh} km/h');
    }
    
    if (localizacao.accuracy != null) {
      parts.add('Precisão: ${localizacao.accuracy!.round()}m');
    }
    
    if (localizacao.heading != null) {
      parts.add('Direção: ${localizacao.heading!.round()}°');
    }
    
    return parts.isEmpty ? 'Atualização em tempo real' : parts.join(', ');
  }

  bool get isConnected => _webSocketService.isConnected;

  void dispose() {
    _pedidoTrackingControllers.values.forEach((controller) => controller.close());
    _pedidoTrackingControllers.clear();
    
    _driverTrackingControllers.values.forEach((controller) => controller.close());
    _driverTrackingControllers.clear();
    
    _connectionStateSubscription?.cancel();
    _pendingPedidoSubscriptions.clear();
    _pendingDriverSubscriptions.clear();
    
    _mockDataTimers.values.forEach((timer) => timer.cancel());
    _mockDataTimers.clear();
    
    _webSocketService.dispose();
  }

  void _startMockDataGeneration(int? pedidoId, int? driverId) {
    final timerId = pedidoId ?? driverId ?? 0;
    
    if (_mockDataTimers.containsKey(timerId)) {
      _mockDataTimers[timerId]?.cancel();
    }
    
    final timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_webSocketService.isConnected) {
        final mockRastreamento = Rastreamento(
          id: DateTime.now().millisecondsSinceEpoch,
          entregaId: pedidoId ?? 0,
          latitude: -23.550520 + (DateTime.now().millisecond / 1000000),
          longitude: -46.633308 + (DateTime.now().millisecond / 1000000),
          dataAtualizacao: DateTime.now(),
          status: 'Em trânsito',
          observacao: 'Dados de teste - Backend não disponível',
        );
        
        if (pedidoId != null) {
          final controller = _pedidoTrackingControllers[pedidoId];
          if (controller != null && !controller.isClosed) {
            controller.add(mockRastreamento);
          }
        }
        
        if (driverId != null) {
          final controller = _driverTrackingControllers[driverId];
          if (controller != null && !controller.isClosed) {
            controller.add(mockRastreamento);
          }
        }
      } else {
        timer.cancel();
        _mockDataTimers.remove(timerId);
      }
    });
    
    _mockDataTimers[timerId] = timer;
  }
} 