using BaseApi.Application.Comum.Comportamentos;
using BaseApi.Application.Comum.Mapeamentos;
using FluentValidation;
using Mapster;
using MapsterMapper;
using MediatR;
using Microsoft.Extensions.DependencyInjection;

namespace BaseApi.Application;

/// <summary>
/// Registra todos os serviços da camada Application no container de DI.
/// Chamado em Program.cs via: builder.Services.AdicionarApplication();
/// </summary>
public static class DependencyInjection
{
    public static IServiceCollection AdicionarApplication(this IServiceCollection services)
    {
        // MediatR — registra todos os Handlers, Behaviors e Notifications do assembly
        services.AddMediatR(cfg =>
        {
            cfg.RegisterServicesFromAssembly(typeof(DependencyInjection).Assembly);
            // Adiciona o pipeline de validação automática
            cfg.AddBehavior(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
        });

        // FluentValidation — registra todos os Validators do assembly
        services.AddValidatorsFromAssembly(typeof(DependencyInjection).Assembly);

        // Mapster — configura mapeamentos
        var config = TypeAdapterConfig.GlobalSettings;
        config.Scan(typeof(DependencyInjection).Assembly);
        services.AddSingleton(config);
        services.AddScoped<IMapper, ServiceMapper>();

        return services;
    }
}
