import 'package:flutter/material.dart';
import 'package:entrega_app/presentation/widgets/live_tracking_widget.dart';

class LiveTrackingDemoPage extends StatefulWidget {
  const LiveTrackingDemoPage({Key? key}) : super(key: key);

  @override
  State<LiveTrackingDemoPage> createState() => _LiveTrackingDemoPageState();
}

class _LiveTrackingDemoPageState extends State<LiveTrackingDemoPage> {
  final TextEditingController _pedidoController = TextEditingController();
  final TextEditingController _driverController = TextEditingController();
  int? _selectedPedidoId;
  int? _selectedDriverId;

  @override
  void dispose() {
    _pedidoController.dispose();
    _driverController.dispose();
    super.dispose();
  }

  void _startTracking() {
    final pedidoId = int.tryParse(_pedidoController.text);
    final driverId = int.tryParse(_driverController.text);
    
    if (pedidoId == null && driverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, insira um ID de pedido ou motorista')),
      );
      return;
    }

    setState(() {
      _selectedPedidoId = pedidoId;
      _selectedDriverId = driverId;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LiveTrackingWidget(
          pedidoId: _selectedPedidoId ?? 0,
          driverId: _selectedDriverId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Demo - Rastreamento em Tempo Real'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rastreamento em Tempo Real',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Teste o rastreamento em tempo real usando WebSocket. '
                    'Insira um ID de pedido ou motorista para começar.',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            Text(
              'ID do Pedido',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _pedidoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Ex: 1001',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_cart),
              ),
            ),
            
            SizedBox(height: 16),
            
            Text(
              'ID do Motorista (opcional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _driverController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Ex: 123',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            
            SizedBox(height: 24),
            
            ElevatedButton.icon(
              onPressed: _startTracking,
              icon: Icon(Icons.location_on),
              label: Text('Iniciar Rastreamento'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
            
            SizedBox(height: 24),
            
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Como usar:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildInstruction('1. Insira um ID de pedido para rastrear uma entrega específica'),
                  _buildInstruction('2. Ou insira um ID de motorista para rastrear um motorista específico'),
                  _buildInstruction('3. Clique em "Iniciar Rastreamento"'),
                  _buildInstruction('4. O app se conectará ao WebSocket e mostrará atualizações em tempo real'),
                  _buildInstruction('5. O mapa será atualizado automaticamente com a nova localização'),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange.shade700),
                      SizedBox(width: 8),
                      Text(
                        'Informações de Conexão',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• URL do WebSocket: ws://localhost:8080/ws',
                    style: TextStyle(color: Colors.orange.shade700),
                  ),
                  Text(
                    '• Protocolo: STOMP',
                    style: TextStyle(color: Colors.orange.shade700),
                  ),
                  Text(
                    '• Tópicos: /topic/pedido/{id}/location, /topic/driver/{id}/location',
                    style: TextStyle(color: Colors.orange.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(color: Colors.grey.shade700),
      ),
    );
  }
} 