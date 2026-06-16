# 🛠️ Guia: Como Criar um Novo Recurso (CRUD)

> **Exemplo prático:** Vamos criar do zero um CRUD de **Telefones** — como se fosse um catálogo de aparelhos celulares.  
> Ao final você vai ter: listar, buscar por ID, criar, editar e deletar telefones, com tudo validado e protegido por perfil.

---

## Antes de começar: entenda o checklist

Criar um novo recurso sempre segue a **mesma sequência de 10 passos**, sempre da camada mais interna para a mais externa:

```
Passo 1  → Domain:         Criar a Entidade
Passo 2  → Domain:         Criar a Interface do Repositório
Passo 3  → Infrastructure: Configurar o mapeamento da tabela (Fluent API)
Passo 4  → Infrastructure: Implementar o Repositório
Passo 5  → Infrastructure: Registrar no DependencyInjection
Passo 6  → Application:    Criar Commands (criar, atualizar, deletar)
Passo 7  → Application:    Criar Queries (buscar, listar)
Passo 8  → Infrastructure: Criar a Migration do banco
Passo 9  → API:            Criar o Controller
Passo 10 → Testar no Swagger
```

Vamos executar cada passo agora.

---

## O recurso que vamos criar

**Telefone** — um catálogo de aparelhos celulares com os campos:

| Campo | Tipo | Descrição |
|-------|------|-----------|
| Id | Guid | Identificador único |
| Marca | string | Ex: Samsung, Apple |
| Modelo | string | Ex: Galaxy S24, iPhone 15 |
| Preco | decimal | Preço de venda |
| Estoque | int | Quantidade disponível |
| Ativo | bool | Se está disponível |
| CriadoEm | DateTime | Data de cadastro |

---

## Passo 1 — Criar a Entidade (Domain)

📁 Crie o arquivo: `src/BaseApi.Domain/Entidades/Telefone.cs`

```csharp
namespace BaseApi.Domain.Entidades;

/// <summary>
/// Entidade que representa um aparelho de telefone no catálogo.
/// </summary>
public class Telefone
{
    public Guid Id { get; set; } = Guid.NewGuid();

    /// <summary>Marca do aparelho. Ex: Samsung, Apple, Motorola</summary>
    public string Marca { get; set; } = string.Empty;

    /// <summary>Modelo do aparelho. Ex: Galaxy S24, iPhone 15</summary>
    public string Modelo { get; set; } = string.Empty;

    public decimal Preco { get; set; }

    public int Estoque { get; set; }

    public bool Ativo { get; set; } = true;

    public DateTime CriadoEm { get; set; } = DateTime.UtcNow;

    public DateTime AtualizadoEm { get; set; } = DateTime.UtcNow;
}
```

> ✅ **Por que aqui?** O Domain define o que o sistema É. A entidade `Telefone` representa o objeto do mundo real.

---

## Passo 2 — Criar a Interface do Repositório (Domain)

📁 Crie o arquivo: `src/BaseApi.Domain/Interfaces/Repositorios/ITelefoneRepositorio.cs`

```csharp
using BaseApi.Domain.Entidades;

namespace BaseApi.Domain.Interfaces.Repositorios;

/// <summary>
/// Contrato das operações de persistência de Telefone.
/// O Domain apenas define o contrato — a Infrastructure implementa.
/// </summary>
public interface ITelefoneRepositorio
{
    Task<Telefone?> ObterPorIdAsync(Guid id, CancellationToken ct = default);

    Task<(IEnumerable<Telefone> Itens, int Total)> ListarAsync(
        int pagina,
        int tamanhoPagina,
        string? busca,
        CancellationToken ct = default);

    Task AdicionarAsync(Telefone telefone, CancellationToken ct = default);

    void Atualizar(Telefone telefone);

    void Remover(Telefone telefone);

    Task SalvarAsync(CancellationToken ct = default);
}
```

> ✅ **Por que interface aqui?** O Domain diz "preciso de um repositório de Telefones" sem se importar como é implementado. Isso permite trocar o banco de dados sem mudar regras de negócio.

