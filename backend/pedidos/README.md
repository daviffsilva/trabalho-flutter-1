# Serviço de Pedidos

Micro-serviço contendo a lógica de gerenciamento de Pedidos e cálculo de rotas otimizadas.

## Funcionalidades

### Gerenciamento de Pedidos
- **CRUD completo de pedidos** com informações detalhadas (origem, destino, cliente, carga)
- **Atualização de status** (Pendente, Aceito, Em trânsito, Saiu para entrega, Entregue, Cancelado, Falhou)
- **Busca por diferentes critérios** (ID, cliente, motorista, status)
- **Pedidos disponíveis** para motoristas aceitarem

### Cálculo de Rotas
- **Integração com OSRM** (Open Source Routing Machine) para rotas otimizadas
- **Cálculo de distância e tempo estimado**
- **Fallback para cálculo simples** caso a API externa falhe
- **Instruções de navegação** detalhadas

### Recursos Técnicos
- **Documentação OpenAPI/Swagger** completa
- **Validação de dados** com mensagens em português
- **Tratamento de erros** padronizado
- **Banco de dados H2** para desenvolvimento
- **CORS configurado** para integração com frontend

## Endpoints Principais

### Pedidos
- `POST /api/orders` - Criar novo pedido
- `GET /api/orders/{id}` - Buscar pedido por ID
- `GET /api/orders/customer/{email}` - Pedidos por cliente
- `GET /api/orders/driver/{driverId}` - Pedidos por motorista
- `GET /api/orders/available` - Pedidos disponíveis
- `GET /api/orders/status/{status}` - Pedidos por status
- `PUT /api/orders/{id}/status` - Atualizar status
- `DELETE /api/orders/{id}` - Excluir pedido

### Rotas
- `GET /api/orders/route` - Calcular rota entre dois pontos

## Tecnologias Utilizadas

- **Spring Boot 3.2.0**
- **Spring Data JPA**
- **Spring Security**
- **H2 Database** (desenvolvimento)
- **PostgreSQL** (produção)
- **OpenAPI/Swagger**
- **OSRM API** (cálculo de rotas)

## Execução

### Pré-requisitos
- Java 17+
- Maven 3.6+

### Comandos
```bash
# Compilar
mvn clean compile

# Executar
mvn spring-boot:run

# Executar em porta específica
mvn spring-boot:run -Dspring-boot.run.arguments="--server.port=8082"
```

### Acessos
- **API**: http://localhost:8082/api/orders
- **Swagger UI**: http://localhost:8082/swagger-ui.html
- **H2 Console**: http://localhost:8082/h2-console

## Estrutura do Projeto

```
src/main/java/com/entregas/pedidos/
├── PedidosApplication.java          # Classe principal
├── config/                          # Configurações
│   ├── SecurityConfig.java         # Segurança
│   ├── OpenApiConfig.java          # Documentação
│   └── DataLoader.java             # Dados de teste
├── controller/                      # Controllers REST
│   └── OrderController.java        # Endpoints de pedidos
├── dto/                            # Objetos de transferência
│   ├── CreateOrderRequest.java     # Criação de pedido
│   ├── OrderResponse.java          # Resposta de pedido
│   ├── UpdateOrderStatusRequest.java # Atualização de status
│   ├── RouteResponse.java          # Resposta de rota
│   └── ErrorResponse.java          # Resposta de erro
├── exception/                      # Tratamento de exceções
│   ├── OrderException.java         # Exceções de negócio
│   └── GlobalExceptionHandler.java # Handler global
├── model/                          # Entidades
│   ├── Order.java                  # Entidade de pedido
│   └── OrderStatus.java            # Enum de status
├── repository/                     # Repositórios
│   └── OrderRepository.java        # Acesso a dados
└── service/                        # Lógica de negócio
    ├── OrderService.java           # Serviço de pedidos
    └── RouteService.java           # Serviço de rotas
```

## Integração com Outros Serviços

Este serviço está preparado para integração com:
- **Serviço de Autenticação** - Validação de JWT
- **Serviço de Rastreamento** - Atualizações de localização
- **Serviço de Notificações** - Alertas de status
- **API Gateway** - Roteamento centralizado

## Dados de Teste

O serviço inclui dados de exemplo para testes:
- 3 pedidos com diferentes status
- Coordenadas reais de São Paulo
- Informações completas de clientes e cargas