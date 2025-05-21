import 'package:flutter/material.dart';
import 'package:entrega_app/data/models/entrega.dart';
import 'package:entrega_app/data/services/entrega_service.dart';
import 'package:entrega_app/presentation/screens/cliente/entrega_rastreamento_page.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _entregaService = EntregaService();
  List<Entrega> _entregas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarEntregas();
  }

  Future<void> _carregarEntregas() async {
    setState(() => _isLoading = true);
    final entregas = await _entregaService.getEntregasByCliente(1); // Mock cliente ID
    setState(() {
      _entregas = entregas;
      _isLoading = false;
    });
  }

  Map<StatusEntrega, int> _getDeliveryStats() {
    final stats = <StatusEntrega, int>{};
    for (final status in StatusEntrega.values) {
      stats[status] = _entregas.where((e) => e.status == status).length;
    }
    return stats;
  }

  Color _getStatusColor(StatusEntrega status) {
    switch (status) {
      case StatusEntrega.entregue:
        return Colors.green;
      case StatusEntrega.emAndamento:
        return Colors.orange;
      case StatusEntrega.pendente:
        return Colors.blue;
      case StatusEntrega.cancelada:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = _getDeliveryStats();

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarEntregas,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: StatusEntrega.values.map((status) {
                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          status.label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: _getStatusColor(status),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${stats[status]}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Entregas Recentes',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _entregas.length,
              itemBuilder: (context, index) {
                final entrega = _entregas[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(entrega.endereco),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status: ${entrega.status.label}',
                          style: TextStyle(
                            color: _getStatusColor(entrega.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(entrega.dataCriacao)}',
                        ),
                      ],
                    ),
                    trailing: entrega.status == StatusEntrega.emAndamento
                        ? IconButton(
                            icon: const Icon(Icons.location_on),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EntregaRastreamentoPage(
                                    entrega: entrega,
                                  ),
                                ),
                              );
                            },
                          )
                        : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}