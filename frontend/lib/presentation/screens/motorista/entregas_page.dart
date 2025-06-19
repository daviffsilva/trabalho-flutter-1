import 'package:flutter/material.dart';
import 'package:entrega_app/data/models/pedido.dart';
import 'package:entrega_app/data/services/pedido_service.dart';
import 'package:entrega_app/data/services/usuario_service.dart';
import 'package:entrega_app/presentation/screens/motorista/entrega_detalhes_page.dart';
import 'package:intl/intl.dart';

class MotoristaEntregasPage extends StatefulWidget {
  const MotoristaEntregasPage({super.key});

  @override
  State<MotoristaEntregasPage> createState() => _MotoristaEntregasPageState();
}

class _MotoristaEntregasPageState extends State<MotoristaEntregasPage> {
  final _pedidoService = PedidoService();
  final _usuarioService = UsuarioService();
  List<Pedido> _pedidos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarPedidos();
  }

  @override
  void dispose() {
    _pedidoService.dispose();
    _usuarioService.dispose();
    super.dispose();
  }

  Future<void> _carregarPedidos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pedidos = await _pedidoService.getPedidosForCurrentUser();
        setState(() {
        _pedidos = pedidos;
          _isLoading = false;
        });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar pedidos: $e';
        _isLoading = false;
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
              Icon(Icons.error, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade700),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _carregarPedidos,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_pedidos.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Nenhum pedido encontrado',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pedidos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarPedidos,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _carregarPedidos,
      child: ListView.builder(
          itemCount: _pedidos.length,
        itemBuilder: (context, index) {
            final pedido = _pedidos[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
                title: Text(
                  pedido.destinationAddress,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Cliente: ${pedido.clienteNome}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Carga: ${pedido.cargoType}',
                  ),
                    if (pedido.cargoWeight != null)
                      Text('Peso: ${pedido.cargoWeight} kg'),
                    Text(
                      'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(pedido.createdAt)}',
                    ),
                    if (pedido.estimatedDistance != null)
                      Text('Distância: ${pedido.estimatedDistance!.toStringAsFixed(1)} km'),
                    if (pedido.totalPrice != null)
                      Text(
                        'Preço: R\$ ${pedido.totalPrice!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                    ),
                ],
              ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Chip(
                label: Text(
                        pedido.status.label,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                      backgroundColor: _getStatusColor(pedido.status),
                    ),
                    if (pedido.status == StatusPedido.OUT_FOR_DELIVERY)
                      const Icon(Icons.local_shipping, color: Colors.orange),
                  ],
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/motorista/entrega-detalhes',
                    arguments: pedido,
                );
              },
            ),
          );
        },
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