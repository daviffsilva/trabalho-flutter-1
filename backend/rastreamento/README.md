# Serviço de Rastreamento

Micro-serviço contendo a lógica de rastreamento em tempo real de motoristas com suporte a WebSocket, autenticação JWT e banco de dados PostgreSQL.

## Funcionalidades

### Autenticação e Segurança
- **Validação JWT via serviço de autenticação** - Tokens são validados chamando o endpoint `/api/auth/validate` do serviço de autenticação
- **Controle de acesso baseado em roles** - DRIVER, CUSTOMER, ADMIN
- **Filtro de autenticação personalizado** - Valida tokens em cada requisição
- **Segurança em nível de método** - Anotações @PreAuthorize para controle granular

### Rastreamento em Tempo Real
- **WebSocket para atualizações em tempo real** de localização dos motoristas
- **Canais específicos** por motorista e pedido para rastreamento direcionado
- **Broadcast automático** de atualizações para todos os clientes conectados

### Gerenciamento de Localização
- **Atualização de localização** com dados completos (lat/lng, altitude, velocidade, direção, precisão)
- **Histórico de localizações** por motorista e pedido
- **Busca por período** para análises temporais
- **Localizações ativas** com controle de status
- **Auditoria completa** com timestamps de criação e atualização

### Recursos Técnicos
- **WebSocket com STOMP** para comunicação bidirecional
- **Documentação OpenAPI/Swagger** completa com autenticação
- **Validação de dados** com mensagens em português
- **Tratamento de erros** padronizado
- **Banco de dados PostgreSQL** para produção e desenvolvimento
- **CORS configurado** para integração com frontend
- **Docker Compose** para ambiente de desenvolvimento

## Autenticação

### Como Funciona
1. **Token JWT** deve ser enviado no header `Authorization: Bearer <token>`
2. **Validação remota** - O serviço chama o endpoint de validação do serviço de autenticação
3. **Extração de informações** - User ID e tipo de usuário são extraídos do token válido
4. **Controle de acesso** - Permissões baseadas no tipo de usuário (DRIVER, CUSTOMER, ADMIN)

### Roles e Permissões
- **DRIVER**: Pode atualizar localização e ver suas próprias localizações
- **CUSTOMER**: Pode ver localizações de pedidos e motoristas
- **ADMIN**: Acesso completo a todas as funcionalidades

### Configuração
```yaml
auth:
  service:
    url: http://localhost:8081  # URL do serviço de autenticação
```

## Endpoints Principais

### Localização (Todos requerem autenticação JWT)
- `POST /api/localizacoes/update` - Atualizar localização (DRIVER, ADMIN)
- `GET /api/localizacoes/driver/{driverId}/latest` - Última localização por motorista (DRIVER, ADMIN, CUSTOMER)
- `GET /api/localizacoes/pedido/{pedidoId}/latest` - Última localização por pedido (DRIVER, ADMIN, CUSTOMER)
- `GET /api/localizacoes/driver/{driverId}` - Histórico por motorista (DRIVER, ADMIN)
- `GET /api/localizacoes/pedido/{pedidoId}` - Histórico por pedido (DRIVER, ADMIN, CUSTOMER)
- `GET /api/localizacoes/driver/{driverId}/timerange` - Localizações por período (motorista) (DRIVER, ADMIN)
- `GET /api/localizacoes/pedido/{pedidoId}/timerange` - Localizações por período (pedido) (DRIVER, ADMIN, CUSTOMER)
- `GET /api/localizacoes/active/since` - Localizações ativas desde um momento (ADMIN)
- `GET /api/localizacoes/driver/{driverId}/pedido/{pedidoId}` - Localizações por motorista e pedido (DRIVER, ADMIN, CUSTOMER)
- `DELETE /api/localizacoes/{id}` - Desativar localização (DRIVER, ADMIN)

### WebSocket (Não requer autenticação)
- `ws://localhost:8083/ws` - Endpoint WebSocket principal
- `/topic/driver/{driverId}/location` - Canal específico por motorista
- `/topic/pedido/{pedidoId}/location` - Canal específico por pedido
- `/topic/location-updates` - Canal geral de rastreamento

## Tecnologias Utilizadas

- **Spring Boot 3.2.0**
- **Spring WebSocket** com STOMP
- **Spring Data JPA**
- **Spring Security** com JWT
- **Spring Method Security** para controle de acesso
- **PostgreSQL 15** (banco de dados principal)
- **H2 Database** (desenvolvimento/testes)
- **OpenAPI/Swagger**
- **SockJS** para fallback
- **RestTemplate** para comunicação entre serviços
- **Docker Compose** para ambiente de desenvolvimento

## Execução

### Pré-requisitos
- Java 17+
- Maven 3.6+
- **Docker e Docker Compose** para banco de dados
- **Serviço de Autenticação** rodando na porta 8081

### Configuração do Banco de Dados
```bash
# Iniciar PostgreSQL e PgAdmin
cd backend/rastreamento
docker-compose up -d

# Verificar se os containers estão rodando
docker-compose ps
```

### Comandos
```bash
# Compilar
mvn clean compile

# Executar
mvn spring-boot:run

# Executar em porta específica
mvn spring-boot:run -Dspring-boot.run.arguments="--server.port=8083"

# Executar com perfil de desenvolvimento
mvn spring-boot:run -Dspring.profiles.active=dev
```

