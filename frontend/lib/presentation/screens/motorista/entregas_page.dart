import 'package:flutter/material.dart';
import 'package:entrega_app/data/database/database_helper.dart';
import 'package:entrega_app/data/models/entrega.dart';
import 'package:entrega_app/data/services/usuario_service.dart';
import 'package:entrega_app/presentation/screens/motorista/entrega_detalhes_page.dart';
import 'package:intl/intl.dart';

class MotoristaEntregasPage extends StatefulWidget {
  const MotoristaEntregasPage({super.key});

  @override
  State<MotoristaEntregasPage> createState() => _MotoristaEntregasPageState();
}

class _MotoristaEntregasPageState extends State<MotoristaEntregasPage> {
  final _databaseHelper = DatabaseHelper();
  final _usuarioService = UsuarioService();
  List<Entrega> _entregas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarEntregas();
  }

  Future<void> _carregarEntregas() async {
    setState(() => _isLoading = true);
    try {
      final usuario = await _usuarioService.obterUsuario();
      if (usuario != null) {
        final entregas = await _databaseHelper.getEntregasByMotorista(usuario.id);
        setState(() {
          _entregas = entregas;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar entregas: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
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
                    'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(entrega.dataCriacao)}',
                  ),
                  if (entrega.dataEntrega != null)
                    Text(
                      'Entregue em: ${DateFormat('dd/MM/yyyy HH:mm').format(entrega.dataEntrega!)}',
                    ),
                ],
              ),
              trailing: Chip(
                label: Text(
                  entrega.status.toString().split('.').last.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: _getStatusColor(entrega.status),
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/motorista/entrega-detalhes',
                  arguments: entrega,
                );
              },
            ),
          );
        },
      ),
    );
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
} 