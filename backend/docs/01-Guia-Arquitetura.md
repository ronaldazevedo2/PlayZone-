# 📐 Guia de Arquitetura — BaseApi

> **Para quem é este guia?**  
> Para iniciantes que estão abrindo este projeto pela primeira vez e querem entender **por que** cada pasta existe e **como as peças se encaixam**.

---

## O que é Arquitetura Limpa?

Imagine que você tem uma casa. Ela tem cômodos separados com funções bem definidas:
- **Cozinha** → prepara a comida
- **Sala** → recebe visitas
- **Quarto** → descansa
- **Garagem** → guarda o carro

Cada cômodo tem uma responsabilidade. A garagem não prepara comida, e a cozinha não guarda carros.

**Arquitetura Limpa** funciona assim com código. Cada "camada" (pasta de projeto) tem uma responsabilidade específica e regras claras sobre **quem pode falar com quem**.

---

## Os 4 projetos da solução

```
BaseApi.sln
├── BaseApi.Domain          ← O coração do sistema (regras de negócio)
├── BaseApi.Application     ← O cérebro (casos de uso)
├── BaseApi.Infrastructure  ← Os braços (banco de dados, e-mail, etc.)
└── BaseApi.API             ← A porta de entrada (o que o mundo de fora vê)
```

Pense assim: as dependências só andam **de fora para dentro**. A API conhece a Application, que conhece o Domain. Mas o Domain **não conhece ninguém** — ele é o mais independente de todos.

```
API → Application → Domain
Infrastructure → Domain
Infrastructure → Application
```

---

## 📦 BaseApi.Domain — "O Coração"

**Responsabilidade:** Define o que o sistema **É**. Entidades, regras fundamentais, contratos (interfaces).

**Regra de ouro:** Esta camada **não depende de ninguém**. Ela não sabe que existe banco de dados, API, e-mail. Só sabe de negócio.

```
BaseApi.Domain/
├── Entidades/
│   ├── Usuario.cs       ← Representa um usuário (campos, dados)
│   └── Perfil.cs        ← Representa um perfil de acesso
├── Interfaces/
│   ├── Repositorios/
│   │   ├── IUsuarioRepositorio.cs   ← Contrato: "preciso buscar usuários"
│   │   └── IPerfilRepositorio.cs
│   └── Servicos/
│       ├── IEmailServico.cs         ← Contrato: "preciso enviar e-mails"
│       ├── ITokenServico.cs         ← Contrato: "preciso gerar tokens JWT"
│       └── ISenhaServico.cs         ← Contrato: "preciso fazer hash de senha"
├── Enums/
│   └── NomePerfil.cs    ← Constantes: "Admin", "Gerente", "Usuário"
└── Excecoes/
    └── ExcecaoDominio.cs ← Erros de regra de negócio
```

### O que é uma Entidade?

É uma classe que representa um objeto do mundo real no seu sistema.

```csharp
// Usuario.cs — representa um usuário do sistema
public class Usuario
{
    public Guid Id { get; set; }         // Identificador único
    public string NomeCompleto { get; set; }
    public string Email { get; set; }
    public string SenhaHash { get; set; } // ← Nunca salva senha em texto puro!
    public int PerfilId { get; set; }    // Qual perfil este usuário tem?
    public bool Ativo { get; set; }
}
```

### O que é uma Interface?

É um "contrato" que diz **o que** precisa ser feito, mas não **como**. 

Pense assim: a Interface é a tomada da parede. Ela define o formato (2 pinos, 3 pinos). O aparelho (implementação) é o carregador. A tomada não sabe se é um carregador de iPhone ou Android — só sabe o formato.

```csharp
// IUsuarioRepositorio.cs — "contrato" do repositório
public interface IUsuarioRepositorio
{
    Task<Usuario?> ObterPorIdAsync(Guid id, CancellationToken ct);
    Task<Usuario?> ObterPorEmailAsync(string email, CancellationToken ct);
    Task AdicionarAsync(Usuario usuario, CancellationToken ct);
    Task SalvarAsync(CancellationToken ct);
    // ...
}
```

