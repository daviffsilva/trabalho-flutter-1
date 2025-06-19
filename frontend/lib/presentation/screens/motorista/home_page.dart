import 'dart:async';
import 'package:entrega_app/data/models/pedido.dart';
import 'package:entrega_app/data/services/pedido_service.dart';
import 'package:entrega_app/data/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MotoristaHomePage extends StatefulWidget {
  const MotoristaHomePage({super.key});

  @override
  State<MotoristaHomePage> createState() => _MotoristaHomePageState();
}

class _MotoristaHomePageState extends State<MotoristaHomePage> {
  final _pedidoService = PedidoService();
  final _authService = AuthService();
  final _mapController = Completer<GoogleMapController>();
  Position? _currentPosition;
  Set<Marker> _markers = {};
  List<Pedido> _pedidosAssigned = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _obterLocalizacaoAtual();
      await _carregarPedidosAssigned();
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar dados: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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

      if (_mapController.isCompleted) {
        final controller = await _mapController.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
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

  Future<void> _carregarPedidosAssigned() async {
    try {
      final userData = await _authService.getUserData();
      if (userData == null) {
        throw Exception('Usuário não autenticado');
      }

      final userId = userData['userId'];
      if (userId == null) {
        throw Exception('ID do usuário não encontrado');
      }

      final pedidos = await _pedidoService.getPedidosByMotorista(userId);
      setState(() {
        _pedidosAssigned = pedidos;
        _markers = pedidos.map((pedido) {
          return Marker(
            markerId: MarkerId(pedido.id?.toString() ?? ''),
            position: pedido.originLocation,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
              title: 'Pedido #${pedido.id}',
              snippet: pedido.originAddress,
            ),
          );
        }).toSet();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar pedidos: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _carregarDados,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentPosition == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pedidos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarDados,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                zoom: 15,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (controller) => _mapController.complete(controller),
            ),
          ),
          Expanded(
            flex: 1,
            child: _pedidosAssigned.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum pedido atribuído',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Você não possui pedidos atribuídos no momento',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _pedidosAssigned.length,
                    itemBuilder: (context, index) {
                      final pedido = _pedidosAssigned[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text('Pedido #${pedido.id}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('De: ${pedido.originAddress}'),
                              Text('Para: ${pedido.destinationAddress}'),
                              Text('Status: ${pedido.status.label}'),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/motorista/entrega-detalhes',
                                arguments: pedido,
                              );
                            },
                            child: const Text('Ver Detalhes'),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pedidoService.dispose();
    _authService.dispose();
    super.dispose();
  }
} 