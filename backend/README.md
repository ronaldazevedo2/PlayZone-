# BaseApi — Template Clean Architecture .NET 8 + MySQL

API REST base com Clean Architecture, CQRS (MediatR), JWT, MySQL no Docker.  
Use este projeto como ponto de partida e siga os comentários no código para criar novos CRUDs.

---

## Pré-requisitos

- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [EF Core CLI](https://learn.microsoft.com/ef/core/cli/dotnet): `dotnet tool install --global dotnet-ef`

---

## Como rodar com Docker

```bash
# Na raiz do projeto (onde está o docker-compose.yml)
docker-compose up --build
```

- **Swagger:** http://localhost:5000/swagger
- **MySQL externo (DBeaver/TablePlus):** `localhost:5306` · user: `root` · senha: `BaseApi@2024`

O banco é criado e as migrations aplicadas **automaticamente** na primeira execução.

---

## Como rodar localmente (sem Docker)

```bash
# 1. Suba apenas o MySQL no Docker
docker-compose up mysql -d

# 2. Rode a API localmente
cd src/BaseApi.API
dotnet run
```

Swagger em: http://localhost:5200/swagger

---

## Usuário padrão

| Campo | Valor |
|-------|-------|
| E-mail | admin@baseapi.com |
| Senha | Admin@123 |
| Perfil | Admin |

---

## Perfis de acesso

| Id | Nome | Descrição |
|----|------|-----------|
| 1 | Admin | Acesso total ao sistema |
| 2 | Gerente | Acesso intermediário |
| 3 | Usuário | Acesso básico |

---

## Endpoints de Autenticação

### Login
```http
POST /api/autenticacao/login
Content-Type: application/json

{
  "email": "admin@baseapi.com",
  "senha": "Admin@123"
}
```
Retorna o `accessToken` JWT. Cole no botão **Authorize** do Swagger como `Bearer SEU_TOKEN`.

---

### Esqueceu a Senha
```http
POST /api/autenticacao/esqueceu-senha
Content-Type: application/json

{
  "email": "usuario@exemplo.com"
}
```
Envia e-mail com link de redefinição (válido 2 horas). Configure o Mailtrap para capturar.

---

### Redefinir Senha
```http
POST /api/autenticacao/redefinir-senha
Content-Type: application/json

{
  "token": "TOKEN_DO_EMAIL",
  "novaSenha": "NovaSenha@123",
  "confirmacaoSenha": "NovaSenha@123"
}
```

---

## Configurar Mailtrap (e-mail gratuito para testes)

1. Crie conta gratuita em **https://mailtrap.io**
2. Vá em **Email Testing → My Inbox → SMTP Settings**
3. Selecione **MailKit** no dropdown
4. Copie `Host`, `Port`, `Username` e `Password`
5. Cole no `docker-compose.yml` (variáveis `Email__Smtp__*`) ou em `appsettings.json`

Os e-mails ficam capturados no painel do Mailtrap — **nenhum e-mail real é enviado**.

---

## Estrutura do Projeto

```
src/
├── BaseApi.Domain/           # Entidades, interfaces, enums, exceções
├── BaseApi.Application/      # Casos de uso: Commands, Queries, Validators
├── BaseApi.Infrastructure/   # EF Core, repositórios, email, JWT
└── BaseApi.API/              # Controllers, middlewares, Program.cs
```

### Fluxo de uma requisição

```
HTTP Request
    → Controller
        → IMediator.Send(Command/Query)
            → ValidationBehavior (FluentValidation)
                → Handler
                    → IRepositorio / IServico
                        → AppDbContext (MySQL)
    ← HTTP Response (RespostaApi<T>)
```

---

## Criar um novo CRUD (exemplo: Produto)

Siga os comentários em `UsuariosController.cs`. Em resumo:

1. `BaseApi.Domain` → `Entidades/Produto.cs` + `Interfaces/Repositorios/IProdutoRepositorio.cs`
2. `BaseApi.Application` → `Produtos/Commands/` + `Produtos/Queries/`
3. `BaseApi.Infrastructure` → `Dados/Configuracoes/ProdutoConfiguracao.cs` + `Repositorios/ProdutoRepositorio.cs`
4. `BaseApi.API` → `Controllers/ProdutosController.cs`
5. Criar migration: `dotnet ef migrations add AdicionarProduto --project src/BaseApi.Infrastructure --startup-project src/BaseApi.API --output-dir Dados/Migrations`

---

## Comandos EF Core úteis

```bash
# Criar nova migration
dotnet ef migrations add NomeDaMigration \
  --project src/BaseApi.Infrastructure \
  --startup-project src/BaseApi.API \
  --output-dir Dados/Migrations

# Remover última migration
dotnet ef migrations remove \
  --project src/BaseApi.Infrastructure \
  --startup-project src/BaseApi.API

# Aplicar manualmente (sem docker)
dotnet ef database update \
  --project src/BaseApi.Infrastructure \
  --startup-project src/BaseApi.API
```
