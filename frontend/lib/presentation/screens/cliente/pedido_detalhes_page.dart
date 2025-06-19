import 'package:flutter/material.dart';
import 'package:entrega_app/data/models/pedido.dart';
import 'package:entrega_app/data/services/pedido_service.dart';
import 'package:entrega_app/presentation/screens/cliente/entrega_rastreamento_page.dart';
import 'package:intl/intl.dart';

class PedidoDetalhesPage extends StatefulWidget {
  final Pedido pedido;

  const PedidoDetalhesPage({
    super.key,
    required this.pedido,
  });

  @override
  State<PedidoDetalhesPage> createState() => _PedidoDetalhesPageState();
}

class _PedidoDetalhesPageState extends State<PedidoDetalhesPage> {
  final _pedidoService = PedidoService();
  Pedido? _pedido;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pedido = widget.pedido;
    _refreshPedido();
  }

  @override
  void dispose() {
    _pedidoService.dispose();
    super.dispose();
  }

  Future<void> _refreshPedido() async {
    if (_pedido?.id == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final updatedPedido = await _pedidoService.getPedidoById(_pedido!.id!);
      if (mounted) {
        setState(() {
          _pedido = updatedPedido;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao atualizar pedido: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedido = _pedido ?? widget.pedido;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido #${pedido.id ?? 'N/A'}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshPedido,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusCard(pedido),
                      const SizedBox(height: 16),
                      _buildAddressesCard(pedido),
                      const SizedBox(height: 16),
                      _buildCargoCard(pedido),
                      const SizedBox(height: 16),
                      _buildDetailsCard(pedido),
                      const SizedBox(height: 16),
                      _buildTrackingButton(pedido),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
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
            onPressed: _refreshPedido,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(Pedido pedido) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(pedido.status),
                  color: _getStatusColor(pedido.status),
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(pedido.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getStatusColor(pedido.status),
                  width: 1,
                ),
              ),
              child: Text(
                pedido.status.label,
                style: TextStyle(
                  color: _getStatusColor(pedido.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressesCard(Pedido pedido) {
    return Card(
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
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Origem',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(pedido.originAddress),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Destino',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(pedido.destinationAddress),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCargoCard(Pedido pedido) {
    return Card(
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
            _buildInfoRow('Tipo', pedido.cargoType),
            if (pedido.cargoWeight != null)
              _buildInfoRow('Peso', '${pedido.cargoWeight} kg'),
            if (pedido.cargoDimensions != null)
              _buildInfoRow('Dimensões', pedido.cargoDimensions!),
            if (pedido.specialInstructions != null)
              _buildInfoRow('Instruções Especiais', pedido.specialInstructions!),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(Pedido pedido) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalhes do Pedido',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('ID do Pedido', '#${pedido.id ?? 'N/A'}'),
            _buildInfoRow('Data de Criação', 
                DateFormat('dd/MM/yyyy HH:mm').format(pedido.createdAt)),
            if (pedido.updatedAt != null)
              _buildInfoRow('Última Atualização', 
                  DateFormat('dd/MM/yyyy HH:mm').format(pedido.updatedAt!)),
            if (pedido.deliveredAt != null)
              _buildInfoRow('Data de Entrega', 
                  DateFormat('dd/MM/yyyy HH:mm').format(pedido.deliveredAt!)),
            if (pedido.estimatedDistance != null)
              _buildInfoRow('Distância Estimada', 
                  '${pedido.estimatedDistance!.toStringAsFixed(1)} km'),
            if (pedido.estimatedDuration != null)
              _buildInfoRow('Duração Estimada', 
                  '${pedido.estimatedDuration} minutos'),
            if (pedido.totalPrice != null)
              _buildInfoRow('Preço Total', 
                  'R\$ ${pedido.totalPrice!.toStringAsFixed(2)}',
                  valueColor: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingButton(Pedido pedido) {
    if (pedido.status != StatusPedido.IN_TRANSIT && 
        pedido.status != StatusPedido.OUT_FOR_DELIVERY) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EntregaRastreamentoPage(pedido: pedido),
            ),
          );
        },
        icon: const Icon(Icons.location_on),
        label: const Text('Rastrear Entrega'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(StatusPedido status) {
    switch (status) {
      case StatusPedido.PENDING:
        return Icons.schedule;
      case StatusPedido.ACCEPTED:
        return Icons.check_circle;
      case StatusPedido.IN_TRANSIT:
        return Icons.local_shipping;
      case StatusPedido.OUT_FOR_DELIVERY:
        return Icons.delivery_dining;
      case StatusPedido.DELIVERED:
        return Icons.done_all;
      case StatusPedido.CANCELLED:
        return Icons.cancel;
      case StatusPedido.FAILED:
        return Icons.error;
    }
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