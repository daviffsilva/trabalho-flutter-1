import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:entrega_app/data/models/entrega.dart';
import 'package:entrega_app/data/models/rastreamento.dart';
import 'package:entrega_app/data/services/rastreamento_service.dart';
import 'package:intl/intl.dart';

class EntregaRastreamentoPage extends StatefulWidget {
  final Entrega entrega;

  const EntregaRastreamentoPage({
    super.key,
    required this.entrega,
  });

  @override
  State<EntregaRastreamentoPage> createState() => _EntregaRastreamentoPageState();
}

class _EntregaRastreamentoPageState extends State<EntregaRastreamentoPage> {
  final _rastreamentoService = RastreamentoService();
  final Completer<GoogleMapController> _controller = Completer();
  Rastreamento? _ultimoRastreamento;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  BitmapDescriptor? _driverIcon;

  @override
  void initState() {
    super.initState();
    _loadDriverIcon();
    _carregarRastreamento();
  }

  Future<void> _loadDriverIcon() async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = Colors.blue;
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

  Future<void> _carregarRastreamento() async {
    setState(() => _isLoading = true);
    
    final rastreamento = await _rastreamentoService.getUltimoRastreamento(widget.entrega.id!);
    
    if (mounted) {
      setState(() {
        _ultimoRastreamento = rastreamento;
        _isLoading = false;
        if (rastreamento != null) {
          _updateMarkers(rastreamento);
        }
      });
    }

    _rastreamentoService.rastreamentoStream(widget.entrega.id!).listen((rastreamento) {
      if (mounted) {
        setState(() {
          _ultimoRastreamento = rastreamento;
          _updateMarkers(rastreamento);
        });
      }
    });
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
        position: LatLng(
          widget.entrega.latitude ?? 0.0,
          widget.entrega.longitude ?? 0.0,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(
          title: 'Destino',
          snippet: 'Local de entrega',
        ),
      ),
    };
  }

  double _calculateRotation(Rastreamento rastreamento) {
    return 45.0;
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
          child: Text(
            'Nenhuma informação de rastreamento disponível',
            style: theme.textTheme.bodyLarge,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rastreamento'),
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
                Text(
                  'Status: ${_ultimoRastreamento!.status}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Última atualização: ${DateFormat('dd/MM/yyyy HH:mm').format(_ultimoRastreamento!.dataAtualizacao)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (_ultimoRastreamento!.observacao != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _ultimoRastreamento!.observacao!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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