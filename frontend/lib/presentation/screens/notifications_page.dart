import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/notification.dart';
import '../../data/services/firebase_notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FirebaseNotificationService _notificationService = FirebaseNotificationService();
  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notifications = await _notificationService.getStoredNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar notificações: $e')),
        );
      }
    }
  }

  Future<void> _markAsRead(AppNotification notification) async {
    if (!notification.isRead) {
      await _notificationService.markNotificationAsRead(notification.id);
      await _loadNotifications();
    }
  }

  Future<void> _clearAllNotifications() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Notificações'),
        content: const Text('Tem certeza que deseja limpar todas as notificações?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _notificationService.clearAllNotifications();
      await _loadNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearAllNotifications,
              tooltip: 'Limpar todas',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhuma notificação',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Você receberá notificações sobre seus pedidos aqui',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _buildNotificationTile(notification);
        },
      ),
    );
  }

  Widget _buildNotificationTile(AppNotification notification) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: notification.isRead ? 1 : 3,
      child: ListTile(
        leading: _buildNotificationIcon(notification.type),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.body,
              style: TextStyle(
                color: notification.isRead ? Colors.grey[600] : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  notification.typeDisplayName,
                  style: TextStyle(
                    fontSize: 12,
                    color: _getTypeColor(notification.type),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(notification.timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: notification.isRead
            ? const Icon(Icons.check, color: Colors.green, size: 20)
            : const Icon(Icons.circle, color: Colors.blue, size: 12),
        onTap: () => _markAsRead(notification),
        tileColor: notification.isRead ? null : Colors.blue.withOpacity(0.05),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type) {
    IconData iconData;
    Color color;

    switch (type) {
      case NotificationType.novoPedido:
        iconData = Icons.shopping_bag;
        color = Colors.green;
        break;
      case NotificationType.pedidoAceito:
        iconData = Icons.check_circle;
        color = Colors.blue;
        break;
      case NotificationType.entregaIniciada:
        iconData = Icons.local_shipping;
        color = Colors.orange;
        break;
      case NotificationType.entregaConcluida:
        iconData = Icons.task_alt;
        color = Colors.green;
        break;
      case NotificationType.entregaCancelada:
        iconData = Icons.cancel;
        color = Colors.red;
        break;
      case NotificationType.motoristaChegou:
        iconData = Icons.location_on;
        color = Colors.purple;
        break;
      case NotificationType.atualizacaoLocalizacao:
        iconData = Icons.my_location;
        color = Colors.teal;
        break;
      case NotificationType.geral:
      default:
        iconData = Icons.notifications;
        color = Colors.grey;
        break;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(
        iconData,
        color: color,
        size: 20,
      ),
    );
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.novoPedido:
        return Colors.green;
      case NotificationType.pedidoAceito:
        return Colors.blue;
      case NotificationType.entregaIniciada:
        return Colors.orange;
      case NotificationType.entregaConcluida:
        return Colors.green;
      case NotificationType.entregaCancelada:
        return Colors.red;
      case NotificationType.motoristaChegou:
        return Colors.purple;
      case NotificationType.atualizacaoLocalizacao:
        return Colors.teal;
      case NotificationType.geral:
      default:
        return Colors.grey;
    }
  }
} 