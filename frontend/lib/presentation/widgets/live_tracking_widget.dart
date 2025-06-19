import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:entrega_app/data/models/rastreamento.dart';
import 'package:entrega_app/data/services/live_tracking_service.dart';

class LiveTrackingWidget extends StatefulWidget {
  final int pedidoId;
  final int? driverId;

  const LiveTrackingWidget({
    Key? key,
    required this.pedidoId,
    this.driverId,
  }) : super(key: key);

  @override
  State<LiveTrackingWidget> createState() => _LiveTrackingWidgetState();
}

class _LiveTrackingWidgetState extends State<LiveTrackingWidget> {
  final LiveTrackingService _trackingService = LiveTrackingService();
  StreamSubscription<Rastreamento>? _trackingSubscription;
  Rastreamento? _currentLocation;
  bool _isConnected = false;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Timer? _connectionTimer;

  @override
  void initState() {
    super.initState();
    _initializeTracking();
    _startConnectionMonitoring();
  }

  @override
  void dispose() {
    _trackingSubscription?.cancel();
    _connectionTimer?.cancel();
    if (widget.driverId != null) {
      _trackingService.stopDriverTracking(widget.driverId!);
    } else {
      _trackingService.stopPedidoTracking(widget.pedidoId);
    }
    super.dispose();
  }

  Future<void> _initializeTracking() async {
    try {
      await _trackingService.initialize();
      
      setState(() {
        _isConnected = _trackingService.isConnected;
      });

      Stream<Rastreamento> trackingStream;
      if (widget.driverId != null) {
        trackingStream = _trackingService.startDriverTracking(widget.driverId!);
      } else {
        trackingStream = _trackingService.startPedidoTracking(widget.pedidoId);
      }

      _trackingSubscription = trackingStream.listen(
        (rastreamento) {
          if (mounted) {
            setState(() {
              _currentLocation = rastreamento;
              _updateMarkers();
            });
            
            _animateToLocation(rastreamento);
          }
        },
        onError: (error) {
          print('Tracking error: $error');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro no rastreamento: $error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    } catch (e) {
      print('Failed to initialize tracking: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha ao conectar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateMarkers() {
    if (_currentLocation == null) return;

    _markers = {
      Marker(
        markerId: MarkerId('driver_${widget.driverId ?? widget.pedidoId}'),
        position: LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
        infoWindow: InfoWindow(
          title: widget.driverId != null ? 'Motorista ${widget.driverId}' : 'Pedido ${widget.pedidoId}',
          snippet: _currentLocation!.observacao,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    };
  }

  void _animateToLocation(Rastreamento rastreamento) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(rastreamento.latitude, rastreamento.longitude),
        ),
      );
    }
  }

  void _startConnectionMonitoring() {
    _connectionTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _isConnected = _trackingService.isConnected;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rastreamento em Tempo Real'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(
                  _isConnected ? Icons.wifi : Icons.wifi_off,
                  color: _isConnected ? Colors.green : Colors.red,
                ),
                SizedBox(width: 8),
                Text(
                  _isConnected ? 'Conectado' : 'Desconectado',
                  style: TextStyle(
                    color: _isConnected ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status do Rastreamento',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      _isConnected ? Icons.check_circle : Icons.error,
                      color: _isConnected ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 8),
                    Text(
                      _isConnected ? 'Conectado ao servidor' : 'Desconectado',
                      style: TextStyle(
                        color: _isConnected ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                if (_currentLocation != null) ...[
                  SizedBox(height: 8),
                  Text('Status: ${_currentLocation!.status}'),
                  Text('Última atualização: ${_formatDateTime(_currentLocation!.dataAtualizacao)}'),
                  if (_currentLocation!.observacao != null)
                    Text('Observação: ${_currentLocation!.observacao}'),
                ],
              ],
            ),
          ),
          
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(-23.550520, -46.633308),
                    zoom: 15,
                  ),
                  markers: _markers,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    if (_currentLocation != null) {
                      _animateToLocation(_currentLocation!);
                    }
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                ),
              ),
            ),
          ),
          
          SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
} 