Quem vai implementar este contrato? A camada Infrastructure! O Domain só define o que precisa.

---

## 🧠 BaseApi.Application — "O Cérebro"

**Responsabilidade:** Define o que o sistema **FAZ**. Cada caso de uso (ação do usuário) vira um Command ou Query.

**Padrão usado: CQRS**  
- **Command** → muda dados (criar, atualizar, deletar)
- **Query** → lê dados (buscar, listar)

```
BaseApi.Application/
├── Autenticacao/
│   └── Commands/
│       ├── Login/              ← Fazer login
│       ├── EsqueceuSenha/      ← Solicitar recuperação de senha
│       └── RedefinirSenha/     ← Trocar a senha
├── Usuarios/
│   ├── Commands/
│   │   ├── CriarUsuario/       ← Criar novo usuário
│   │   ├── AtualizarUsuario/   ← Editar usuário
│   │   └── ExcluirUsuario/     ← Remover usuário
│   └── Queries/
│       ├── ObterUsuarioPorId/  ← Buscar 1 usuário
│       └── ListarUsuarios/     ← Listar todos
└── Comum/
    ├── Comportamentos/
    │   └── ValidationBehavior.cs  ← Valida automaticamente antes de executar
    ├── Modelos/
    │   ├── RespostaApi.cs         ← Formato padrão de resposta
    │   └── ResultadoPaginado.cs   ← Modelo de lista paginada
    └── Mapeamentos/
        └── UsuarioMapeamento.cs   ← Converte Entidade → DTO
```

### Como funciona o MediatR?

É o "carteiro" do sistema. Você envia uma carta (Command/Query), e ele entrega para o destinatário certo (Handler), sem que o remetente saiba quem vai receber.

```
Controller → mediator.Send(CriarUsuarioCommand)
                          ↓
                   [MediatR encontra o Handler]
                          ↓
             CriarUsuarioHandler.Handle(command)
```

### Anatomia de um Command

Cada caso de uso tem geralmente 3 arquivos:

**1. Command** — o "formulário" com os dados da ação
```csharp
// CriarUsuarioCommand.cs
public record CriarUsuarioCommand(
    string NomeCompleto,
    string Email,
    string Senha,
    int PerfilId
) : IRequest<CriarUsuarioResposta>; // ← "quero uma resposta deste tipo"
```

**2. Validator** — as regras de validação (executadas automaticamente)
```csharp
// CriarUsuarioValidator.cs
public class CriarUsuarioValidator : AbstractValidator<CriarUsuarioCommand>
{
    public CriarUsuarioValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("E-mail é obrigatório.")
            .EmailAddress().WithMessage("E-mail inválido.");
        // ...
    }
}
```

**3. Handler** — a lógica de negócio de verdade
```csharp
// CriarUsuarioHandler.cs
public class CriarUsuarioHandler : IRequestHandler<CriarUsuarioCommand, CriarUsuarioResposta>
{
    public async Task<CriarUsuarioResposta> Handle(CriarUsuarioCommand command, CancellationToken ct)
    {
        // Aqui fica o código que realmente cria o usuário
    }
}
```

### O que é um DTO?

DTO = Data Transfer Object. É um objeto que carrega dados entre camadas, sem ser a entidade do banco.

Por que usar DTO e não a entidade direto?
- A entidade `Usuario` tem `SenhaHash` — você jamais quer retornar isso para o cliente!
- O DTO `UsuarioDetalheDto` só tem os campos seguros para mostrar.

```csharp
// Entidade (vai pro banco):        DTO (vai pro cliente):
public class Usuario               public record UsuarioDetalheDto(
{                                      Guid Id,
    public Guid Id { get; set; }       string NomeCompleto,
    public string SenhaHash { get; }   string Email,
    // ...                             string NomePerfil,  ← nome, não o id!
}                                      bool Ativo
                                   );
```

