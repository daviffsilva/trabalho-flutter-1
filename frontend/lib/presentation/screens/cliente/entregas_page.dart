import 'package:flutter/material.dart';
import 'package:entrega_app/data/models/entrega.dart';
import 'package:entrega_app/data/services/entrega_service.dart';
import 'package:entrega_app/presentation/screens/cliente/entrega_rastreamento_page.dart';
import 'package:intl/intl.dart';

class EntregasPage extends StatefulWidget {
  const EntregasPage({super.key});

  @override
  State<EntregasPage> createState() => _EntregasPageState();
}

class _EntregasPageState extends State<EntregasPage> {
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
    final entregas = await _entregaService.getEntregasByCliente(1);
    setState(() {
      _entregas = entregas;
      _isLoading = false;
    });
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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_entregas.isEmpty) {
      return const Center(
        child: Text('Nenhuma entrega encontrada'),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarEntregas,
      child: ListView.builder(
        itemCount: _entregas.length,
        itemBuilder: (context, index) {
          final entrega = _entregas[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    );
  }
} 