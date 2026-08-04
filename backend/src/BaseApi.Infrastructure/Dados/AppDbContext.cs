using BaseApi.Domain.Entidades;
using Microsoft.EntityFrameworkCore;

namespace BaseApi.Infrastructure.Dados;

/// <summary>
/// Contexto principal do Entity Framework Core.
/// Gerencia todas as entidades e a conexão com o banco MySQL.
///
/// As migrations são criadas pelo CLI do EF e aplicadas automaticamente no startup.
/// Para criar uma nova migration após alterar entidades:
///   dotnet ef migrations add NomeDaMigration --project src/BaseApi.Infrastructure --startup-project src/BaseApi.API
/// </summary>
public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<Usuario> Usuarios => Set<Usuario>();
    public DbSet<Perfil> Perfis => Set<Perfil>();
    public DbSet<Quadra> Quadra => Set<Quadra>();
    public DbSet<Reserva> Reserva => Set<Reserva>();
    public DbSet<DadosSecretaria> DadosSecretaria => Set<DadosSecretaria>();
    public DbSet<Vigilantes> Vigilantes => Set<Vigilantes>();

    public DbSet<Notificacao> Telefones => Set<Notificacao>();

    public object Notificacoes { get; internal set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Aplica todas as configurações do assembly automaticamente (Fluent API)
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);

        // =============================================
        // SEED — dados iniciais criados automaticamente
        // =============================================
        SeedPerfis(modelBuilder);
        SeedUsuarioAdmin(modelBuilder);
        SeedUsuarios(modelBuilder);
        SeedDadosSecretaria(modelBuilder);
        SeedQuadras(modelBuilder);
        SeedReservas(modelBuilder);
        SeedVigilantes(modelBuilder);

    }
    private static void SeedPerfis(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Perfil>().HasData(
            new Perfil { Id = 1, Nome = "Admin", Descricao = "Acesso total ao sistema" },
            new Perfil { Id = 2, Nome = "Gerente", Descricao = "Acesso intermediário ao sistema" },
            new Perfil { Id = 3, Nome = "Usuário", Descricao = "Acesso básico ao sistema" }
        );
    }

    private static void SeedUsuarioAdmin(ModelBuilder modelBuilder)
    {
        // Usuário padrão: admin@baseapi.com / Admin@123
        // Hash gerado com BCrypt (work factor 12)
        modelBuilder.Entity<Usuario>().HasData(new Usuario
        {
            UsuariosId = Guid.Parse("00000000-0000-0000-0000-000000000001"),
            NomeCompleto = "Ana Carolina Ferreira Ribeiro",
            Email = "ana@gmail.com",
            SenhaHash = BCrypt.Net.BCrypt.HashPassword("Admin@123"),
            PerfilId = 1,
            Ativo = true,
            CriadoEm = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc),
            AtualizadoEm = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
        });
    }

    private static void SeedUsuarios(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Usuario>().HasData(
            new Usuario
            {
                UsuariosId = Guid.Parse("77777777-7777-7777-7777-777777777777"),
                NomeCompleto = "Ronald Azevedo",
                Email = "ronald@gmail.com",
                Cpf = "20314556729",
                Telefone = "27997904554",
                SenhaHash = BCrypt.Net.BCrypt.HashPassword("Admin@123"),
                PerfilId = 1,
                Ativo = true,
                CriadoEm = new DateTime(2026, 1, 1),
                AtualizadoEm = new DateTime(2026, 1, 1)
            },
            new Usuario
            {
                UsuariosId = Guid.Parse("88888888-8888-8888-8888-888888888888"),
                NomeCompleto = "Julia Tolentino",
                Email = "julia7@gmail.com",
                Cpf = "14578925689",
                Telefone = "27995107361",
                SenhaHash = BCrypt.Net.BCrypt.HashPassword("123456"),
                PerfilId = 2,
                Ativo = true,
                CriadoEm = new DateTime(2026, 1, 1),
                AtualizadoEm = new DateTime(2026, 1, 1)
            },
            new Usuario
            {
                UsuariosId = Guid.Parse("99999999-9999-9999-9999-999999999999"),
                NomeCompleto = "Amanda Soares",
                Email = "amanda@gmail.com",
                Cpf = "05522890789",
                Telefone = "27996108515",
                SenhaHash = BCrypt.Net.BCrypt.HashPassword("123456"),
                PerfilId = 3,
                Ativo = true,
                CriadoEm = new DateTime(2026, 1, 1),
                AtualizadoEm = new DateTime(2026, 1, 1)
            }
        );
    }

    private static void SeedDadosSecretaria(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<DadosSecretaria>().HasData(
            new DadosSecretaria
            {
                SecretariaId = Guid.Parse("11111111-1111-1111-1111-111111111111"),
                Nome = "Secretaria Municipal de Esportes e lazer",
                Email = "semel.linhares@gmail.com",
                Contato = " (27) 3372-6800",
                Cep = "29.900-192",
                Endereço = "Avenida Augusto Pestana",
                Numero = "790",
                Bairro = "Centro",
                Cidade = "Linhares"
            }
           
        );
    }

    private static void SeedQuadras(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Quadra>().HasData(

        new Quadra
        {
            Id = Guid.Parse("33333333-3333-3333-3333-333333333333"),
            Nome = "GINÁSIO POLIESPORTIVO \"EURICO GUILHERME SCHULZ\"",
            Descricao = "Ginásio Poliesportivo localizado no bairro São José.",
            Capacidade = 20,
            Localizacao = "São José",
            Modalidade = "Futebol",
            ImagemUrl = "https://www.aecweb.com.br/revista/materias/projetando-areas-esportivas-conheca-os-materiais-mais-indicados/6698"
        },

        new Quadra
        {
            Id = Guid.Parse("44444444-4444-4444-4444-444444444444"),
            Nome = "GINÁSIO POLIESPORTIVO BAIRRO AVISO",
            Descricao = "Ginásio Poliesportivo localizado no bairro Aviso.",
            Capacidade = 20,
            Localizacao = "Aviso",
            Modalidade = "Futebol",
            ImagemUrl = "https://www.aecweb.com.br/revista/materias/projetando-areas-esportivas-conheca-os-materiais-mais-indicados/6698"
        },

        new Quadra
        {
            Id = Guid.Parse("55555555-5555-5555-5555-555555555555"),
            Nome = "GINÁSIO POLIESPORTIVO \"LEANDRO SILVA DOS REIS\"",
            Descricao = "Ginásio Poliesportivo localizado no bairro Interlagos.",
            Capacidade = 20,
            Localizacao = "Interlagos",
            Modalidade = "Futebol",
            ImagemUrl = "https://www.aecweb.com.br/revista/materias/projetando-areas-esportivas-conheca-os-materiais-mais-indicados/6698"
        },

        new Quadra
        {
            Id = Guid.Parse("66666666-6666-6666-6666-666666666666"),
            Nome = "GINÁSIO POLIESPORTIVO BAIRRO ARAÇÁ",
            Descricao = "Ginásio Poliesportivo localizado no bairro Araçá.",
            Capacidade = 20,
            Localizacao = "Araçá",
            Modalidade = "Futebol",
            ImagemUrl = "https://www.aecweb.com.br/revista/materias/projetando-areas-esportivas-conheca-os-materiais-mais-indicados/6698"
        },

        new Quadra
        {
            Id = Guid.Parse("33333333-3333-3333-3333-333333333333"),
            Nome = "GINÁSIO POLIESPORTIVO \"EURICO GUILHERME SCHULZ\"",
            Descricao = "Ginásio Poliesportivo localizado no bairro São José.",
            Capacidade = 20,
            Localizacao = "São José",
            Modalidade = "Futebol",
            ImagemUrl = "https://www.aecweb.com.br/revista/materias/projetando-areas-esportivas-conheca-os-materiais-mais-indicados/6698"
        }

    );
    }

    private static void SeedReservas(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Reserva>().HasData(
            // Quadra Society
            new Reserva
            {
                ReservasId = Guid.Parse("70000000-0000-0000-0000-000000000001"),
                QuadraId = Guid.Parse("33333333-3333-3333-3333-333333333333"),
                UsuarioId = Guid.Parse("88888888-8888-8888-8888-888888888888"),
                DataAgendada = new DateTime(2026, 7, 10),
                HorarioAgendado = new TimeSpan(8, 0, 0)
            },
            new Reserva
            {
                ReservasId = Guid.Parse("70000000-0000-0000-0000-000000000002"),
                QuadraId = Guid.Parse("33333333-3333-3333-3333-333333333333"),
                UsuarioId = Guid.Parse("88888888-8888-8888-8888-888888888888"),
                DataAgendada = new DateTime(2026, 7, 10),
                HorarioAgendado = new TimeSpan(9, 0, 0)
            },

            // Quadra Futsal
            new Reserva
            {
                ReservasId = Guid.Parse("70000000-0000-0000-0000-000000000003"),
                QuadraId = Guid.Parse("44444444-4444-4444-4444-444444444444"),
                UsuarioId = Guid.Parse("88888888-8888-8888-8888-888888888888"),
                DataAgendada = new DateTime(2026, 7, 10),
                HorarioAgendado = new TimeSpan(10, 0, 0)
            },
            new Reserva
            {
                ReservasId = Guid.Parse("70000000-0000-0000-0000-000000000004"),
                QuadraId = Guid.Parse("44444444-4444-4444-4444-444444444444"),
                UsuarioId = Guid.Parse("88888888-8888-8888-8888-888888888888"),
                DataAgendada = new DateTime(2026, 7, 10),
                HorarioAgendado = new TimeSpan(11, 0, 0)
            },

            // Quadra Vôlei
            new Reserva
            {
                ReservasId = Guid.Parse("70000000-0000-0000-0000-000000000005"),
                QuadraId = Guid.Parse("55555555-5555-5555-5555-555555555555"),
                UsuarioId = Guid.Parse("88888888-8888-8888-8888-888888888888"),
                DataAgendada = new DateTime(2026, 7, 10),
                HorarioAgendado = new TimeSpan(14, 0, 0)
            },

            // Quadra Basquete
            new Reserva
            {
                ReservasId = Guid.Parse("70000000-0000-0000-0000-000000000006"),
                QuadraId = Guid.Parse("66666666-6666-6666-6666-666666666666"),
                UsuarioId = Guid.Parse("88888888-8888-8888-8888-888888888888"),
                DataAgendada = new DateTime(2026, 7, 10),
                HorarioAgendado = new TimeSpan(16, 0, 0)
            }
        );
    }

    private static void SeedVigilantes(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Vigilantes>().HasData(
            new Vigilantes
            {
                Id = Guid.Parse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"),
                NomeCompleto = "Davi Soares",
                Cpf = "13836508702",
                Email = "davisoares@gmail.com",
                Telefone = "(27) 999872638",
                DataNascimento = new DateTime(2000, 6, 12),
                FotoPerfil = "https://exemplo.com/fotos/carlos.jpg",
                Ativo = true,
                CriadoEm = new DateTime(2026, 1, 1),
                AtualizadoEm = new DateTime(2026, 1, 1),
                Matricula = "VIG001",
                Arena = "Arena Central"
            },
            new Vigilantes
            {
                Id = Guid.Parse("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"),
                NomeCompleto = "Ana Alice Ferreira",
                Cpf = "98765878456",
                Email = "anaalice@gmail.com",
                Telefone = "(27) 995162604",
                DataNascimento = new DateTime(1983, 2, 24),
                FotoPerfil = "https://exemplo.com/fotos/marcos.jpg",
                Ativo = true,
                CriadoEm = new DateTime(2026, 1, 1),
                AtualizadoEm = new DateTime(2026, 1, 1),
                Matricula = "VIG002",
                Arena = "Arena Norte"
            },
            new Vigilantes
            {
                Id = Guid.Parse("cccccccc-cccc-cccc-cccc-cccccccccccc"),
                NomeCompleto = "Jailson Conceição",
                Cpf = "90778965823",
                Email = "jailsonconceicao@gmail.com",
                Telefone = "(11) 99999-3333",
                DataNascimento = new DateTime(1995, 2, 10),
                FotoPerfil = "https://exemplo.com/fotos/fernanda.jpg",
                Ativo = true,
                CriadoEm = new DateTime(2026, 1, 1),
                AtualizadoEm = new DateTime(2026, 1, 1),
                Matricula = "VIG003",
                Arena = "Arena Sul"
            }
        );
    }
}
