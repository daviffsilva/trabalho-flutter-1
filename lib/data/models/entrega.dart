import 'package:google_maps_flutter/google_maps_flutter.dart';

enum StatusEntrega {
  pendente('Pendente'),
  emAndamento('Em Andamento'),
  entregue('Entregue'),
  cancelada('Cancelada');

  final String label;
  const StatusEntrega(this.label);
}

class Entrega {
  final int? id;
  final int clienteId;
  final int motoristaId;
  final String endereco;
  final double? latitude;
  final double? longitude;
  final StatusEntrega status;
  final DateTime dataCriacao;
  final DateTime? dataEntrega;
  final String? fotoEntrega;
  final String? fotoAssinatura;

  Entrega({
    this.id,
    required this.clienteId,
    required this.motoristaId,
    required this.endereco,
    this.latitude,
    this.longitude,
    required this.status,
    required this.dataCriacao,
    this.dataEntrega,
    this.fotoEntrega,
    this.fotoAssinatura,
  });

  factory Entrega.fromJson(Map<String, dynamic> json) {
    return Entrega(
      id: json['id'] as int,
      clienteId: json['clienteId'] as int,
      motoristaId: json['motoristaId'] as int,
      endereco: json['endereco'] as String,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      status: StatusEntrega.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == (json['status'] as String).toUpperCase(),
      ),
      dataCriacao: DateTime.parse(json['dataCriacao'] as String),
      dataEntrega: json['dataEntrega'] != null
          ? DateTime.parse(json['dataEntrega'] as String)
          : null,
      fotoEntrega: json['fotoEntrega'] as String?,
      fotoAssinatura: json['fotoAssinatura'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clienteId': clienteId,
      'motoristaId': motoristaId,
      'endereco': endereco,
      'latitude': latitude,
      'longitude': longitude,
      'status': status.toString().split('.').last,
      'dataCriacao': dataCriacao.toIso8601String(),
      'dataEntrega': dataEntrega?.toIso8601String(),
      'fotoEntrega': fotoEntrega,
      'fotoAssinatura': fotoAssinatura,
    };
  }

  LatLng? get location {
    if (latitude != null && longitude != null) {
      return LatLng(latitude!, longitude!);
    }
    return null;
  }

  bool get hasLocation => latitude != null && longitude != null;
} 