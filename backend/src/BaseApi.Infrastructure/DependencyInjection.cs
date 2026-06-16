using BaseApi.Domain.Interfaces.Repositorios;
using BaseApi.Domain.Interfaces.Servicos;
using BaseApi.Infrastructure.Dados;
using BaseApi.Infrastructure.Repositorios;
using BaseApi.Infrastructure.Servicos;
using Microsoft.EntityFrameworkCore;
using Pomelo.EntityFrameworkCore.MySql.Infrastructure;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace BaseApi.Infrastructure;

/// <summary>
/// Registra todos os serviços da camada Infrastructure no container de DI.
/// Chamado em Program.cs via: builder.Services.AdicionarInfrastructure(config);
/// </summary>
public static class DependencyInjection
{
    public static IServiceCollection AdicionarInfrastructure(
        this IServiceCollection services,
        IConfiguration config)
    {
        // Configura o EF Core com MySQL (Pomelo)
        var connectionString = config.GetConnectionString("MySQL");
        // MySQL 8.0 — versão fixada para evitar conexão em design-time
        var serverVersion = new MySqlServerVersion(new Version(8, 0, 0));
        services.AddDbContext<AppDbContext>(opt =>
            opt.UseMySql(connectionString, serverVersion));

        // Repositórios
        services.AddScoped<IUsuarioRepositorio, UsuarioRepositorio>();
        services.AddScoped<IPerfilRepositorio, PerfilRepositorio>();

        // Serviços de infraestrutura
        services.AddScoped<ITokenServico, TokenServico>();
        services.AddScoped<IEmailServico, EmailServico>();
        services.AddScoped<ISenhaServico, SenhaServico>();

        return services;
    }
}