---

## Passo 3 — Configurar o Mapeamento da Tabela (Infrastructure)

📁 Crie o arquivo: `src/BaseApi.Infrastructure/Dados/Configuracoes/TelefoneConfiguracao.cs`

```csharp
using BaseApi.Domain.Entidades;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BaseApi.Infrastructure.Dados.Configuracoes;

/// <summary>
/// Define como a entidade Telefone é mapeada no banco de dados.
/// Aqui você define o nome da tabela, tamanhos, índices, etc.
/// </summary>
public class TelefoneConfiguracao : IEntityTypeConfiguration<Telefone>
{
    public void Configure(EntityTypeBuilder<Telefone> builder)
    {
        // Nome da tabela no banco
        builder.ToTable("telefones");

        // Chave primária
        builder.HasKey(t => t.Id);

        // Configuração das colunas
        builder.Property(t => t.Marca)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(t => t.Modelo)
            .IsRequired()
            .HasMaxLength(150);

        builder.Property(t => t.Preco)
            .HasColumnType("decimal(10,2)"); // 10 dígitos, 2 casas decimais

        builder.Property(t => t.Estoque)
            .IsRequired();

        // Índice para busca rápida por marca
        builder.HasIndex(t => t.Marca);
    }
}
```

> ✅ **Por que aqui?** A Infrastructure é responsável por "como" os dados são salvos. O EF Core vai usar esta classe para criar a tabela no MySQL.  
> 💡 **Não precisa registrar** — o `AppDbContext` usa `ApplyConfigurationsFromAssembly` e detecta automaticamente.

---

## Passo 3.1 — Adicionar o DbSet no AppDbContext

📁 Abra: `src/BaseApi.Infrastructure/Dados/AppDbContext.cs`

Adicione a linha do `DbSet`:

```csharp
public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<Usuario> Usuarios => Set<Usuario>();
    public DbSet<Perfil> Perfis => Set<Perfil>();
    public DbSet<Telefone> Telefones => Set<Telefone>(); // ← ADICIONE ESTA LINHA
```

> ✅ **Por que?** O `DbSet` é o que permite fazer `contexto.Telefones.ToListAsync()`. Sem ele, o EF Core não sabe que a entidade existe.

---

## Passo 4 — Implementar o Repositório (Infrastructure)

📁 Crie o arquivo: `src/BaseApi.Infrastructure/Repositorios/TelefoneRepositorio.cs`

```csharp
using BaseApi.Domain.Entidades;
using BaseApi.Domain.Interfaces.Repositorios;
using BaseApi.Infrastructure.Dados;
using Microsoft.EntityFrameworkCore;

namespace BaseApi.Infrastructure.Repositorios;

/// <summary>
/// Implementação do repositório de Telefones usando Entity Framework Core.
/// Esta classe implementa o contrato ITelefoneRepositorio definido no Domain.
/// </summary>
public class TelefoneRepositorio(AppDbContext contexto) : ITelefoneRepositorio
{
    public async Task<Telefone?> ObterPorIdAsync(Guid id, CancellationToken ct = default)
        => await contexto.Telefones
            .FirstOrDefaultAsync(t => t.Id == id, ct);

    public async Task<(IEnumerable<Telefone> Itens, int Total)> ListarAsync(
        int pagina, int tamanhoPagina, string? busca, CancellationToken ct = default)
    {
        var query = contexto.Telefones
            .AsNoTracking(); // AsNoTracking = mais performance para leitura

        // Filtro de busca por marca ou modelo
        if (!string.IsNullOrWhiteSpace(busca))
        {
            busca = busca.ToLower();
            query = query.Where(t =>
                t.Marca.ToLower().Contains(busca) ||
                t.Modelo.ToLower().Contains(busca));
        }

        var total = await query.CountAsync(ct);
        var itens = await query
            .OrderBy(t => t.Marca).ThenBy(t => t.Modelo)
            .Skip((pagina - 1) * tamanhoPagina)
            .Take(tamanhoPagina)
            .ToListAsync(ct);

        return (itens, total);
    }

    public async Task AdicionarAsync(Telefone telefone, CancellationToken ct = default)
        => await contexto.Telefones.AddAsync(telefone, ct);

    public void Atualizar(Telefone telefone)
        => contexto.Telefones.Update(telefone);

    public void Remover(Telefone telefone)
        => contexto.Telefones.Remove(telefone);

    public async Task SalvarAsync(CancellationToken ct = default)
        => await contexto.SaveChangesAsync(ct);
}
```

