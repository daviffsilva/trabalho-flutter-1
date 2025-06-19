import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:entrega_app/data/models/pedido.dart';
import 'package:entrega_app/data/models/rastreamento.dart';
import 'package:entrega_app/data/services/live_tracking_service.dart';
import 'package:intl/intl.dart';

class EntregaRastreamentoPage extends StatefulWidget {
  final Pedido pedido;

  const EntregaRastreamentoPage({
    super.key,
    required this.pedido,
  });

  @override
  State<EntregaRastreamentoPage> createState() => _EntregaRastreamentoPageState();
}

class _EntregaRastreamentoPageState extends State<EntregaRastreamentoPage> {
  final _liveTrackingService = LiveTrackingService();
  final Completer<GoogleMapController> _controller = Completer();
  Rastreamento? _ultimoRastreamento;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _isConnected = false;
  bool _autoFollow = true;
  BitmapDescriptor? _driverIcon;
  StreamSubscription<Rastreamento>? _trackingSubscription;

  @override
  void initState() {
    super.initState();
    _loadDriverIcon();
    _initializeTracking();
  }

  @override
  void dispose() {
    _trackingSubscription?.cancel();
    if (widget.pedido.id != null) {
      _liveTrackingService.stopPedidoTracking(widget.pedido.id!);
    }
    super.dispose();
  }

  Future<void> _initializeTracking() async {
    setState(() => _isLoading = true);
    try {
      await _liveTrackingService.initialize();
      
      if (widget.pedido.id != null) {
        _trackingSubscription = _liveTrackingService
            .startPedidoTracking(widget.pedido.id!)
            .listen((rastreamento) {
          if (mounted) {
            setState(() {
              _ultimoRastreamento = rastreamento;
              _isConnected = _liveTrackingService.isConnected;
              _updateMarkers(rastreamento);
            });
          }
        });
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isConnected = _liveTrackingService.isConnected;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isConnected = false;
        });
      }
    }
  }

  Future<void> _loadDriverIcon() async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final size = const Size(48, 48);

    final builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        fontSize: size.width,
        textAlign: TextAlign.center,
      ),
    )
      ..pushStyle(ui.TextStyle(color: Colors.white))
      ..addText('🚗');

    final paragraph = builder.build();
    paragraph.layout(ui.ParagraphConstraints(width: size.width));

    canvas.drawParagraph(paragraph, Offset.zero);

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    if (bytes != null) {
      _driverIcon = BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
    }
  }

  void _updateMarkers(Rastreamento rastreamento) {
    _markers = {
      Marker(
        markerId: const MarkerId('entregador'),
        position: LatLng(rastreamento.latitude, rastreamento.longitude),
        icon: _driverIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        anchor: const Offset(0.5, 0.5),
        rotation: _calculateRotation(rastreamento),
        infoWindow: InfoWindow(
          title: 'Entregador',
          snippet: rastreamento.observacao,
        ),
      ),
      Marker(
        markerId: const MarkerId('destino'),
        position: widget.pedido.destinationLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Destino',
          snippet: widget.pedido.destinationAddress,
        ),
      ),
      Marker(
        markerId: const MarkerId('origem'),
        position: widget.pedido.originLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Origem',
          snippet: widget.pedido.originAddress,
        ),
      ),
    };

    if (_autoFollow && _controller.isCompleted) {
      _moveCameraToDriver(rastreamento);
    }
  }

  Future<void> _moveCameraToDriver(Rastreamento rastreamento) async {
    try {
      final controller = await _controller.future;
      await controller.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(rastreamento.latitude, rastreamento.longitude),
        ),
      );
    } catch (e) {
      // Camera movement failed, ignore
    }
  }

  Future<void> _moveCameraToShowAllMarkers() async {
    try {
      final controller = await _controller.future;
      final bounds = _calculateBounds();
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50),
      );
    } catch (e) {
      // Camera movement failed, ignore
    }
  }

  LatLngBounds _calculateBounds() {
    final positions = <LatLng>[
      LatLng(_ultimoRastreamento!.latitude, _ultimoRastreamento!.longitude),
      widget.pedido.originLocation,
      widget.pedido.destinationLocation,
    ];

    double minLat = positions[0].latitude;
    double maxLat = positions[0].latitude;
    double minLng = positions[0].longitude;
    double maxLng = positions[0].longitude;

    for (final position in positions) {
      minLat = min(minLat, position.latitude);
      maxLat = max(maxLat, position.latitude);
      minLng = min(minLng, position.longitude);
      maxLng = max(maxLng, position.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  double _calculateRotation(Rastreamento rastreamento) {
    final observacao = rastreamento.observacao;
    if (observacao != null && observacao.contains('Direção:')) {
      final directionMatch = RegExp(r'Direção: (\d+)°').firstMatch(observacao);
      if (directionMatch != null) {
        return double.tryParse(directionMatch.group(1) ?? '0') ?? 0.0;
      }
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Rastreamento'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_ultimoRastreamento == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Rastreamento'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Nenhuma informação de rastreamento disponível',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Status do pedido: ${widget.pedido.status.label}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              if (!_isConnected) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_off, size: 16, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Modo offline - dados de teste',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rastreamento'),
        actions: [
          if (!_isConnected)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off, size: 14, color: Colors.orange.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'Offline',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          IconButton(
            icon: Icon(
              _autoFollow ? Icons.my_location : Icons.my_location_outlined,
              color: _autoFollow ? theme.colorScheme.primary : null,
            ),
            onPressed: () {
              setState(() {
                _autoFollow = !_autoFollow;
              });
              if (_autoFollow && _ultimoRastreamento != null) {
                _moveCameraToDriver(_ultimoRastreamento!);
              }
            },
            tooltip: _autoFollow ? 'Desativar auto-seguir' : 'Ativar auto-seguir',
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out_map),
            onPressed: _moveCameraToShowAllMarkers,
            tooltip: 'Mostrar todos os marcadores',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _ultimoRastreamento!.latitude,
                  _ultimoRastreamento!.longitude,
                ),
                zoom: 15,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              compassEnabled: true,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Status: ${_ultimoRastreamento!.status}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (!_isConnected)
                      Icon(Icons.wifi_off, size: 16, color: Colors.orange.shade600),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Última atualização: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(_ultimoRastreamento!.dataAtualizacao)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                if (_ultimoRastreamento!.observacao != null && _ultimoRastreamento!.observacao!.isNotEmpty)
                  Text(
                    'Observação: ${_ultimoRastreamento!.observacao}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                if (!_isConnected) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Conectando ao servidor... Dados de teste sendo exibidos',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
} 