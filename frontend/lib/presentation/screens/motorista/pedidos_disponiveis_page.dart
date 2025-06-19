import 'package:flutter/material.dart';
import 'package:entrega_app/data/models/pedido.dart';
import 'package:entrega_app/data/services/pedido_service.dart';
import 'package:entrega_app/data/services/auth_service.dart';
import 'package:entrega_app/presentation/screens/motorista/entrega_detalhes_page.dart';
import 'package:intl/intl.dart';

class PedidosDisponiveisPage extends StatefulWidget {
  const PedidosDisponiveisPage({super.key});

  @override
  State<PedidosDisponiveisPage> createState() => _PedidosDisponiveisPageState();
}

class _PedidosDisponiveisPageState extends State<PedidosDisponiveisPage> {
  final _pedidoService = PedidoService();
  final _authService = AuthService();
  List<Pedido> _pedidos = [];
  bool _isLoading = true;
  String? _errorMessage;
  Map<int, bool> _acceptingPedidos = {};

  @override
  void initState() {
    super.initState();
    _carregarPedidosDisponiveis();
  }

  @override
  void dispose() {
    _pedidoService.dispose();
    _authService.dispose();
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

  Future<void> _aceitarPedido(Pedido pedido) async {
    if (!pedido.canBeAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este pedido não pode ser aceito')),
      );
      return;
    }

    setState(() {
      _acceptingPedidos[pedido.id!] = true;
    });

    try {
      final userData = await _authService.getUserData();
      if (userData == null) {
        throw Exception('Usuário não autenticado');
      }

      final motoristaId = userData['userId'];
      if (motoristaId == null) {
        throw Exception('ID do motorista não encontrado');
      }

      final request = ClaimPedidoRequest(
        motoristaId: motoristaId,
      );

      await _pedidoService.claimPedido(pedido.id!, request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido aceito com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        _carregarPedidosDisponiveis();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao aceitar pedido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _acceptingPedidos[pedido.id!] = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pedidos Disponíveis'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
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
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pedidos Disponíveis'),
        ),
        body: const Center(
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
            final isAccepting = _acceptingPedidos[pedido.id!] ?? false;
            
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pedido #${pedido.id}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Cliente: ${pedido.clienteNome}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Chip(
                          label: const Text(
                            'DISPONÍVEL',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Origem:', pedido.originAddress),
                    _buildInfoRow('Destino:', pedido.destinationAddress),
                    _buildInfoRow('Carga:', pedido.cargoType),
                    if (pedido.cargoWeight != null)
                      _buildInfoRow('Peso:', '${pedido.cargoWeight} kg'),
                    if (pedido.estimatedDistance != null)
                      _buildInfoRow('Distância:', '${pedido.estimatedDistance!.toStringAsFixed(1)} km'),
                    if (pedido.totalPrice != null)
                      _buildInfoRow('Preço:', 'R\$ ${pedido.totalPrice!.toStringAsFixed(2)}'),
                    _buildInfoRow('Data:', DateFormat('dd/MM/yyyy HH:mm').format(pedido.createdAt)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isAccepting ? null : () => _aceitarPedido(pedido),
                            icon: isAccepting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.check),
                            label: Text(isAccepting ? 'Aceitando...' : 'Aceitar Pedido'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _verDetalhes(pedido),
                            icon: const Icon(Icons.info_outline),
                            label: const Text('Ver Detalhes'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
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