---

## 🔧 BaseApi.Infrastructure — "Os Braços"

**Responsabilidade:** Implementa os contratos definidos no Domain. É aqui que o código "suja as mãos" com tecnologias específicas: banco de dados, e-mail, JWT.

```
BaseApi.Infrastructure/
├── Dados/
│   ├── AppDbContext.cs              ← Conexão com o banco (EF Core)
│   ├── AppDbContextFactory.cs       ← Usado só para criar migrations
│   ├── Migrations/                  ← Histórico de mudanças no banco (gerado automaticamente)
│   └── Configuracoes/
│       ├── UsuarioConfiguracao.cs   ← Define tabela/colunas da entidade Usuario
│       └── PerfilConfiguracao.cs    ← Define tabela/colunas da entidade Perfil
├── Repositorios/
│   ├── UsuarioRepositorio.cs        ← Implementa IUsuarioRepositorio usando EF Core
│   └── PerfilRepositorio.cs
└── Servicos/
    ├── TokenServico.cs              ← Gera tokens JWT
    ├── EmailServico.cs              ← Envia e-mails via SMTP (Mailtrap)
    └── SenhaServico.cs              ← Hash e verificação de senha (BCrypt)
```

### O que é o AppDbContext?

É a "janela" para o banco de dados. Você não escreve SQL — o EF Core traduz suas consultas C# para SQL automaticamente.

```csharp
// Exemplo de como o EF Core funciona:
// C#:  await contexto.Usuarios.Where(u => u.Ativo).ToListAsync()
// SQL: SELECT * FROM usuarios WHERE ativo = 1
```

### O que são Migrations?

São o "histórico de versões" do banco de dados. Cada vez que você muda uma entidade, cria uma migration que registra o que mudou e atualiza o banco.

```bash
# Criar migration (após mudar uma entidade):
dotnet ef migrations add AdicionarCampoCpf \
  --project src/BaseApi.Infrastructure \
  --startup-project src/BaseApi.API \
  --output-dir Dados/Migrations
```

O sistema aplica as migrations **automaticamente** ao iniciar (via `db.Database.MigrateAsync()` no `Program.cs`).

---

## 🚪 BaseApi.API — "A Porta de Entrada"

**Responsabilidade:** Recebe as requisições HTTP, delega para a Application e retorna respostas.

```
BaseApi.API/
├── Controllers/
│   ├── AutenticacaoController.cs  ← /api/autenticacao/*
│   ├── UsuariosController.cs      ← /api/usuarios/*
│   └── PerfisController.cs        ← /api/perfis
├── Middlewares/
│   └── ExcecaoMiddleware.cs       ← Captura erros e retorna JSON padrão
├── Program.cs                     ← Configuração geral da aplicação
└── appsettings.json               ← Configurações (banco, JWT, e-mail)
```

### O que é um Controller?

É o "atendente de balcão". Recebe o pedido do cliente, passa para o "cozinheiro" (Application) e devolve o resultado.

```csharp
[HttpPost]                          // ← método HTTP
[Route("/api/usuarios")]            // ← URL
public async Task<IActionResult> Criar([FromBody] CriarUsuarioCommand command)
{
    var resultado = await mediator.Send(command); // ← passa pro MediatR
    return Created(..., RespostaApi<...>.Sucesso(resultado));
}
```

### O que é o Middleware de Exceção?

Fica na "fila de processamento" de toda requisição. Se qualquer erro acontecer, ele intercepta e formata a resposta:

```
Requisição → [ExcecaoMiddleware] → Controller → Application → Infrastructure
                   ↑                                                ↓
              Se der erro,                               Lança Exceção
              captura aqui
              e retorna JSON
```

---

## 🔐 Como funciona a Autenticação JWT?

**JWT** (JSON Web Token) é como um "crachá digital". Após o login, o servidor emite um crachá com suas informações. Em cada requisição você apresenta o crachá — sem precisar fazer login novamente.

