import 'package:entrega_app/data/models/entrega.dart';

class Rastreamento {
  final int id;
  final int entregaId;
  final double latitude;
  final double longitude;
  final DateTime dataAtualizacao;
  final String status;
  final String? observacao;

  Rastreamento({
    required this.id,
    required this.entregaId,
    required this.latitude,
    required this.longitude,
    required this.dataAtualizacao,
    required this.status,
    this.observacao,
  });

  factory Rastreamento.fromJson(Map<String, dynamic> json) {
    return Rastreamento(
      id: json['id'] as int,
      entregaId: json['entregaId'] as int,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      dataAtualizacao: DateTime.parse(json['dataAtualizacao'] as String),
      status: json['status'] as String,
      observacao: json['observacao'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entregaId': entregaId,
      'latitude': latitude,
      'longitude': longitude,
      'dataAtualizacao': dataAtualizacao.toIso8601String(),
      'status': status,
      'observacao': observacao,
    };
  }
} 