import 'package:entrega_app/data/models/rastreamento.dart';
import 'package:entrega_app/data/models/entrega.dart';

class RastreamentoService {
  final List<Rastreamento> _mockRastreamentos = [
    Rastreamento(
      id: 1,
      entregaId: 1,
      latitude: -23.550520,
      longitude: -46.633308,
      dataAtualizacao: DateTime.now().subtract(const Duration(minutes: 5)),
      status: 'Em trânsito',
      observacao: 'Entregador a 2km do destino',
    ),
    Rastreamento(
      id: 2,
      entregaId: 2,
      latitude: -23.563210,
      longitude: -46.654190,
      dataAtualizacao: DateTime.now().subtract(const Duration(minutes: 15)),
      status: 'Coletado',
      observacao: 'Pacote coletado e em rota',
    ),
  ];

  Future<List<Rastreamento>> getRastreamentosByEntrega(int entregaId) async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockRastreamentos.where((r) => r.entregaId == entregaId).toList();
  }

  Future<Rastreamento?> getUltimoRastreamento(int entregaId) async {
    final rastreamentos = await getRastreamentosByEntrega(entregaId);
    if (rastreamentos.isEmpty) return null;
    return rastreamentos.reduce((a, b) => 
      a.dataAtualizacao.isAfter(b.dataAtualizacao) ? a : b);
  }

  Stream<Rastreamento> rastreamentoStream(int entregaId) async* {
    final rastreamento = await getUltimoRastreamento(entregaId);
    if (rastreamento != null) {
      yield rastreamento;
      while (true) {
        await Future.delayed(const Duration(seconds: 30));
        yield Rastreamento(
          id: rastreamento.id,
          entregaId: rastreamento.entregaId,
          latitude: rastreamento.latitude + 0.001,
          longitude: rastreamento.longitude + 0.001,
          dataAtualizacao: DateTime.now(),
          status: rastreamento.status,
          observacao: 'Atualização em tempo real',
        );
      }
    }
  }
} 