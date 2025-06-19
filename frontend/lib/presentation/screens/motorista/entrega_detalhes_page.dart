import 'dart:async';
import 'dart:io';
import 'package:entrega_app/data/models/pedido.dart';
import 'package:entrega_app/data/services/pedido_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class EntregaDetalhesPage extends StatefulWidget {
  final Pedido pedido;

  const EntregaDetalhesPage({
    super.key,
    required this.pedido,
  });

  @override
  State<EntregaDetalhesPage> createState() => _EntregaDetalhesPageState();
}

class _EntregaDetalhesPageState extends State<EntregaDetalhesPage> {
  final _pedidoService = PedidoService();
  late GoogleMapController _mapController;
  final Completer<GoogleMapController> _controller = Completer();
  CameraController? _cameraController;
  bool _isReadOnly = false;
  Position? _currentPosition;
  String? _fotoEntrega;
  String? _fotoAssinatura;
  bool _isFinalizing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isReadOnly = widget.pedido.status == StatusPedido.DELIVERED;
    if (!_isReadOnly) {
      _initializeCamera();
    }
    _obterLocalizacaoAtual();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _pedidoService.dispose();
    super.dispose();
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
              target: widget.pedido.destinationLocation,
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

  Future<void> _atualizarStatus(StatusPedido novoStatus) async {
    setState(() => _isLoading = true);

    try {
      final request = UpdatePedidoStatusRequest(
        status: novoStatus,
        deliveryPhotoUrl: _fotoEntrega,
        deliverySignature: _fotoAssinatura,
      );

      await _pedidoService.updatePedidoStatus(widget.pedido.id!, request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status atualizado para: ${novoStatus.label}')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar status: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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

    await _atualizarStatus(StatusPedido.DELIVERED);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Pedido'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 300,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: widget.pedido.destinationLocation,
                  zoom: 15,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                markers: {
                  Marker(
                    markerId: const MarkerId('origem'),
                    position: widget.pedido.originLocation,
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                    infoWindow: InfoWindow(
                      title: 'Origem',
                      snippet: widget.pedido.originAddress,
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
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                compassEnabled: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  if (!_isReadOnly) _buildActionButtons(),
                  if (_isReadOnly) _buildReadOnlyInfo(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.pedido.clienteNome,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    widget.pedido.status.label,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(widget.pedido.status),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Origem:', widget.pedido.originAddress),
            _buildInfoRow('Destino:', widget.pedido.destinationAddress),
            _buildInfoRow('Carga:', widget.pedido.cargoType),
            if (widget.pedido.cargoWeight != null)
              _buildInfoRow('Peso:', '${widget.pedido.cargoWeight} kg'),
            if (widget.pedido.cargoDimensions != null)
              _buildInfoRow('Dimensões:', widget.pedido.cargoDimensions!),
            if (widget.pedido.specialInstructions != null)
              _buildInfoRow('Instruções:', widget.pedido.specialInstructions!),
            if (widget.pedido.estimatedDistance != null)
              _buildInfoRow('Distância:', '${widget.pedido.estimatedDistance!.toStringAsFixed(1)} km'),
            if (widget.pedido.totalPrice != null)
              _buildInfoRow('Preço:', 'R\$ ${widget.pedido.totalPrice!.toStringAsFixed(2)}'),
            _buildInfoRow('Data:', DateFormat('dd/MM/yyyy HH:mm').format(widget.pedido.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (widget.pedido.canBeAccepted)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _atualizarStatus(StatusPedido.ACCEPTED),
              icon: const Icon(Icons.check),
              label: const Text('Aceitar Pedido'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        if (widget.pedido.canBeStarted) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _atualizarStatus(StatusPedido.IN_TRANSIT),
              icon: const Icon(Icons.directions_car),
              label: const Text('Iniciar Entrega'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
        if (widget.pedido.canBeDelivered) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _atualizarStatus(StatusPedido.OUT_FOR_DELIVERY),
              icon: const Icon(Icons.local_shipping),
              label: const Text('Sair para Entrega'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
        if (widget.pedido.status == StatusPedido.OUT_FOR_DELIVERY) ...[
          const SizedBox(height: 16),
          const Text(
            'Fotos da Entrega',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _tirarFoto('entrega'),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Foto da Entrega'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _tirarFoto('assinatura'),
                  icon: const Icon(Icons.edit),
                  label: const Text('Assinatura'),
                ),
              ),
            ],
          ),
          if (_fotoEntrega != null || _fotoAssinatura != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (_fotoEntrega != null)
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Foto da Entrega:'),
                        const SizedBox(height: 8),
                        Image.file(
                          File(_fotoEntrega!),
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                if (_fotoAssinatura != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Assinatura:'),
                        const SizedBox(height: 8),
                        Image.file(
                          File(_fotoAssinatura!),
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isFinalizing ? null : _finalizarEntrega,
                icon: _isFinalizing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(_isFinalizing ? 'Finalizando...' : 'Finalizar Entrega'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildReadOnlyInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.check_circle, size: 48, color: Colors.green),
            const SizedBox(height: 8),
            const Text(
              'Pedido Entregue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            if (widget.pedido.deliveredAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Entregue em: ${DateFormat('dd/MM/yyyy HH:mm').format(widget.pedido.deliveredAt!)}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(StatusPedido status) {
    switch (status) {
      case StatusPedido.DELIVERED:
        return Colors.green;
      case StatusPedido.IN_TRANSIT:
      case StatusPedido.OUT_FOR_DELIVERY:
        return Colors.orange;
      case StatusPedido.ACCEPTED:
        return Colors.blue;
      case StatusPedido.PENDING:
        return Colors.grey;
      case StatusPedido.CANCELLED:
      case StatusPedido.FAILED:
        return Colors.red;
    }
  }
} 