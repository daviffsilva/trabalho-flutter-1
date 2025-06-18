class Localizacao {
  final int? id;
  final int? driverId;
  final double? latitude;
  final double? longitude;
  final double? altitude;
  final double? speed;
  final double? heading;
  final double? accuracy;
  final DateTime? timestamp;
  final int? pedidoId;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Localizacao({
    this.id,
    this.driverId,
    this.latitude,
    this.longitude,
    this.altitude,
    this.speed,
    this.heading,
    this.accuracy,
    this.timestamp,
    this.pedidoId,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Localizacao.fromJson(Map<String, dynamic> json) {
    return Localizacao(
      id: json['id'] as int?,
      driverId: json['driverId'] as int?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      altitude: json['altitude'] as double?,
      speed: json['speed'] as double?,
      heading: json['heading'] as double?,
      accuracy: json['accuracy'] as double?,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String) 
          : null,
      pedidoId: json['pedidoId'] as int?,
      isActive: json['isActive'] as bool?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'accuracy': accuracy,
      'timestamp': timestamp?.toIso8601String(),
      'pedidoId': pedidoId,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Localizacao(id: $id, driverId: $driverId, latitude: $latitude, longitude: $longitude, pedidoId: $pedidoId, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Localizacao &&
        other.id == id &&
        other.driverId == driverId &&
        other.pedidoId == pedidoId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ driverId.hashCode ^ pedidoId.hashCode;
  }
} 