### Fluxo completo:

```
1. Cliente → POST /api/autenticacao/login { email, senha }
2. Servidor → valida credenciais → gera token JWT
3. Servidor → retorna { accessToken: "eyJhbGci..." }

4. Cliente → GET /api/usuarios (com header: Authorization: Bearer eyJhbGci...)
5. Servidor → valida o token → permite acesso
```

### O que tem dentro do token?

O token JWT contém "claims" (informações sobre o usuário):

```
{
  "sub": "guid-do-usuario",
  "email": "admin@baseapi.com",
  "name": "Administrador do Sistema",
  "role": "Admin",
  "exp": 1234567890   ← data de expiração
}
```

O servidor usa o `role` para decidir se o usuário pode acessar um endpoint com `[Authorize(Roles = "Admin")]`.

---

## 📊 Diagrama do Fluxo Completo

```
┌─────────────────────────────────────────────────────────────┐
│                        HTTP Request                          │
│              POST /api/usuarios { nome, email... }           │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────┐
│  ExcecaoMiddleware  (captura qualquer erro que acontecer)     │
└──────────────────────────────┬───────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────┐
│  UsuariosController.Criar()                                   │
│  → mediator.Send(CriarUsuarioCommand)                         │
└──────────────────────────────┬───────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────┐
│  ValidationBehavior                                           │
│  → CriarUsuarioValidator (valida campos)                      │
│  → Se inválido: lança ValidationException → HTTP 400         │
└──────────────────────────────┬───────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────┐
│  CriarUsuarioHandler.Handle()                                 │
│  → Aplica regras de negócio                                   │
│  → repositorio.AdicionarAsync(usuario)                        │
│  → repositorio.SalvarAsync()                                  │
└──────────────────────────────┬───────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────┐
│  UsuarioRepositorio (Infrastructure)                          │
│  → contexto.Usuarios.AddAsync(usuario)                        │
│  → contexto.SaveChangesAsync()                                │
└──────────────────────────────┬───────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────┐
│                      MySQL (Docker)                           │
│              INSERT INTO usuarios VALUES (...)                │
└──────────────────────────────┬───────────────────────────────┘
                               │
                       (resposta sobe)
                               │
                               ▼
┌──────────────────────────────────────────────────────────────┐
│  HTTP Response 201 Created                                    │
│  { "ok": true, "dados": { "id": "...", "email": "..." } }    │
└──────────────────────────────────────────────────────────────┘
```

---

## 📝 Formato Padrão de Resposta

Toda resposta da API usa o modelo `RespostaApi<T>`:

```json
// Sucesso:
{
  "ok": true,
  "mensagem": "Usuário criado com sucesso!",
  "dados": {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "nomeCompleto": "João Silva",
    "email": "joao@exemplo.com"
  },
  "erros": null
}

// Erro de validação:
{
  "ok": false,
  "mensagem": "Erro de validação.",
  "dados": null,
  "erros": [
    "E-mail é obrigatório.",
    "Senha deve ter no mínimo 8 caracteres."
  ]
}
```

---

## 🏁 Resumo Final

| Camada | O que faz | Tecnologias |
|--------|-----------|-------------|
| **Domain** | Define entidades e contratos | Só C# puro |
| **Application** | Implementa casos de uso (CQRS) | MediatR, FluentValidation, Mapster |
| **Infrastructure** | Acessa banco, e-mail, JWT | EF Core, MySQL, MailKit, BCrypt |
| **API** | Recebe requisições HTTP | ASP.NET Core, Swagger/JWT |

**Regra de dependência:** Setas sempre apontam para dentro (Domain nunca depende de ninguém).

```
API ──────────────────────→ Application ──────→ Domain
Infrastructure ──────────────────────────────→ Domain
Infrastructure ─────────────────→ Application
```

Pronto! Agora você sabe como o projeto está organizado. No próximo guia, vamos colocar a mão na massa e criar um CRUD completo do zero! 🚀