---

## Passo 5 — Registrar no DependencyInjection (Infrastructure)

📁 Abra: `src/BaseApi.Infrastructure/DependencyInjection.cs`

Adicione o registro do repositório:

```csharp
// Repositórios
services.AddScoped<IUsuarioRepositorio, UsuarioRepositorio>();
services.AddScoped<IPerfilRepositorio, PerfilRepositorio>();
services.AddScoped<ITelefoneRepositorio, TelefoneRepositorio>(); // ← ADICIONE ESTA LINHA
```

> ✅ **Por que?** Isso ensina ao .NET que quando alguém pedir um `ITelefoneRepositorio`, ele deve criar um `TelefoneRepositorio`. É a "ligação" entre a interface e a implementação.  
> 💡 `AddScoped` = uma instância por requisição HTTP. Ideal para repositórios.

---

## Passo 6 — Criar os Commands (Application)

Vamos criar 3 commands: **Criar**, **Atualizar** e **Excluir**.

### 6.1 — CriarTelefone

📁 Crie a pasta: `src/BaseApi.Application/Telefones/Commands/CriarTelefone/`

**Arquivo: `CriarTelefoneCommand.cs`**
```csharp
using MediatR;

namespace BaseApi.Application.Telefones.Commands.CriarTelefone;

/// <summary>
/// Command para criar um novo telefone no catálogo.
/// "record" é imutável — ideal para Commands (não muda depois de criado).
/// </summary>
public record CriarTelefoneCommand(
    string Marca,
    string Modelo,
    decimal Preco,
    int Estoque
) : IRequest<CriarTelefoneResposta>;

/// <summary>Dados retornados após criação bem-sucedida</summary>
public record CriarTelefoneResposta(Guid Id, string Marca, string Modelo, decimal Preco);
```

**Arquivo: `CriarTelefoneValidator.cs`**
```csharp
using FluentValidation;

namespace BaseApi.Application.Telefones.Commands.CriarTelefone;

/// <summary>
/// Validações executadas automaticamente antes do Handler.
/// Se qualquer regra falhar, retorna HTTP 400 com as mensagens.
/// </summary>
public class CriarTelefoneValidator : AbstractValidator<CriarTelefoneCommand>
{
    public CriarTelefoneValidator()
    {
        RuleFor(x => x.Marca)
            .NotEmpty().WithMessage("Marca é obrigatória.")
            .MaximumLength(100).WithMessage("Marca deve ter no máximo 100 caracteres.");

        RuleFor(x => x.Modelo)
            .NotEmpty().WithMessage("Modelo é obrigatório.")
            .MaximumLength(150).WithMessage("Modelo deve ter no máximo 150 caracteres.");

        RuleFor(x => x.Preco)
            .GreaterThan(0).WithMessage("Preço deve ser maior que zero.");

        RuleFor(x => x.Estoque)
            .GreaterThanOrEqualTo(0).WithMessage("Estoque não pode ser negativo.");
    }
}
```

