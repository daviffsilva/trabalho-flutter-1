import 'package:google_maps_flutter/google_maps_flutter.dart';

enum StatusPedido {
  PENDING('Pendente'),
  ACCEPTED('Aceito'),
  IN_TRANSIT('Em Trânsito'),
  OUT_FOR_DELIVERY('Saiu para Entrega'),
  DELIVERED('Entregue'),
  CANCELLED('Cancelado'),
  FAILED('Falhou');

  final String label;
  const StatusPedido(this.label);

  static StatusPedido fromString(String status) {
    return StatusPedido.values.firstWhere(
      (e) => e.name == status,
      orElse: () => StatusPedido.PENDING,
    );
  }
}

class Pedido {
  final int? id;
  final String originAddress;
  final String destinationAddress;
  final double originLatitude;
  final double originLongitude;
  final double destinationLatitude;
  final double destinationLongitude;
  final int? clienteId;
  final String clienteNome;
  final String clienteEmail;
  final String? clienteTelefone;
  final String cargoType;
  final double? cargoWeight;
  final String? cargoDimensions;
  final String? specialInstructions;
  final StatusPedido status;
  final int? motoristaId;
  final double? estimatedDistance;
  final int? estimatedDuration;
  final double? totalPrice;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveredAt;
  final String? deliveryPhotoUrl;
  final String? deliverySignature;

  Pedido({
    this.id,
    required this.originAddress,
    required this.destinationAddress,
    required this.originLatitude,
    required this.originLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    this.clienteId,
    required this.clienteNome,
    required this.clienteEmail,
    this.clienteTelefone,
    required this.cargoType,
    this.cargoWeight,
    this.cargoDimensions,
    this.specialInstructions,
    required this.status,
    this.motoristaId,
    this.estimatedDistance,
    this.estimatedDuration,
    this.totalPrice,
    required this.createdAt,
    this.updatedAt,
    this.deliveredAt,
    this.deliveryPhotoUrl,
    this.deliverySignature,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'],
      originAddress: json['originAddress'],
      destinationAddress: json['destinationAddress'],
      originLatitude: json['originLatitude']?.toDouble() ?? 0.0,
      originLongitude: json['originLongitude']?.toDouble() ?? 0.0,
      destinationLatitude: json['destinationLatitude']?.toDouble() ?? 0.0,
      destinationLongitude: json['destinationLongitude']?.toDouble() ?? 0.0,
      clienteId: json['clienteId'],
      clienteNome: json['clienteNome'],
      clienteEmail: json['clienteEmail'],
      clienteTelefone: json['clienteTelefone'],
      cargoType: json['cargoType'],
      cargoWeight: json['cargoWeight']?.toDouble(),
      cargoDimensions: json['cargoDimensions'],
      specialInstructions: json['specialInstructions'],
      status: StatusPedido.fromString(json['status']),
      motoristaId: json['motoristaId'],
      estimatedDistance: json['estimatedDistance']?.toDouble(),
      estimatedDuration: json['estimatedDuration'],
      totalPrice: json['totalPrice']?.toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
      deliveryPhotoUrl: json['deliveryPhotoUrl'],
      deliverySignature: json['deliverySignature'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originAddress': originAddress,
      'destinationAddress': destinationAddress,
      'originLatitude': originLatitude,
      'originLongitude': originLongitude,
      'destinationLatitude': destinationLatitude,
      'destinationLongitude': destinationLongitude,
      'clienteId': clienteId,
      'clienteNome': clienteNome,
      'clienteEmail': clienteEmail,
      'clienteTelefone': clienteTelefone,
      'cargoType': cargoType,
      'cargoWeight': cargoWeight,
      'cargoDimensions': cargoDimensions,
      'specialInstructions': specialInstructions,
      'status': status.name,
      'motoristaId': motoristaId,
      'estimatedDistance': estimatedDistance,
      'estimatedDuration': estimatedDuration,
      'totalPrice': totalPrice,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'deliveryPhotoUrl': deliveryPhotoUrl,
      'deliverySignature': deliverySignature,
    };
  }

  LatLng get originLocation => LatLng(originLatitude, originLongitude);
  LatLng get destinationLocation => LatLng(destinationLatitude, destinationLongitude);

  bool get isPending => status == StatusPedido.PENDING;
  bool get isAccepted => status == StatusPedido.ACCEPTED;
  bool get isInTransit => status == StatusPedido.IN_TRANSIT;
  bool get isOutForDelivery => status == StatusPedido.OUT_FOR_DELIVERY;
  bool get isDelivered => status == StatusPedido.DELIVERED;
  bool get isCancelled => status == StatusPedido.CANCELLED;
  bool get isFailed => status == StatusPedido.FAILED;

  bool get canBeAccepted => status == StatusPedido.PENDING;
  bool get canBeStarted => status == StatusPedido.ACCEPTED;
  bool get canBeDelivered => status == StatusPedido.OUT_FOR_DELIVERY;
}

class CreatePedidoRequest {
  final String originAddress;
  final String destinationAddress;
  final double originLatitude;
  final double originLongitude;
  final double destinationLatitude;
  final double destinationLongitude;
  final int clienteId;
  final String clienteNome;
  final String clienteEmail;
  final String? clienteTelefone;
  final String cargoType;
  final double? cargoWeight;
  final String? cargoDimensions;
  final String? specialInstructions;

  CreatePedidoRequest({
    required this.originAddress,
    required this.destinationAddress,
    required this.originLatitude,
    required this.originLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.clienteId,
    required this.clienteNome,
    required this.clienteEmail,
    this.clienteTelefone,
    required this.cargoType,
    this.cargoWeight,
    this.cargoDimensions,
    this.specialInstructions,
  });

  Map<String, dynamic> toJson() {
    return {
      'originAddress': originAddress,
      'destinationAddress': destinationAddress,
      'originLatitude': originLatitude,
      'originLongitude': originLongitude,
      'destinationLatitude': destinationLatitude,
      'destinationLongitude': destinationLongitude,
      'clienteId': clienteId,
      'clienteNome': clienteNome,
      'clienteEmail': clienteEmail,
      'clienteTelefone': clienteTelefone,
      'cargoType': cargoType,
      'cargoWeight': cargoWeight,
      'cargoDimensions': cargoDimensions,
      'specialInstructions': specialInstructions,
    };
  }
}

class UpdatePedidoStatusRequest {
  final StatusPedido status;
  final int? driverId;
  final String? deliveryPhotoUrl;
  final String? deliverySignature;

  UpdatePedidoStatusRequest({
    required this.status,
    this.driverId,
    this.deliveryPhotoUrl,
    this.deliverySignature,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      if (driverId != null) 'driverId': driverId,
      if (deliveryPhotoUrl != null) 'deliveryPhotoUrl': deliveryPhotoUrl,
      if (deliverySignature != null) 'deliverySignature': deliverySignature,
    };
  }
} 