import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../data/models/pedido.dart';
import '../../../data/services/pedido_service.dart';
import '../../../data/services/auth_service.dart';
import '../../widgets/address_search_field.dart';

class CriarPedidoPage extends StatefulWidget {
  const CriarPedidoPage({super.key});

  @override
  State<CriarPedidoPage> createState() => _CriarPedidoPageState();
}

class _CriarPedidoPageState extends State<CriarPedidoPage> {
  final _formKey = GlobalKey<FormState>();
  final _pedidoService = PedidoService();
  final _authService = AuthService();
  
  bool _isLoading = false;
  String? _errorMessage;
  
  final _originAddressController = TextEditingController();
  final _destinationAddressController = TextEditingController();
  final _cargoTypeController = TextEditingController();
  final _cargoWeightController = TextEditingController();
  final _cargoDimensionsController = TextEditingController();
  final _specialInstructionsController = TextEditingController();
  
  LatLng? _originCoordinates;
  LatLng? _destinationCoordinates;

  @override
  void dispose() {
    _originAddressController.dispose();
    _destinationAddressController.dispose();
    _cargoTypeController.dispose();
    _cargoWeightController.dispose();
    _cargoDimensionsController.dispose();
    _specialInstructionsController.dispose();
    super.dispose();
  }

  void _onOriginAddressSelected(String address, LatLng coordinates) {
    setState(() {
      _originCoordinates = coordinates;
    });
  }

  void _onDestinationAddressSelected(String address, LatLng coordinates) {
    setState(() {
      _destinationCoordinates = coordinates;
    });
  }

  Future<void> _createPedido() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_originCoordinates == null || _destinationCoordinates == null) {
      setState(() {
        _errorMessage = 'Por favor, selecione endereços válidos da lista de sugestões';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userData = await _authService.getUserData();
      if (userData == null) {
        throw Exception('User not authenticated');
      }

      final request = CreatePedidoRequest(
        originAddress: _originAddressController.text,
        destinationAddress: _destinationAddressController.text,
        originLatitude: _originCoordinates!.latitude,
        originLongitude: _originCoordinates!.longitude,
        destinationLatitude: _destinationCoordinates!.latitude,
        destinationLongitude: _destinationCoordinates!.longitude,
        clienteId: userData['userId'],
        clienteNome: userData['name'],
        clienteEmail: userData['email'],
        cargoType: _cargoTypeController.text,
        cargoWeight: _cargoWeightController.text.isNotEmpty 
            ? double.tryParse(_cargoWeightController.text) 
            : null,
        cargoDimensions: _cargoDimensionsController.text.isNotEmpty 
            ? _cargoDimensionsController.text 
            : null,
        specialInstructions: _specialInstructionsController.text.isNotEmpty 
            ? _specialInstructionsController.text 
            : null,
      );
      
      final createdPedido = await _pedidoService.createPedido(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pedido criado com sucesso! ID: ${createdPedido.id}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao criar pedido: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Novo Pedido'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Endereços',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            AddressSearchField(
                              controller: _originAddressController,
                              label: 'Endereço de Origem *',
                              hint: 'Digite para buscar endereços...',
                              prefixIcon: Icons.location_on,
                              prefixIconColor: Colors.red,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira o endereço de origem';
                                }
                                if (_originCoordinates == null) {
                                  return 'Por favor, selecione um endereço da lista';
                                }
                                return null;
                              },
                              onAddressSelected: _onOriginAddressSelected,
                            ),
                            const SizedBox(height: 16),
                            AddressSearchField(
                              controller: _destinationAddressController,
                              label: 'Endereço de Destino *',
                              hint: 'Digite para buscar endereços...',
                              prefixIcon: Icons.location_on,
                              prefixIconColor: Colors.green,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira o endereço de destino';
                                }
                                if (_destinationCoordinates == null) {
                                  return 'Por favor, selecione um endereço da lista';
                                }
                                return null;
                              },
                              onAddressSelected: _onDestinationAddressSelected,
                            ),
                            const SizedBox(height: 16),
                            if (_originCoordinates != null && _destinationCoordinates != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  border: Border.all(color: Colors.green.shade200),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green.shade700),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Endereços válidos selecionados',
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informações da Carga',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _cargoTypeController,
                              decoration: const InputDecoration(
                                labelText: 'Tipo de Carga *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.inventory),
                                hintText: 'Ex: Eletrônicos, Roupas, Alimentos...',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira o tipo de carga';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _cargoWeightController,
                              decoration: const InputDecoration(
                                labelText: 'Peso (kg)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.scale),
                                hintText: 'Ex: 5.5',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _cargoDimensionsController,
                              decoration: const InputDecoration(
                                labelText: 'Dimensões',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.straighten),
                                hintText: 'Ex: 30x20x15 cm',
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _specialInstructionsController,
                              decoration: const InputDecoration(
                                labelText: 'Instruções Especiais',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.info),
                                hintText: 'Ex: Frágil, manuseio com cuidado...',
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    ElevatedButton(
                      onPressed: _isLoading ? null : _createPedido,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Criar Pedido',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 