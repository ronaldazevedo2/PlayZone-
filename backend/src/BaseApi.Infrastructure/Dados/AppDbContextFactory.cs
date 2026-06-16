using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace BaseApi.Infrastructure.Dados;

/// <summary>
/// Factory usada APENAS pelo CLI do EF Core para criar migrations sem precisar do banco ativo.
/// Não é usada em runtime — apenas durante: dotnet ef migrations add / dotnet ef database update
/// </summary>
public class AppDbContextFactory : IDesignTimeDbContextFactory<AppDbContext>
{
    public AppDbContext CreateDbContext(string[] args)
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseMySql(
                "Server=localhost;Port=5306;Database=baseapi_db;User=root;Password=BaseApi@2024;",
                ServerVersion.Create(8, 0, 0, Pomelo.EntityFrameworkCore.MySql.Infrastructure.ServerType.MySql))
            .Options;

        return new AppDbContext(options);
    }
}
