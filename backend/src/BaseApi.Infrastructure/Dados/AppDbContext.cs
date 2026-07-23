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
            Id = Guid.Parse("00000000-0000-0000-0000-000000000001"),
            NomeCompleto = "Administrador do Sistema",
            Email = "admin@baseapi.com",
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
                Id = Guid.Parse("77777777-7777-7777-7777-777777777777"),
                NomeCompleto = "Administrador",
                Email = "admin@playzone.com",
                SenhaHash = BCrypt.Net.BCrypt.HashPassword("Admin@123"),
                PerfilId = 1,
                Ativo = true,
                CriadoEm = new DateTime(2026, 1, 1),
                AtualizadoEm = new DateTime(2026, 1, 1)
            },
            new Usuario
            {
                Id = Guid.Parse("88888888-8888-8888-8888-888888888888"),
                NomeCompleto = "João Silva",
                Email = "joao@playzone.com",
                SenhaHash = BCrypt.Net.BCrypt.HashPassword("123456"),
                PerfilId = 2,
                Ativo = true,
                CriadoEm = new DateTime(2026, 1, 1),
                AtualizadoEm = new DateTime(2026, 1, 1)
            },
            new Usuario
            {
                Id = Guid.Parse("99999999-9999-9999-9999-999999999999"),
                NomeCompleto = "Maria Souza",
                Email = "maria@playzone.com",
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
                Nome = "Secretaria Municipal de Esportes",
                Email = "esportes@prefeitura.com",
                Contato = "(11) 99999-9999",
                Cep = "01001000",
                Endereço = "Rua das Flores",
                Numero = "100",
                Bairro = "Centro",
                Cidade = "São Paulo"
            },
            new DadosSecretaria
            {
                SecretariaId = Guid.Parse("22222222-2222-2222-2222-222222222222"),
                Nome = "Secretaria Municipal de Educação",
                Email = "educacao@prefeitura.com",
                Contato = "(11) 98888-8888",
                Cep = "02002000",
                Endereço = "Av. Brasil",
                Numero = "250",
                Bairro = "Jardim América",
                Cidade = "São Paulo"
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
            ImagemUrl = "https://www.newquadras.com.br/images/Projetos/Fotos/ESCOLA%20IPSG%20(2).jpg"
        },

        new Quadra
        {
            Id = Guid.Parse("55555555-5555-5555-5555-555555555555"),
            Nome = "GINÁSIO POLIESPORTIVO \"LEANDRO SILVA DOS REIS\"",
            Descricao = "Ginásio Poliesportivo localizado no bairro Interlagos.",
            Capacidade = 20,
            Localizacao = "Interlagos",
            Modalidade = "Futebol",
            ImagemUrl = "https://exemplo.com/imagens/interlagos.jpg"
        },

        new Quadra
        {
            Id = Guid.Parse("66666666-6666-6666-6666-666666666666"),
            Nome = "GINÁSIO POLIESPORTIVO BAIRRO ARAÇÁ",
            Descricao = "Ginásio Poliesportivo localizado no bairro Araçá.",
            Capacidade = 20,
            Localizacao = "Araçá",
            Modalidade = "Futebol",
            ImagemUrl = "https://exemplo.com/imagens/araca.jpg"
        }

    );
    }

    private static void SeedReservas(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Reserva>().HasData(
            // Quadra Society
            new Reserva
            {
                Id = Guid.Parse("70000000-0000-0000-0000-000000000001"),
                QuadraId = Guid.Parse("33333333-3333-3333-3333-333333333333"),
                DataAgendada = new DateTime(2026, 7, 10),
                HorarioAgendado = new TimeSpan(8, 0, 0)
            },
            new Reserva
            {
                Id = Guid.Parse("70000000-0000-0000-0000-000000000002"),
                QuadraId = Guid.Parse("33333333-3333-3333-3333-333333333333"),
                DataAgendada = new DateTime(2026, 7, 10),
                HorarioAgendado = new TimeSpan(9, 0, 0)
            },

            // Quadra Futsal
            new Reserva
            {
                Id = Guid.Parse("70000000-0000-0000-0000-000000000003"),
                QuadraId = Guid.Parse("44444444-4444-4444-4444-444444444444"),
                DataAgendada = new DateTime(2026, 7, 10),
                HorarioAgendado = new TimeSpan(10, 0, 0)
            },
            new Reserva
            {
                Id = Guid.Parse("70000000-0000-0000-0000-000000000004"),
                QuadraId = Guid.Parse("44444444-4444-4444-4444-444444444444"),
                DataAgendada = new DateTime(2026, 7, 10),
                HorarioAgendado = new TimeSpan(11, 0, 0)
            },

            // Quadra Vôlei
            new Reserva
            {
                Id = Guid.Parse("70000000-0000-0000-0000-000000000005"),
                QuadraId = Guid.Parse("55555555-5555-5555-5555-555555555555"),
                DataAgendada = new DateTime(2026, 7, 10),
                HorarioAgendado = new TimeSpan(14, 0, 0)
            },

            // Quadra Basquete
            new Reserva
            {
                Id = Guid.Parse("70000000-0000-0000-0000-000000000006"),
                QuadraId = Guid.Parse("66666666-6666-6666-6666-666666666666"),
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
                NomeCompleto = "Carlos Eduardo Silva",
                Cpf = "12345678901",
                Email = "carlos.silva@playzone.com",
                Telefone = "(11) 99999-1111",
                DataNascimento = new DateTime(1988, 5, 15),
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
                NomeCompleto = "Marcos Antônio Souza",
                Cpf = "98765432100",
                Email = "marcos.souza@playzone.com",
                Telefone = "(11) 99999-2222",
                DataNascimento = new DateTime(1992, 8, 20),
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
                NomeCompleto = "Fernanda Oliveira",
                Cpf = "45678912345",
                Email = "fernanda.oliveira@playzone.com",
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
