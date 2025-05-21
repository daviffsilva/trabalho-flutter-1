import 'dart:async';
import 'package:entrega_app/data/models/entrega.dart';
import 'package:entrega_app/data/services/entrega_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MotoristaHomePage extends StatefulWidget {
  const MotoristaHomePage({super.key});

  @override
  State<MotoristaHomePage> createState() => _MotoristaHomePageState();
}

class _MotoristaHomePageState extends State<MotoristaHomePage> {
  final _entregaService = EntregaService();
  final _mapController = Completer<GoogleMapController>();
  Position? _currentPosition;
  Set<Marker> _markers = {};
  List<Entrega> _entregasPendentes = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    await _obterLocalizacaoAtual();
    await _carregarEntregasPendentes();
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

  Future<void> _carregarEntregasPendentes() async {
    final entregas = await _entregaService.obterEntregasPendentes();
    setState(() {
      _entregasPendentes = entregas;
      _markers = entregas.map((entrega) {
        return Marker(
          markerId: MarkerId(entrega.id?.toString() ?? ''),
          position: LatLng(entrega.latitude ?? 0.0, entrega.longitude ?? 0.0),
          infoWindow: InfoWindow(
            title: entrega.clienteId.toString(),
            snippet: entrega.endereco,
          ),
        );
      }).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
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
          child: ListView.builder(
            itemCount: _entregasPendentes.length,
            itemBuilder: (context, index) {
              final entrega = _entregasPendentes[index];
              return ListTile(
                title: Text(entrega.clienteId.toString()),
                subtitle: Text(entrega.endereco),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/motorista/entrega-detalhes',
                      arguments: entrega,
                    );
                  },
                  child: const Text('Aceitar'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 