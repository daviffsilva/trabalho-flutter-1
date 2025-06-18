# API Gateway

Micro-serviço responsável pelo roteamento centralizado, autenticação e autorização das requisições para os microsserviços do sistema de entregas.

## Funcionalidades

- Roteamento de requisições para microsserviços (autenticação, pedidos, rastreamento)
- Validação de tokens JWT em todas as requisições protegidas
- Suporte a CORS
- Documentação interativa da API com Swagger UI

## Tecnologias Utilizadas

- Spring Boot 3.2.0
- Spring Cloud Gateway
- Spring Security
- SpringDoc OpenAPI (Swagger)
- Maven

## Configuração e Execução

### Pré-requisitos

- Java 17 ou superior
- Maven 3.6 ou superior

### Executando o Projeto

1. Clone o repositório
2. Navegue até o diretório do gateway:
   ```bash
   cd backend/gateway
   ```
3. Execute o projeto:
   ```bash
   mvn spring-boot:run
   ```

O gateway estará disponível em `http://localhost:8080`

### Configurações

As configurações podem ser alteradas no arquivo `application.yml`:

- **Porta**: 8080
- **Roteamento**: URLs dos microsserviços
- **JWT Secret**: Configurável via variável de ambiente `JWT_SECRET`

## Segurança

- Todas as rotas protegidas exigem token JWT válido
- CORS configurado para permitir requisições cross-origin
- Documentação Swagger acessível sem autenticação

## Documentação da API

- **Swagger UI**: `http://localhost:8080/swagger-ui.html`
- **OpenAPI JSON**: `http://localhost:8080/api-docs`

## Variáveis de Ambiente

- `SERVER_PORT`: Porta do gateway (padrão: 8080)
- URLs dos microsserviços (ex: `AUTH_SERVICE_URL`, `PEDIDOS_SERVICE_URL`, `RASTREAMENTO_SERVICE_URL`)
