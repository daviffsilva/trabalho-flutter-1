# Serviço de Autenticação

Micro-serviço contendo a lógica de autenticação e autorização para o sistema de entregas.

## Funcionalidades

- Registro de usuários (clientes e motoristas)
- Login com geração de JWT tokens
- Validação de tokens JWT
- Renovação de tokens (refresh tokens)
- Gerenciamento seguro de senhas com BCrypt
- **Documentação interativa da API com Swagger UI**

## Tecnologias Utilizadas

- Spring Boot 3.2.0
- Spring Security
- Spring Data JPA
- PostgreSQL Database
- JWT (JSON Web Tokens)
- SpringDoc OpenAPI (Swagger)
- Maven

## Configuração e Execução

### Pré-requisitos

- Java 17 ou superior
- Maven 3.6 ou superior
- PostgreSQL 12 ou superior

### Configuração do Banco de Dados

1. **Certifique-se de que o PostgreSQL está rodando na porta 5432**

2. **Crie o banco de dados usando uma das opções abaixo:**

   **Opção 1: Usando psql (se disponível)**
   ```bash
   psql -U <usuario> -h <servidor> -p 5432 -c "CREATE DATABASE autenticacao_db;"
   ```

   **Opção 2: Usando pgAdmin ou outro cliente PostgreSQL**
   - Conecte ao PostgreSQL como usuário `<usuario>`
   - Execute: `CREATE DATABASE autenticacao_db;`

   **Opção 3: Usando Docker (se PostgreSQL estiver em container)**
   ```bash
   docker exec -it postgres_container psql -U <usuario> -c "CREATE DATABASE autenticacao_db;"
   ```

3. **Verifique as permissões do usuário:**
   - O usuário `<usuario>` deve ter privilégios para criar e modificar tabelas no banco `autenticacao_db`

### Executando o Projeto

1. Clone o repositório
2. Navegue até o diretório do serviço:
   ```bash
   cd backend/autenticacao
   ```
3. Execute o projeto:
   ```bash
   mvn spring-boot:run
   ```

O serviço estará disponível em `http://localhost:8081`

### Documentação da API

A documentação interativa da API está disponível através do Swagger UI:

- **Swagger UI**: `http://localhost:8081/swagger-ui.html`
- **OpenAPI JSON**: `http://localhost:8081/api-docs`

### Configurações

As configurações podem ser alteradas no arquivo `application.yml`:

- **Porta**: 8081
- **Database**: PostgreSQL (DB_HOST:DB_PORT/DB_NAME)
- **JWT Secret**: Configurável via variável de ambiente `JWT_SECRET`
- **Token Expiration**: 24 horas
- **Refresh Token Expiration**: 7 dias

## Endpoints da API

### URL Base: `http://localhost:8081/api/auth`

### 1. Registro de Usuário
```http
POST /register
Content-Type: application/json

{
  "email": "usuario@exemplo.com",
  "password": "senha123",
  "name": "Nome do Usuário",
  "userType": "CLIENT"
}
```

**Resposta:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiJ9...",
  "tokenType": "Bearer",
  "userId": 1,
  "email": "usuario@exemplo.com",
  "name": "Nome do Usuário",
  "userType": "CLIENT",
  "expiresIn": 86400000
}
```

### 2. Login
```http
POST /login
Content-Type: application/json

{
  "email": "usuario@exemplo.com",
  "password": "senha123"
}
```

**Resposta:** Mesmo formato do registro

### 3. Validação de Token
```http
POST /validate
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**Resposta:**
```json
{
  "valid": true,
  "userId": 1,
  "userType": "CLIENT"
}
```

### 4. Renovação de Token
```http
POST /refresh
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**Resposta:** Mesmo formato do registro

### 5. Verificação de Saúde
```http
GET /health
```

**Resposta:**
```json
{
  "status": "UP",
  "service": "Authentication Service"
}
```

## Tipos de Usuário

- `CLIENT`: Cliente que faz pedidos
- `DRIVER`: Motorista que realiza entregas

## Estrutura do Token JWT

O token JWT contém as seguintes claims:
- `sub`: Email do usuário
- `userId`: ID do usuário
- `userType`: Tipo do usuário (CLIENT/DRIVER)
- `iat`: Data de criação
- `exp`: Data de expiração

## Tratamento de Erros

O serviço retorna erros no seguinte formato:

```json
{
  "error": "Mensagem de erro",
  "status": "error"
}
```

### Códigos de Status HTTP

- `200`: Sucesso
- `400`: Erro de validação ou dados inválidos
- `401`: Token inválido ou expirado
- `500`: Erro interno do servidor

## Banco de Dados

### PostgreSQL

O serviço utiliza PostgreSQL como banco de dados principal:

- **Host**: localhost
- **Porta**: 5432
- **Database**: autenticacao_db

### Schema

As tabelas são criadas automaticamente pelo Hibernate com a configuração `ddl-auto: create-drop`:

```sql
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    user_type VARCHAR(20) NOT NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);
```

## Segurança

- Senhas são criptografadas usando BCrypt
- Tokens JWT são assinados com HMAC-SHA256
- CORS configurado para permitir requisições cross-origin
- Validação de entrada em todos os endpoints
- Tratamento de exceções global

## Integração com Outros Serviços

Este serviço pode ser integrado com outros microsserviços através do API Gateway. Para validar tokens em outros serviços, use o endpoint `/validate` ou implemente a validação local usando a mesma chave secreta JWT.

## Variáveis de Ambiente

- `JWT_SECRET`: Chave secreta para assinatura dos tokens JWT
- `SERVER_PORT`: Porta do servidor (padrão: 8081)
- `DB_HOST`: Host do banco de dados PostgreSQL
- `DB_USERNAME`: Usuário do banco de dados
- `DB_PASSWORD`: Senha do banco de dados

## Documentação da API

### Swagger UI

Acesse `http://localhost:8081/swagger-ui.html` para visualizar a documentação interativa da API, onde você pode:

- Ver todos os endpoints disponíveis
- Testar as APIs diretamente no navegador
- Visualizar os schemas de request/response
- Ver exemplos de uso
- Autenticar usando JWT tokens

### Especificação OpenAPI

A especificação OpenAPI está disponível em:
- JSON: `http://localhost:8081/api-docs`
- YAML: `http://localhost:8081/api-docs.yaml`