**Arquivo: `CriarTelefoneHandler.cs`**
```csharp
using BaseApi.Domain.Entidades;
using BaseApi.Domain.Interfaces.Repositorios;
using MediatR;

namespace BaseApi.Application.Telefones.Commands.CriarTelefone;

/// <summary>
/// Handler que contém a lógica de negócio para criar um telefone.
/// Só é executado se o Validator passar sem erros.
/// </summary>
public class CriarTelefoneHandler(ITelefoneRepositorio repositorio)
    : IRequestHandler<CriarTelefoneCommand, CriarTelefoneResposta>
{
    public async Task<CriarTelefoneResposta> Handle(CriarTelefoneCommand command, CancellationToken ct)
    {
        var telefone = new Telefone
        {
            Marca = command.Marca.Trim(),
            Modelo = command.Modelo.Trim(),
            Preco = command.Preco,
            Estoque = command.Estoque,
            Ativo = true,
            CriadoEm = DateTime.UtcNow,
            AtualizadoEm = DateTime.UtcNow
        };

        await repositorio.AdicionarAsync(telefone, ct);
        await repositorio.SalvarAsync(ct);

        return new CriarTelefoneResposta(telefone.Id, telefone.Marca, telefone.Modelo, telefone.Preco);
    }
}
```

---

### 6.2 — AtualizarTelefone

📁 Crie a pasta: `src/BaseApi.Application/Telefones/Commands/AtualizarTelefone/`

**Arquivo: `AtualizarTelefoneCommand.cs`**
```csharp
using MediatR;

namespace BaseApi.Application.Telefones.Commands.AtualizarTelefone;

public record AtualizarTelefoneCommand(
    Guid Id,
    string Marca,
    string Modelo,
    decimal Preco,
    int Estoque,
    bool Ativo
) : IRequest<Unit>;
```

**Arquivo: `AtualizarTelefoneValidator.cs`**
```csharp
using FluentValidation;

namespace BaseApi.Application.Telefones.Commands.AtualizarTelefone;

public class AtualizarTelefoneValidator : AbstractValidator<AtualizarTelefoneCommand>
{
    public AtualizarTelefoneValidator()
    {
        RuleFor(x => x.Id)
            .NotEmpty().WithMessage("Id do telefone é obrigatório.");

        RuleFor(x => x.Marca)
            .NotEmpty().WithMessage("Marca é obrigatória.")
            .MaximumLength(100).WithMessage("Marca deve ter no máximo 100 caracteres.");

        RuleFor(x => x.Modelo)
            .NotEmpty().WithMessage("Modelo é obrigatório.")
            .MaximumLength(150).WithMessage("Modelo deve ter no máximo 150 caracteres.");

        RuleFor(x => x.Preco)
            .GreaterThan(0).WithMessage("Preço deve ser maior que zero.");

        RuleFor(x => x.Estoque)
            .GreaterThanOrEqualTo(0).WithMessage("Estoque não pode ser negativo.");
    }
}
```

**Arquivo: `AtualizarTelefoneHandler.cs`**
```csharp
using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using MediatR;

namespace BaseApi.Application.Telefones.Commands.AtualizarTelefone;

public class AtualizarTelefoneHandler(ITelefoneRepositorio repositorio)
    : IRequestHandler<AtualizarTelefoneCommand, Unit>
{
    public async Task<Unit> Handle(AtualizarTelefoneCommand command, CancellationToken ct)
    {
        var telefone = await repositorio.ObterPorIdAsync(command.Id, ct)
            ?? throw new ExcecaoNaoEncontrado($"Telefone com Id '{command.Id}' não encontrado.");

        // Atualiza apenas os campos permitidos
        telefone.Marca = command.Marca.Trim();
        telefone.Modelo = command.Modelo.Trim();
        telefone.Preco = command.Preco;
        telefone.Estoque = command.Estoque;
        telefone.Ativo = command.Ativo;
        telefone.AtualizadoEm = DateTime.UtcNow;

        repositorio.Atualizar(telefone);
        await repositorio.SalvarAsync(ct);

        return Unit.Value;
    }
}
```

---

### 6.3 — ExcluirTelefone

📁 Crie a pasta: `src/BaseApi.Application/Telefones/Commands/ExcluirTelefone/`

**Arquivo: `ExcluirTelefoneCommand.cs`**
```csharp
using MediatR;

namespace BaseApi.Application.Telefones.Commands.ExcluirTelefone;

public record ExcluirTelefoneCommand(Guid Id) : IRequest<Unit>;
```

