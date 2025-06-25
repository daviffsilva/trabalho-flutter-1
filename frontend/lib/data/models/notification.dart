enum NotificationType {
  novoPedido,
  pedidoAceito,
  entregaIniciada,
  entregaConcluida,
  entregaCancelada,
  motoristaChegou,
  atualizacaoLocalizacao,
  geral
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.timestamp,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.geral,
      ),
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case NotificationType.novoPedido:
        return 'Novo Pedido';
      case NotificationType.pedidoAceito:
        return 'Pedido Aceito';
      case NotificationType.entregaIniciada:
        return 'Entrega Iniciada';
      case NotificationType.entregaConcluida:
        return 'Entrega Concluída';
      case NotificationType.entregaCancelada:
        return 'Entrega Cancelada';
      case NotificationType.motoristaChegou:
        return 'Motorista Chegou';
      case NotificationType.atualizacaoLocalizacao:
        return 'Atualização de Localização';
      case NotificationType.geral:
        return 'Notificação';
    }
  }
}

class NotificationPayload {
  final String? pedidoId;
  final String? entregaId;
  final String? motoristaId;
  final String? clienteId;
  final Map<String, dynamic> extra;

  NotificationPayload({
    this.pedidoId,
    this.entregaId,
    this.motoristaId,
    this.clienteId,
    this.extra = const {},
  });

  factory NotificationPayload.fromJson(Map<String, dynamic> json) {
    return NotificationPayload(
      pedidoId: json['pedidoId'],
      entregaId: json['entregaId'],
      motoristaId: json['motoristaId'],
      clienteId: json['clienteId'],
      extra: Map<String, dynamic>.from(json['extra'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pedidoId': pedidoId,
      'entregaId': entregaId,
      'motoristaId': motoristaId,
      'clienteId': clienteId,
      'extra': extra,
    };
  }
} 