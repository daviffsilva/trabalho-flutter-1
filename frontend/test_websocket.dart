import 'dart:io';
import 'dart:convert';

void main() async {
  print('Testing WebSocket connection...');
  
  try {
    final socket = await WebSocket.connect('ws://localhost:8080/ws');
    print('WebSocket connected successfully!');
    
    final connectFrame = 'CONNECT\naccept-version:1.2\nheart-beat:10000,10000\n\n\x00';
    socket.add(connectFrame);
    print('Sent CONNECT frame');
    
    socket.listen(
      (data) {
        print('Received: $data');
        if (data.toString().startsWith('CONNECTED')) {
          print('STOMP connection established!');
          
          final subscribeFrame = 'SUBSCRIBE\nid:test-sub\ndestination:/topic/location-updates\n\n\x00';
          socket.add(subscribeFrame);
          print('Sent SUBSCRIBE frame');
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket connection closed');
      },
    );
    
    await Future.delayed(Duration(seconds: 10));
    socket.close();
    
  } catch (e) {
    print('Failed to connect: $e');
    print('Make sure the Spring Boot backend is running on localhost:8080');
  }
} 