**Arquivo: `ExcluirTelefoneHandler.cs`**
```csharp
using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using MediatR;

namespace BaseApi.Application.Telefones.Commands.ExcluirTelefone;

public class ExcluirTelefoneHandler(ITelefoneRepositorio repositorio)
    : IRequestHandler<ExcluirTelefoneCommand, Unit>
{
    public async Task<Unit> Handle(ExcluirTelefoneCommand command, CancellationToken ct)
    {
        var telefone = await repositorio.ObterPorIdAsync(command.Id, ct)
            ?? throw new ExcecaoNaoEncontrado($"Telefone com Id '{command.Id}' não encontrado.");

        repositorio.Remover(telefone);
        await repositorio.SalvarAsync(ct);

        return Unit.Value;
    }
}
```

---

## Passo 7 — Criar as Queries (Application)

### 7.1 — ObterTelefonePorId

📁 Crie a pasta: `src/BaseApi.Application/Telefones/Queries/ObterTelefonePorId/`

**Arquivo: `ObterTelefonePorIdQuery.cs`**
```csharp
using MediatR;

namespace BaseApi.Application.Telefones.Queries.ObterTelefonePorId;

/// <summary>
/// Query para buscar um único telefone pelo Id.
/// Queries NUNCA alteram dados — apenas leem.
/// </summary>
public record ObterTelefonePorIdQuery(Guid Id) : IRequest<TelefoneDetalheDto>;

/// <summary>DTO com todos os dados do telefone para exibição</summary>
public record TelefoneDetalheDto(
    Guid Id,
    string Marca,
    string Modelo,
    decimal Preco,
    int Estoque,
    bool Ativo,
    DateTime CriadoEm
);
```

**Arquivo: `ObterTelefonePorIdHandler.cs`**
```csharp
using BaseApi.Domain.Excecoes;
using BaseApi.Domain.Interfaces.Repositorios;
using Mapster;
using MediatR;

namespace BaseApi.Application.Telefones.Queries.ObterTelefonePorId;

public class ObterTelefonePorIdHandler(ITelefoneRepositorio repositorio)
    : IRequestHandler<ObterTelefonePorIdQuery, TelefoneDetalheDto>
{
    public async Task<TelefoneDetalheDto> Handle(ObterTelefonePorIdQuery query, CancellationToken ct)
    {
        var telefone = await repositorio.ObterPorIdAsync(query.Id, ct)
            ?? throw new ExcecaoNaoEncontrado($"Telefone com Id '{query.Id}' não encontrado.");

        // Mapster converte a entidade para o DTO automaticamente
        return telefone.Adapt<TelefoneDetalheDto>();
    }
}
```

---

### 7.2 — ListarTelefones

📁 Crie a pasta: `src/BaseApi.Application/Telefones/Queries/ListarTelefones/`

**Arquivo: `ListarTelefonesQuery.cs`**
```csharp
using BaseApi.Application.Comum.Modelos;
using MediatR;

namespace BaseApi.Application.Telefones.Queries.ListarTelefones;

/// <summary>
/// Query para listar telefones com paginação e busca por marca/modelo.
/// </summary>
public record ListarTelefonesQuery(
    int Pagina = 1,
    int TamanhoPagina = 10,
    string? Busca = null
) : IRequest<ResultadoPaginado<TelefoneListaDto>>;

/// <summary>DTO resumido para listagem</summary>
public record TelefoneListaDto(
    Guid Id,
    string Marca,
    string Modelo,
    decimal Preco,
    int Estoque,
    bool Ativo
);
```

**Arquivo: `ListarTelefonesHandler.cs`**
```csharp
using BaseApi.Application.Comum.Modelos;
using BaseApi.Domain.Interfaces.Repositorios;
using Mapster;
using MediatR;

namespace BaseApi.Application.Telefones.Queries.ListarTelefones;

public class ListarTelefonesHandler(ITelefoneRepositorio repositorio)
    : IRequestHandler<ListarTelefonesQuery, ResultadoPaginado<TelefoneListaDto>>
{
    public async Task<ResultadoPaginado<TelefoneListaDto>> Handle(ListarTelefonesQuery query, CancellationToken ct)
    {
        var (itens, total) = await repositorio.ListarAsync(query.Pagina, query.TamanhoPagina, query.Busca, ct);

        return new ResultadoPaginado<TelefoneListaDto>
        {
            Itens = itens.Adapt<IEnumerable<TelefoneListaDto>>(),
            Total = total,
            Pagina = query.Pagina,
            TamanhoPagina = query.TamanhoPagina
        };
    }
}
```

