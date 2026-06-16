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
    }

    private static void SeedPerfis(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Perfil>().HasData(
            new Perfil { Id = 1, Nome = "Admin",    Descricao = "Acesso total ao sistema" },
            new Perfil { Id = 2, Nome = "Gerente",  Descricao = "Acesso intermediário ao sistema" },
            new Perfil { Id = 3, Nome = "Usuário",  Descricao = "Acesso básico ao sistema" }
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
}