### Acessos
- **API**: http://localhost:8083/api/localizacoes
- **Swagger UI**: http://localhost:8083/api/rastreamento/swagger-ui.html
- **API Docs**: http://localhost:8083/api/rastreamento/api-docs
- **WebSocket**: ws://localhost:8083/ws

## Estrutura do Projeto

```
src/main/java/com/entregas/rastreamento/
├── RastreamentoApplication.java      # Classe principal
├── config/                           # Configurações
│   ├── SecurityConfig.java          # Segurança e autenticação
│   ├── OpenApiConfig.java           # Documentação
│   ├── WebSocketConfig.java         # Configuração WebSocket
│   └── DataLoader.java              # Dados de teste
├── controller/                       # Controllers REST
│   └── LocalizacaoController.java   # Endpoints de localização
├── dto/                             # Objetos de transferência
│   ├── LocalizacaoUpdateRequest.java # Atualização de localização
│   ├── LocalizacaoResponse.java     # Resposta de localização
│   ├── WebSocketMessage.java        # Mensagem WebSocket
│   └── ErrorResponse.java           # Resposta de erro
├── exception/                       # Tratamento de exceções
│   ├── LocationNotFoundException.java # Exceções de negócio
│   └── GlobalExceptionHandler.java  # Handler global
├── filter/                          # Filtros
│   └── JwtAuthenticationFilter.java # Filtro de autenticação JWT
├── model/                           # Entidades
│   └── Localizacao.java             # Entidade de localização
├── repository/                      # Repositórios
│   └── LocalizacaoRepository.java   # Acesso a dados
└── service/                         # Lógica de negócio
    ├── LocalizacaoService.java      # Serviço de localização
    └── TokenValidationService.java  # Validação de tokens
```

## Configuração do Banco de Dados

### Variáveis de Ambiente
```bash
# Configuração do Banco de Dados
DB_HOST=<Endereço do host do banco de dados>
DB_PORT=<Número da porta do banco de dados>
DB_NAME=<Nome do banco de dados>
DB_USERNAME=<Nome de usuário do banco de dados>
DB_PASSWORD=<Senha do banco de dados>

# Configuração JWT
JWT_SECRET=<Chave secreta do JWT>
```

### Schema do Banco
O serviço utiliza a tabela `localizacoes` com os seguintes campos:
- `id` - Identificador único
- `driver_id` - ID do motorista
- `latitude` - Latitude da localização
- `longitude` - Longitude da localização
- `altitude` - Altitude (opcional)
- `speed` - Velocidade (opcional)
- `heading` - Direção (opcional)
- `accuracy` - Precisão do GPS (opcional)
- `timestamp` - Momento da localização
- `pedido_id` - ID do pedido (opcional)
- `is_active` - Status ativo/inativo
- `created_at` - Data de criação
- `updated_at` - Data de atualização

## Integração com Frontend (Flutter)

### Autenticação
```dart
// Obter token do serviço de autenticação
final authResponse = await http.post(
  Uri.parse('http://localhost:8081/api/auth/login'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'email': 'driver@example.com',
    'password': 'password'
  }),
);

final token = jsonDecode(authResponse.body)['accessToken'];
```

### REST API com Autenticação
```dart
// Atualizar localização com token
final response = await http.post(
  Uri.parse('http://localhost:8083/api/localizacoes/update'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token'
  },
  body: jsonEncode({
    'driverId': 123,
    'latitude': -23.5505,
    'longitude': -46.6333,
    'speed': 15.5,
    'pedidoId': 456
  }),
);

// Buscar última localização com token
final location = await http.get(
  Uri.parse('http://localhost:8083/api/localizacoes/driver/123/latest'),
  headers: {'Authorization': 'Bearer $token'},
);
```

### WebSocket Connection
```dart
// Conectar ao WebSocket (não requer autenticação)
final socket = WebSocketChannel.connect(
  Uri.parse('ws://localhost:8083/ws'),
);

// Inscrever em canal específico do pedido
socket.sink.add(jsonEncode({
  'destination': '/topic/pedido/456/location',
  'type': 'SUBSCRIBE'
}));

// Receber atualizações
socket.stream.listen((message) {
  final data = jsonDecode(message);
  // Processar atualização de localização
});
```

## Integração com Outros Serviços

Este serviço está integrado com:
- **Serviço de Autenticação** - Validação de JWT via HTTP
- **Serviço de Pedidos** - Atualizações de status baseadas em localização
- **Serviço de Notificações** - Alertas de proximidade
- **API Gateway** - Roteamento centralizado

## Dados de Teste

O serviço inclui dados de exemplo para testes:
- 3 motoristas diferentes com localizações
- Coordenadas reais de São Paulo
- Dados completos de velocidade, direção e precisão
- Dados de auditoria (created_at, updated_at)

## Segurança

### Validação de Token
- **Chamada HTTP** para o serviço de autenticação
- **Timeout configurável** para evitar travamentos
- **Fallback seguro** em caso de falha na comunicação
- **Logging detalhado** para auditoria

### Controle de Acesso
- **Roles específicos** para cada operação
- **Validação em tempo real** de permissões
- **Isolamento de dados** por tipo de usuário
- **Auditoria completa** de acessos