---

## Passo 8 — Criar a Migration do Banco

Agora que criamos a entidade e o mapeamento, precisamos atualizar o banco de dados.

Abra o **Terminal** (no Visual Studio: `Ferramentas → Terminal do Pacote NuGet` ou o terminal externo) e execute **na raiz da solução**:

```bash
dotnet ef migrations add AdicionarTelefones \
  --project src/BaseApi.Infrastructure \
  --startup-project src/BaseApi.API \
  --output-dir Dados/Migrations
```

Isso vai gerar um arquivo em `src/BaseApi.Infrastructure/Dados/Migrations/` parecido com:
`20240101000000_AdicionarTelefones.cs`

> ✅ **Não precisa executar o banco manualmente!** O `Program.cs` já está configurado para aplicar as migrations automaticamente quando a API iniciar (`db.Database.MigrateAsync()`).

> ⚠️ **Se der erro de conexão** ao criar a migration, é esperado em ambiente sem Docker rodando. Isso não impede a criação do arquivo — o arquivo é gerado mesmo sem conexão.

---

## Passo 9 — Criar o Controller (API)

📁 Crie o arquivo: `src/BaseApi.API/Controllers/TelefonesController.cs`

```csharp
using BaseApi.Application.Comum.Modelos;
using BaseApi.Application.Telefones.Commands.AtualizarTelefone;
using BaseApi.Application.Telefones.Commands.CriarTelefone;
using BaseApi.Application.Telefones.Commands.ExcluirTelefone;
using BaseApi.Application.Telefones.Queries.ListarTelefones;
using BaseApi.Application.Telefones.Queries.ObterTelefonePorId;
using BaseApi.Domain.Enums;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BaseApi.API.Controllers;

/// <summary>
/// CRUD completo de Telefones.
/// Todos os endpoints exigem autenticação JWT.
/// </summary>
[ApiController]
[Route("api/[controller]")]
[Authorize]
[Produces("application/json")]
public class TelefonesController(IMediator mediator) : ControllerBase
{
    /// <summary>
    /// Lista telefones com paginação e filtro por marca/modelo.
    /// Qualquer usuário autenticado pode listar.
    /// </summary>
    [HttpGet]
    [ProducesResponseType(typeof(RespostaApi<ResultadoPaginado<TelefoneListaDto>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> Listar(
        [FromQuery] int pagina = 1,
        [FromQuery] int tamanhoPagina = 10,
        [FromQuery] string? busca = null,
        CancellationToken ct = default)
    {
        var resultado = await mediator.Send(new ListarTelefonesQuery(pagina, tamanhoPagina, busca), ct);
        return Ok(RespostaApi<ResultadoPaginado<TelefoneListaDto>>.Sucesso(resultado));
    }

    /// <summary>
    /// Busca um telefone específico pelo Id.
    /// </summary>
    [HttpGet("{id:guid}")]
    [ProducesResponseType(typeof(RespostaApi<TelefoneDetalheDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> ObterPorId(Guid id, CancellationToken ct)
    {
        var resultado = await mediator.Send(new ObterTelefonePorIdQuery(id), ct);
        return Ok(RespostaApi<TelefoneDetalheDto>.Sucesso(resultado));
    }

    /// <summary>
    /// Cadastra um novo telefone no catálogo.
    /// Apenas Admin e Gerente podem cadastrar.
    /// </summary>
    /// <remarks>
    /// Exemplo de body:
    ///
    ///     {
    ///       "marca": "Samsung",
    ///       "modelo": "Galaxy S24",
    ///       "preco": 3999.90,
    ///       "estoque": 50
    ///     }
    /// </remarks>
    [HttpPost]
    [Authorize(Roles = $"{NomePerfil.Admin},{NomePerfil.Gerente}")]
    [ProducesResponseType(typeof(RespostaApi<CriarTelefoneResposta>), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Criar([FromBody] CriarTelefoneCommand command, CancellationToken ct)
    {
        var resultado = await mediator.Send(command, ct);
        return CreatedAtAction(
            nameof(ObterPorId),
            new { id = resultado.Id },
            RespostaApi<CriarTelefoneResposta>.Sucesso(resultado, "Telefone cadastrado com sucesso!"));
    }

    /// <summary>
    /// Atualiza os dados de um telefone existente.
    /// Apenas Admin e Gerente podem atualizar.
    /// </summary>
    [HttpPut("{id:guid}")]
    [Authorize(Roles = $"{NomePerfil.Admin},{NomePerfil.Gerente}")]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Atualizar(Guid id, [FromBody] AtualizarTelefoneRequest request, CancellationToken ct)
    {
        var command = new AtualizarTelefoneCommand(
            id, request.Marca, request.Modelo, request.Preco, request.Estoque, request.Ativo);

        await mediator.Send(command, ct);
        return Ok(RespostaApi.Sucesso("Telefone atualizado com sucesso!"));
    }

    /// <summary>
    /// Remove um telefone do catálogo permanentemente.
    /// Apenas Admin pode excluir.
    /// </summary>
    [HttpDelete("{id:guid}")]
    [Authorize(Roles = NomePerfil.Admin)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(RespostaApi), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Excluir(Guid id, CancellationToken ct)
    {
        await mediator.Send(new ExcluirTelefoneCommand(id), ct);
        return Ok(RespostaApi.Sucesso("Telefone removido com sucesso!"));
    }
}

// DTO local para o body do PUT (separa o Id da URL dos dados do body)
public record AtualizarTelefoneRequest(
    string Marca,
    string Modelo,
    decimal Preco,
    int Estoque,
    bool Ativo);
```

