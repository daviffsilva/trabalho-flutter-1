import 'package:google_maps_flutter/google_maps_flutter.dart';

enum StatusEntrega {
  pendente,
  emAndamento,
  entregue,
  cancelada,
}

class Entrega {
  final int? id;
  final int clienteId;
  final int motoristaId;
  final String endereco;
  final StatusEntrega status;
  final DateTime dataCriacao;
  final DateTime? dataEntrega;
  final String? fotoEntrega;
  final String? fotoAssinatura;
  final double? latitude;
  final double? longitude;

  Entrega({
    this.id,
    required this.clienteId,
    required this.motoristaId,
    required this.endereco,
    required this.status,
    required this.dataCriacao,
    this.dataEntrega,
    this.fotoEntrega,
    this.fotoAssinatura,
    this.latitude,
    this.longitude,
  });

  factory Entrega.fromMap(Map<String, dynamic> map) {
    return Entrega(
      id: map['id'],
      clienteId: map['clienteId'],
      motoristaId: map['motoristaId'],
      endereco: map['endereco'] as String,
      status: StatusEntrega.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == map['status'],
      ),
      dataCriacao: DateTime.parse(map['dataCriacao'] as String),
      dataEntrega: map['dataEntrega'] != null
          ? DateTime.parse(map['dataEntrega'] as String)
          : null,
      fotoEntrega: map['fotoEntrega'] as String?,
      fotoAssinatura: map['fotoAssinatura'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clienteId': clienteId,
      'motoristaId': motoristaId,
      'endereco': endereco,
      'status': status.toString().split('.').last.toUpperCase(),
      'dataCriacao': dataCriacao.toIso8601String(),
      'dataEntrega': dataEntrega?.toIso8601String(),
      'fotoEntrega': fotoEntrega,
      'fotoAssinatura': fotoAssinatura,
      'latitude': latitude,
      'longitude': longitude,
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