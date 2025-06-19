import 'package:flutter/material.dart';
import 'package:entrega_app/data/models/pedido.dart';
import 'package:entrega_app/data/services/pedido_service.dart';
import 'package:entrega_app/presentation/screens/motorista/entrega_detalhes_page.dart';
import 'package:intl/intl.dart';

class PedidosDisponiveisPage extends StatefulWidget {
  const PedidosDisponiveisPage({super.key});

  @override
  State<PedidosDisponiveisPage> createState() => _PedidosDisponiveisPageState();
}

class _PedidosDisponiveisPageState extends State<PedidosDisponiveisPage> {
  final _pedidoService = PedidoService();
  List<Pedido> _pedidos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarPedidosDisponiveis();
  }

  @override
  void dispose() {
    _pedidoService.dispose();
    super.dispose();
  }

  Future<void> _carregarPedidosDisponiveis() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pedidos = await _pedidoService.getAvailablePedidos();
      setState(() {
        _pedidos = pedidos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar pedidos disponíveis: $e';
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
                onPressed: _carregarPedidosDisponiveis,
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
                'Nenhum pedido disponível no momento',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Novos pedidos aparecerão aqui quando estiverem disponíveis',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos Disponíveis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarPedidosDisponiveis,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _carregarPedidosDisponiveis,
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
                      label: const Text(
                        'DISPONÍVEL',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      backgroundColor: Colors.green,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _verDetalhes(pedido),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, 32),
                      ),
                      child: const Text('Ver'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _verDetalhes(Pedido pedido) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EntregaDetalhesPage(pedido: pedido),
      ),
    ).then((result) {
      if (result == true) {
        _carregarPedidosDisponiveis();
      }
    });
  }
} 