---

## Passo 10 — Testar no Swagger

### 1. Compile o projeto

No Visual Studio: `Ctrl+Shift+B`  
No Terminal: `dotnet build`

Se aparecer **0 Erro(s)** — você está pronto!

### 2. Suba o Docker

```bash
docker-compose up --build
```

### 3. Acesse o Swagger

Abra no navegador: **http://localhost:5000/swagger**

### 4. Faça login

1. Clique em `POST /api/autenticacao/login`
2. Clique em "Try it out"
3. Use:
   ```json
   {
     "email": "admin@baseapi.com",
     "senha": "Admin@123"
   }
   ```
4. Copie o valor de `accessToken`

### 5. Autorize

1. Clique no botão **🔒 Authorize** (topo da página)
2. Cole: `Bearer SEU_TOKEN_AQUI`
3. Clique em "Authorize"

### 6. Teste o CRUD de Telefones

**Criar um telefone:**
- `POST /api/telefones`
```json
{
  "marca": "Apple",
  "modelo": "iPhone 15 Pro",
  "preco": 7999.90,
  "estoque": 30
}
```

**Listar telefones:**
- `GET /api/telefones?pagina=1&tamanhoPagina=10`

**Buscar por marca:**
- `GET /api/telefones?busca=apple`

**Atualizar:**
- `PUT /api/telefones/{id}`
```json
{
  "marca": "Apple",
  "modelo": "iPhone 15 Pro Max",
  "preco": 9499.90,
  "estoque": 20,
  "ativo": true
}
```

**Excluir:**
- `DELETE /api/telefones/{id}`

---

## Resumo Visual dos Arquivos Criados

