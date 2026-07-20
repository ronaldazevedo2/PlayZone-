using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace BaseApi.Infrastructure.Dados;

public class AppDbContextFactory : IDesignTimeDbContextFactory<AppDbContext>
{
    public AppDbContext CreateDbContext(string[] args)
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseMySql(
                "Server=127.0.0.1;Port=5306;Database=baseapi_db;User=root;Password=BaseApi@2024;",
                ServerVersion.Create(
                    8,
                    0,
                    0,
                    Pomelo.EntityFrameworkCore.MySql.Infrastructure.ServerType.MySql))
            .Options;

        return new AppDbContext(options);
    }
}