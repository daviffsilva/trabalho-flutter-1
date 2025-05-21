import 'package:entrega_app/data/models/entrega.dart';

class EntregaService {
  final List<Entrega> _entregas = [
    Entrega(
      id: 1,
      clienteId: 1,
      motoristaId: 1,
      endereco: 'Rua das Flores, 123',
      latitude: -23.550520,
      longitude: -46.633308,
      status: StatusEntrega.pendente,
      dataCriacao: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Entrega(
      id: 2,
      clienteId: 2,
      motoristaId: 1,
      endereco: 'Av. Paulista, 1000',
      latitude: -23.563210,
      longitude: -46.654190,
      status: StatusEntrega.emAndamento,
      dataCriacao: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Entrega(
      id: 3,
      clienteId: 3,
      motoristaId: 1,
      endereco: 'Rua Augusta, 500',
      latitude: -23.548940,
      longitude: -46.638820,
      status: StatusEntrega.pendente,
      dataCriacao: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];

  Future<List<Entrega>> obterEntregasPendentes() async {
    return _entregas.where((e) => e.status == StatusEntrega.pendente).toList();
  }

  Future<List<Entrega>> obterEntregasEmAndamento() async {
    return _entregas.where((e) => e.status == StatusEntrega.emAndamento).toList();
  }

  Future<List<Entrega>> obterEntregasConcluidas() async {
    return _entregas.where((e) => e.status == StatusEntrega.entregue).toList();
  }

  Future<void> atualizarStatusEntrega(String id, String novoStatus) async {
    final index = _entregas.indexWhere((e) => e.id == id);
    if (index != -1) {
      final entrega = _entregas[index];
      _entregas[index] = Entrega(
        id: entrega.id,
        clienteId: entrega.clienteId,
        motoristaId: entrega.motoristaId,
        endereco: entrega.endereco,
        latitude: entrega.latitude,
        longitude: entrega.longitude,
        status: StatusEntrega.values.firstWhere((e) => e.toString().split('.').last.toUpperCase() == novoStatus),
        dataCriacao: entrega.dataCriacao,
        dataEntrega: novoStatus == 'concluida' ? DateTime.now() : entrega.dataEntrega,
        fotoAssinatura: entrega.fotoAssinatura,
        fotoEntrega: entrega.fotoEntrega,
      );
    }
  }

  Future<void> adicionarFotoEntrega(String id, String fotoPath) async {
    final index = _entregas.indexWhere((e) => e.id == id);
    if (index != -1) {
      final entrega = _entregas[index];
      _entregas[index] = Entrega(
        id: entrega.id,
        clienteId: entrega.clienteId,
        motoristaId: entrega.motoristaId,
        endereco: entrega.endereco,
        latitude: entrega.latitude,
        longitude: entrega.longitude,
        status: entrega.status,
        dataCriacao: entrega.dataCriacao,
        dataEntrega: entrega.dataEntrega,
        fotoAssinatura: entrega.fotoAssinatura,
        fotoEntrega: fotoPath,
      );
    }
  }

  Future<void> adicionarFotoAssinatura(String id, String fotoPath) async {
    final index = _entregas.indexWhere((e) => e.id == id);
    if (index != -1) {
      final entrega = _entregas[index];
      _entregas[index] = Entrega(
        id: entrega.id,
        clienteId: entrega.clienteId,
        motoristaId: entrega.motoristaId,
        endereco: entrega.endereco,
        latitude: entrega.latitude,
        longitude: entrega.longitude,
        status: entrega.status,
        dataCriacao: entrega.dataCriacao,
        dataEntrega: entrega.dataEntrega,
        fotoAssinatura: fotoPath,
        fotoEntrega: entrega.fotoEntrega,
      );
    }
  }
} 