```
src/
├── BaseApi.Domain/
│   ├── Entidades/
│   │   └── Telefone.cs                              ← PASSO 1
│   └── Interfaces/Repositorios/
│       └── ITelefoneRepositorio.cs                  ← PASSO 2
│
├── BaseApi.Infrastructure/
│   ├── Dados/
│   │   ├── AppDbContext.cs                          ← PASSO 3.1 (modificado)
│   │   ├── Migrations/
│   │   │   └── ..._AdicionarTelefones.cs            ← PASSO 8 (gerado)
│   │   └── Configuracoes/
│   │       └── TelefoneConfiguracao.cs              ← PASSO 3
│   ├── Repositorios/
│   │   └── TelefoneRepositorio.cs                   ← PASSO 4
│   └── DependencyInjection.cs                       ← PASSO 5 (modificado)
│
├── BaseApi.Application/
│   └── Telefones/
│       ├── Commands/
│       │   ├── CriarTelefone/
│       │   │   ├── CriarTelefoneCommand.cs          ← PASSO 6.1
│       │   │   ├── CriarTelefoneValidator.cs        ← PASSO 6.1
│       │   │   └── CriarTelefoneHandler.cs          ← PASSO 6.1
│       │   ├── AtualizarTelefone/
│       │   │   ├── AtualizarTelefoneCommand.cs      ← PASSO 6.2
│       │   │   ├── AtualizarTelefoneValidator.cs    ← PASSO 6.2
│       │   │   └── AtualizarTelefoneHandler.cs      ← PASSO 6.2
│       │   └── ExcluirTelefone/
│       │       ├── ExcluirTelefoneCommand.cs        ← PASSO 6.3
│       │       └── ExcluirTelefoneHandler.cs        ← PASSO 6.3
│       └── Queries/
│           ├── ObterTelefonePorId/
│           │   ├── ObterTelefonePorIdQuery.cs       ← PASSO 7.1
│           │   └── ObterTelefonePorIdHandler.cs     ← PASSO 7.1
│           └── ListarTelefones/
│               ├── ListarTelefonesQuery.cs          ← PASSO 7.2
│               └── ListarTelefonesHandler.cs        ← PASSO 7.2
│
└── BaseApi.API/
    └── Controllers/
        └── TelefonesController.cs                   ← PASSO 9
```

**Total: 17 arquivos** (2 modificados + 15 novos)

---

## Dúvidas Frequentes

**❓ Preciso criar uma pasta manualmente no Visual Studio?**  
Não. Crie os arquivos `.cs` com o caminho correto e o Visual Studio organiza automaticamente no Solution Explorer.

**❓ Por que usar `record` no Command e no DTO?**  
`record` em C# é imutável — depois de criado, não pode ser modificado. Isso é perfeito para Commands (que representam uma intenção imutável) e DTOs (que só carregam dados).

**❓ Por que `Unit` no retorno de alguns Handlers?**  
`Unit` é o "void" do MediatR. Quando o Handler não precisa retornar dados (como no `ExcluirTelefoneHandler`), usa `Unit.Value` como retorno vazio.

**❓ E se eu quiser criar um recurso com relacionamento? (ex: Pedido tem Itens)**  
Siga os mesmos passos, mas:
- Na Entidade `Pedido`, adicione `ICollection<ItemPedido> Itens`
- Na Entidade `ItemPedido`, adicione `Guid PedidoId` e `Pedido? Pedido`
- Configure o relacionamento no `PedidoConfiguracao.cs` com `.HasMany()` e `.WithOne()`

**❓ Onde coloco regras de negócio mais complexas?**  
No **Handler**. Por exemplo, verificar se tem estoque antes de criar um pedido:
```csharp
if (telefone.Estoque < quantidadePedida)
    throw new ExcecaoDominio("Estoque insuficiente.");
```

**❓ Como adicionar um campo novo em uma entidade existente?**  
1. Adicione a propriedade na Entidade
2. Ajuste o `Configuracao.cs` se necessário
3. Crie uma nova migration: `dotnet ef migrations add AdicionarCampoXxx ...`
4. Reinicie a API — o banco é atualizado automaticamente.

---

## 🎯 Desafio para praticar

Agora que você aprendeu, tente criar um CRUD de **Clientes** com os campos:
- Nome completo
- CPF (com validação de formato)
- E-mail
- Telefone (pode referenciar a entidade Telefone!)
- Data de nascimento

Siga os 10 passos e use este guia como referência. Boa sorte! 🚀
