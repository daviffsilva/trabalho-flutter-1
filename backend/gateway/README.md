# API Gateway Service

Gateway de entrada único para todos os microserviços da plataforma de entregas.

## Funcionalidades

### Roteamento de Serviços

O gateway roteia automaticamente as requisições para os microserviços corretos baseado no path:

| Path | Serviço de Destino | Porta Padrão |
|------|-------------------|--------------|
| `/api/auth/**` | Authentication Service | 8081 |
| `/api/pedidos/**` | Pedidos Service | 8082 |
| `/api/localizacoes/**` | Rastreamento Service | 8083 |
| `/api/notification/**` | Notification Service | 8084 |

### Recursos Implementados

1. **Roteamento Inteligente** - Direcionamento automático baseado em path
2. **CORS Configurado** - Permite requisições de diferentes origens
3. **Documentação Centralizada** - Swagger UI agregado
4. **Configuração Flexível** - URLs dos serviços configuráveis via variáveis de ambiente

## Configuração

### Variáveis de Ambiente

```bash
# Service URLs
AUTH_SERVICE_URL=http://localhost:8081
PEDIDOS_SERVICE_URL=http://localhost:8082
RASTREAMENTO_SERVICE_URL=http://localhost:8083
NOTIFICATION_SERVICE_URL=http://localhost:8084

```

### Prerequisitos

- Java 17+
- Maven 3.8+
- **Todos os microserviços** rodando nas portas configuradas

## Execução

### Local

```bash
# Compilar o projeto
mvn clean compile

# Executar os testes
mvn test

# Iniciar o gateway
mvn spring-boot:run
```

O gateway estará disponível na porta **8080**.

### ⚠️ Ordem de Inicialização

**IMPORTANTE**: O gateway deve ser iniciado **após** todos os microserviços:

```bash
# 1. Authentication Service
cd backend/autenticacao
mvn spring-boot:run &

# 2. Notification Service  
cd backend/notificacao
mvn spring-boot:run &

# 3. Pedidos Service
cd backend/pedidos
mvn spring-boot:run &

# 4. Rastreamento Service
cd backend/rastreamento
mvn spring-boot:run &

# 5. Por último, o Gateway
cd backend/gateway
mvn spring-boot:run
```

## Endpoints Disponíveis

### Através do Gateway (porta 8080)

#### Authentication Service
- `POST http://localhost:8080/api/auth/register`
- `POST http://localhost:8080/api/auth/login`
- `POST http://localhost:8080/api/auth/validate`
- `GET http://localhost:8080/api/auth/health`

#### Pedidos Service
- `POST http://localhost:8080/api/pedidos`
- `GET http://localhost:8080/api/pedidos/{id}`
- `PUT http://localhost:8080/api/pedidos/{id}/claim`
- `PUT http://localhost:8080/api/pedidos/{id}/status`
- `GET http://localhost:8080/api/pedidos/available`

#### Rastreamento Service
- `POST http://localhost:8080/api/localizacoes/update`
- `GET http://localhost:8080/api/localizacoes/driver/{driverId}/latest`
- `GET http://localhost:8080/api/localizacoes/pedido/{pedidoId}/latest`
- `GET http://localhost:8080/api/localizacoes/driver/{driverId}`
- `GET http://localhost:8080/api/localizacoes/pedido/{pedidoId}`

#### Notification Service
- `POST http://localhost:8080/api/notification/send`
- `POST http://localhost:8080/api/notification/send-bulk`
- `POST http://localhost:8080/api/notification/send-motoristas`
- `POST http://localhost:8080/api/notification/send-clientes`
- `GET http://localhost:8080/api/notification/health`

## Documentação

### Swagger UI

Após iniciar o gateway e todos os serviços:
- **Gateway Swagger**: http://localhost:8080/swagger-ui.html

### Documentação Individual dos Serviços

- **Authentication**: http://localhost:8081/api/auth/swagger-ui.html
- **Pedidos**: http://localhost:8082/api/pedidos/swagger-ui.html
- **Rastreamento**: http://localhost:8083/api/rastreamento/swagger-ui.html
- **Notification**: http://localhost:8084/api/notification/swagger-ui.html

## Benefícios do Gateway

1. **Ponto de Entrada Único** - Simplifica a integração do frontend
2. **Load Balancing** - Distribui carga entre instâncias (quando configurado)
3. **Segurança Centralizada** - Validação de tokens em um ponto
4. **Monitoramento** - Logs centralizados de todas as requisições
5. **Versionamento** - Controle de versões de API facilitado

## Configuração de Produção

Para ambiente de produção, considere:

```yaml
# application-prod.yml
spring:
  cloud:
    gateway:
      routes:
        - id: autenticacao-service
          uri: http://auth-service:8081
          predicates:
            - Path=/api/auth/**
        - id: pedidos-service
          uri: http://pedidos-service:8082
          predicates:
            - Path=/api/pedidos/**
        - id: rastreamento-service
          uri: http://rastreamento-service:8083
          predicates:
            - Path=/api/localizacoes/**
        - id: notificacao-service
          uri: http://notification-service:8084
          predicates:
            - Path=/api/notification/**
```

## Troubleshooting

### Gateway não encontra serviços
- Verifique se todos os microserviços estão rodando
- Confirme as portas e URLs configuradas
- Teste conectividade direta com cada serviço

### Problemas de CORS
- Verifique configuração `DedupeResponseHeader`
- Confirme origins permitidos nos microserviços

### Timeouts
- Ajuste timeouts do Spring Cloud Gateway
- Verifique latência dos microserviços
