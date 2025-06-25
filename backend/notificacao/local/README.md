# Notification Service

Microserviço responsável por gerenciar notificações push e integrações com AWS SQS para processamento assíncrono de mensagens.

## Funcionalidades

### Principais Endpoints

- **POST** `/api/notification/send` - Enviar notificação individual
- **POST** `/api/notification/send-bulk` - Enviar notificações em massa
- **POST** `/api/notification/send-all` - Enviar notificação para todos os usuários
- **POST** `/api/notification/send-clientes` - Enviar notificação para todos os clientes
- **POST** `/api/notification/send-motoristas` - Enviar notificação para todos os motoristas
- **GET** `/api/notification/history/{userId}` - Histórico de notificações do usuário
- **GET** `/api/notification/status/{status}` - Filtrar notificações por status
- **GET** `/api/notification/type/{type}` - Filtrar notificações por tipo
- **GET** `/api/notification/stats` - Estatísticas das notificações
- **GET** `/api/notification/health` - Status de saúde do serviço

### Integração AWS SQS

O serviço publica mensagens em filas SQS da AWS para processamento assíncrono. As funções serverless (Lambda) consomem essas mensagens para entregar as notificações aos dispositivos finais.

### Recursos Implementados

1. **Autenticação JWT** - Validação de tokens JWT para endpoints protegidos
2. **Persistência** - Log de todas as notificações enviadas em PostgreSQL
3. **Validação** - Validação de entrada usando Bean Validation
4. **Documentação** - Swagger/OpenAPI 3.0 integrado
5. **Tratamento de Erros** - Handler global para exceções
6. **AWS SQS Integration** - Publicação de mensagens para processamento serverless

## Configuração

### Variáveis de Ambiente

```bash
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=notificacao_db
DB_USERNAME=daviffsilva
DB_PASSWORD=1234

# JWT
JWT_SECRET=mySecretKey1234567890123456789012345678901234567890

# Services
AUTH_SERVICE_URL=http://localhost:8081

# AWS
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_SQS_QUEUE_URL=https://sqs.us-east-1.amazonaws.com/123456789012/notification-queue
```

### Prerequisitos

- Java 17+
- PostgreSQL 13+
- Maven 3.8+
- Conta AWS com permissões SQS
- **Authentication Service** rodando (necessário para validação de tokens)

## Execução

### Local

```bash
# Compilar o projeto
mvn clean compile

# Executar os testes
mvn test

# Iniciar o serviço
mvn spring-boot:run
```

### Docker

```bash
# Build da imagem
docker build -t notification-service .

# Executar container
docker run -p 8084:8084 \
  -e DB_HOST=host.docker.internal \
  -e AWS_ACCESS_KEY_ID=your_key \
  -e AWS_SECRET_ACCESS_KEY=your_secret \
  notification-service
```

## API Documentation

Após iniciar o serviço, a documentação estará disponível em:
- **Swagger UI**: http://localhost:8084/api/notification/swagger-ui.html
- **OpenAPI JSON**: http://localhost:8084/api/notification/api-docs

## Arquitetura

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │───▶│  Notification   │───▶│   AWS SQS       │
│   (Flutter)     │    │   Service       │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │                        │
                              ▼                        ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │   PostgreSQL    │    │  Lambda Function│
                       │   (Logs)        │    │ (Push Delivery) │
                       └─────────────────┘    └─────────────────┘
```

## Monitoramento

### Health Check

```bash
curl http://localhost:8084/api/notification/health
```

### Estatísticas

```bash
curl -H "Authorization: Bearer <token>" \
     http://localhost:8084/api/notification/stats
```

## Integração com Outros Serviços

Este serviço se integra com:

1. **Authentication Service** - Para validação centralizada de tokens JWT (OBRIGATÓRIO)
2. **Pedidos Service** - Recebe eventos de finalização de pedidos
3. **AWS SQS** - Para processamento assíncrono
4. **AWS Lambda** - Para entrega final das notificações

### ⚠️ Ordem de Inicialização

**IMPORTANTE**: O Authentication Service deve estar rodando antes de iniciar o Notification Service, pois todas as validações de token são feitas através de chamadas HTTP para o endpoint `/api/auth/validate`.

```bash
# 1. Primeiro, inicie o Authentication Service
cd backend/autenticacao
mvn spring-boot:run

# 2. Em seguida, inicie o Notification Service
cd backend/notificacao
mvn spring-boot:run
```

## Desenvolvimento

### Estrutura do Projeto

```
src/main/java/com/entregas/notificacao/
├── config/         # Configurações (AWS, Security, OpenAPI)
├── controller/     # REST Controllers
├── dto/           # Data Transfer Objects
├── exception/     # Exception Handlers
├── filter/        # Security Filters
├── model/         # Entidades JPA
├── repository/    # Repositórios JPA
├── service/       # Business Logic
└── util/          # Utilities (JWT)
```

### Tipos de Notificação Suportados

- `PEDIDO_FINALIZADO` - Notificação de pedido concluído
- `AVALIACAO_SOLICITADA` - Solicitação de avaliação
- `PROMOCIONAL` - Campanhas promocionais
- `SISTEMA` - Notificações do sistema
- `URGENTE` - Notificações urgentes

### Prioridades Suportadas

- `LOW` - Baixa prioridade
- `NORMAL` - Prioridade normal (padrão)
- `HIGH` - Alta prioridade
- `URGENT` - Urgente

## Segurança

- Todos os endpoints (exceto `/health` e documentação) requerem autenticação JWT
- CORS configurado para permitir origens específicas
- Validação de entrada em todos os endpoints
- Logs de auditoria para todas as operações

### Roteamento de Tópicos

O serviço automaticamente determina o tópico SQS correto baseado no público-alvo:

| Target Audience | Tópico SQS | Descrição |
|-----------------|------------|-----------|
| `USER` | `user_{userId}` | Notificação específica para um usuário |
| `ALL_USERS` | `all_users` | Notificação para todos os usuários |
| `CLIENTES` | `clientes` | Notificação para todos os clientes |
| `MOTORISTAS` | `motoristas` | Notificação para todos os motoristas |