# Live Tracking Implementation

This document describes the implementation of live tracking functionality using WebSocket connections for real-time driver location updates.

## Overview

The live tracking system allows real-time monitoring of driver locations through WebSocket connections. It integrates with the Spring Boot backend's WebSocket implementation to provide instant location updates.

## Architecture

### Backend (Spring Boot)
- **WebSocket Configuration**: STOMP protocol over WebSocket
- **Topics**: 
  - `/topic/location-updates` - General location updates
  - `/topic/pedido/{id}/location` - Specific pedido location updates
  - `/topic/driver/{id}/location` - Specific driver location updates
- **Broadcasting**: Uses `SimpMessagingTemplate` to broadcast location updates

### Frontend (Flutter)
- **WebSocket Service**: Manages STOMP WebSocket connections
- **Live Tracking Service**: Orchestrates tracking streams and data conversion
- **UI Components**: Real-time map updates and status display

## Implementation Details

### 1. WebSocket Service (`lib/data/services/websocket_service.dart`)

**Key Features:**
- STOMP protocol implementation
- Automatic reconnection on disconnection
- Topic subscription management
- Error handling and logging

**Configuration:**
```dart
static const String _baseUrl = 'ws://localhost:8080';
static const String _wsEndpoint = '/ws';
```

**Usage:**
```dart
final webSocketService = WebSocketService();
await webSocketService.connect();
webSocketService.subscribeToPedidoLocation(pedidoId);
```

### 2. Live Tracking Service (`lib/data/services/live_tracking_service.dart`)

**Key Features:**
- Stream management for multiple tracking sessions
- Data conversion between backend and frontend models
- Automatic status determination based on location data
- Integration with existing rastreamento service

**Usage:**
```dart
final trackingService = LiveTrackingService();
await trackingService.initialize();
Stream<Rastreamento> stream = trackingService.startPedidoTracking(pedidoId);
```

### 3. Data Models

#### Localizacao Model (`lib/data/models/localizacao.dart`)
Matches the backend `LocalizacaoResponse` DTO:
- `driverId`, `pedidoId` - Entity identifiers
- `latitude`, `longitude` - GPS coordinates
- `speed`, `heading`, `accuracy` - Movement data
- `timestamp`, `isActive` - Status information

#### Rastreamento Model (Existing)
Frontend model for tracking data:
- `entregaId` - Delivery identifier
- `latitude`, `longitude` - Location coordinates
- `status`, `observacao` - Status and observations

### 4. UI Components

#### Live Tracking Widget (`lib/presentation/widgets/live_tracking_widget.dart`)
- Real-time Google Maps integration
- Connection status display
- Automatic camera animation to new locations
- Location information cards

#### Demo Page (`lib/presentation/pages/live_tracking_demo_page.dart`)
- User interface for testing tracking functionality
- Input fields for pedido and driver IDs
- Connection information display
- Usage instructions

## Usage Instructions

### 1. Starting the Backend
Ensure the Spring Boot rastreamento service is running:
```bash
cd rastreamento
./mvnw spring-boot:run
```

### 2. Running the Flutter App
```bash
flutter pub get
flutter run
```

### 3. Testing Live Tracking
1. Open the app and navigate to the main screen
2. Tap the location icon in the app bar
3. Enter a pedido ID (e.g., 1001) or driver ID (e.g., 123)
4. Tap "Iniciar Rastreamento"
5. View real-time location updates on the map

### 4. Simulating Location Updates
To test the system, you can send location updates to the backend:

```bash
curl -X POST http://localhost:8080/api/localizacoes/update \
  -H "Content-Type: application/json" \
  -d '{
    "driverId": 123,
    "pedidoId": 1001,
    "latitude": -23.550520,
    "longitude": -46.633308,
    "speed": 15.5,
    "heading": 45.0,
    "accuracy": 5.0
  }'
```

## WebSocket Protocol Details

### STOMP Frames

**Connect:**
```
CONNECT
accept-version:1.2
heart-beat:10000,10000

\x00
```

**Subscribe:**
```
SUBSCRIBE
id:sub-pedido-1001
destination:/topic/pedido/1001/location

\x00
```

**Message (from server):**
```
MESSAGE
destination:/topic/pedido/1001/location
content-type:application/json
content-length:123

{"id":1,"driverId":123,"pedidoId":1001,"latitude":-23.550520,"longitude":-46.633308,"timestamp":"2024-01-15T12:00:00"}
\x00
```

## Error Handling

### Connection Issues
- Automatic reconnection attempts every 5 seconds
- Connection status display in UI
- Error messages for failed connections

### Data Processing
- Null-safe data handling
- Graceful degradation for missing location data
- Validation of GPS coordinates

## Security Considerations

### WebSocket Security
- CORS configuration for WebSocket endpoints
- Origin validation in backend configuration
- Secure WebSocket connections (WSS) for production

### Data Privacy
- Location data should be encrypted in transit
- Implement authentication for WebSocket connections
- Consider data retention policies for location history

## Performance Optimization

### Connection Management
- Single WebSocket connection for multiple subscriptions
- Efficient topic subscription/unsubscription
- Connection pooling for multiple tracking sessions

### Data Efficiency
- Throttling of location updates (configurable frequency)
- Compression of WebSocket messages
- Efficient JSON serialization/deserialization

## Future Enhancements

### Planned Features
1. **Route Visualization**: Display planned vs actual routes
2. **ETA Calculation**: Real-time estimated arrival times
3. **Geofencing**: Alerts when entering/leaving specific areas
4. **Offline Support**: Cache location data for offline viewing
5. **Push Notifications**: Location-based alerts

### Technical Improvements
1. **WebSocket Authentication**: JWT token validation
2. **Message Queuing**: Reliable message delivery
3. **Scalability**: Load balancing for WebSocket connections
4. **Analytics**: Tracking performance metrics

## Troubleshooting

### Common Issues

1. **Connection Failed**
   - Check if backend is running on correct port
   - Verify WebSocket URL configuration
   - Check network connectivity

2. **No Location Updates**
   - Verify topic subscription
   - Check backend location broadcasting
   - Review WebSocket message format

3. **Map Not Updating**
   - Check Google Maps API key
   - Verify location data format
   - Review camera animation logic

### Debug Information
Enable debug logging by setting log level to DEBUG in the WebSocket service:
```dart
print('WebSocket connected successfully');
print('Subscribed to pedido location updates: $topic');
print('Received location update: $localizacao');
```

## Dependencies

### Flutter Dependencies
```yaml
web_socket_channel: ^2.4.0
google_maps_flutter: ^2.5.3
```

### Backend Dependencies
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-websocket</artifactId>
</dependency>
```

## Conclusion

The live tracking implementation provides a robust, real-time solution for monitoring driver locations. The WebSocket-based architecture ensures low-latency updates while maintaining scalability and reliability. The modular design allows for easy extension and customization based on specific requirements. 