import 'dart:async';
import 'dart:io';
import 'package:entrega_app/data/models/entrega.dart';
import 'package:entrega_app/data/services/entrega_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:entrega_app/data/database/database_helper.dart';

class EntregaDetalhesPage extends StatefulWidget {
  final Entrega entrega;

  const EntregaDetalhesPage({
    super.key,
    required this.entrega,
  });

  @override
  State<EntregaDetalhesPage> createState() => _EntregaDetalhesPageState();
}

class _EntregaDetalhesPageState extends State<EntregaDetalhesPage> {
  final _entregaService = EntregaService();
  late GoogleMapController _mapController;
  final Completer<GoogleMapController> _controller = Completer();
  CameraController? _cameraController;
  bool _isReadOnly = false;
  Position? _currentPosition;
  String? _fotoEntrega;
  String? _fotoAssinatura;
  final _databaseHelper = DatabaseHelper();
  bool _isFinalizing = false;

  @override
  void initState() {
    super.initState();
    _isReadOnly = widget.entrega.status == StatusEntrega.entregue;
    if (!_isReadOnly) {
      _initializeCamera();
    }
    _obterLocalizacaoAtual();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhuma câmera disponível')),
        );
      }
      return;
    }

    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.medium,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao inicializar câmera: $e')),
        );
      }
    }
  }

  Future<void> _obterLocalizacaoAtual() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });

      if (_controller.isCompleted) {
        final controller = await _controller.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(widget.entrega.latitude ?? 0.0, widget.entrega.longitude ?? 0.0),
              zoom: 15,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao obter localização')),
      );
    }
  }

  Future<void> _tirarFoto(String tipo) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile foto = await _cameraController!.takePicture();
      final directory = await getApplicationDocumentsDirectory();
      final String path = '${directory.path}/${tipo}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(foto.path).copy(path);

      setState(() {
        if (tipo == 'entrega') {
          _fotoEntrega = path;
        } else {
          _fotoAssinatura = path;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Foto de $tipo salva com sucesso')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao tirar foto: $e')),
        );
      }
    }
  }

  Future<void> _finalizarEntrega() async {
    if (_fotoEntrega == null || _fotoAssinatura == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('É necessário tirar as fotos da entrega e da assinatura')),
      );
      return;
    }

    setState(() => _isFinalizing = true);

    try {
      await _databaseHelper.updateEntregaStatus(
        widget.entrega.id!,
        _fotoEntrega!,
        _fotoAssinatura!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entrega finalizada com sucesso')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao finalizar entrega: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isFinalizing = false);
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultLocation = const LatLng(-23.550520, -46.633308);
    final targetLocation = widget.entrega.hasLocation ? widget.entrega.location! : defaultLocation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Entrega'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 300,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: targetLocation,
                  zoom: 15,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  _mapController = controller;
                },
                markers: widget.entrega.hasLocation
                    ? {
                        Marker(
                          markerId: const MarkerId('entrega'),
                          position: targetLocation,
                        ),
                      }
                    : {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Endereço: ${widget.entrega.endereco}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Data de Criação: ${DateFormat('dd/MM/yyyy HH:mm').format(widget.entrega.dataCriacao)}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (widget.entrega.dataEntrega != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Data de Entrega: ${DateFormat('dd/MM/yyyy HH:mm').format(widget.entrega.dataEntrega!)}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (!_isReadOnly) ...[
                    if (_cameraController != null && _cameraController!.value.isInitialized)
                      SizedBox(
                        height: 200,
                        child: CameraPreview(_cameraController!),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _tirarFoto('entrega'),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Foto da Entrega'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _tirarFoto('assinatura'),
                          icon: const Icon(Icons.draw),
                          label: const Text('Assinatura'),
                        ),
                      ],
                    ),
                    if (_fotoEntrega != null) ...[
                      const SizedBox(height: 16),
                      Image.file(
                        File(_fotoEntrega!),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ],
                    if (_fotoAssinatura != null) ...[
                      const SizedBox(height: 16),
                      Image.file(
                        File(_fotoAssinatura!),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isFinalizing ? null : _finalizarEntrega,
                        child: _isFinalizing
                            ? const CircularProgressIndicator()
                            : const Text('Finalizar Entrega'),
                      ),
                    ),
                  ] else ...[
                    if (widget.entrega.fotoEntrega != null)
                      Image.file(
                        File(widget.entrega.fotoEntrega!),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    if (widget.entrega.fotoAssinatura != null) ...[
                      const SizedBox(height: 16),
                      Image.file(
                        File(widget.entrega.fotoAssinatura!),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 