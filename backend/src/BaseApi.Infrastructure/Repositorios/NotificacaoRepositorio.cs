using BaseApi.Domain.Entidades;
using BaseApi.Domain.Interfaces.Repositorios;
using BaseApi.Infrastructure.Dados;
using Microsoft.EntityFrameworkCore;

namespace BaseApi.Infrastructure.Repositorios;

/// <summary>
/// Implementação do repositório de Notificacoes usando Entity Framework Core.
/// Esta classe implementa o contrato INotificacaoRepositorio definido no Domain.
/// </summary>
public class NotificacaoRepositorio(AppDbContext contexto) : INotificacaoRepositorio
{
    public Task AdicionarAsync(Notificacao notificacao, CancellationToken ct = default)
    {
        throw new NotImplementedException();
    }

    public void Atualizar(Notificacao notificacao)
    {
        throw new NotImplementedException();
    }

    public Task<(IEnumerable<Notificacao> Itens, int Total)> ListarAsync(int pagina, int tamanhoPagina, string? busca, CancellationToken ct = default)
    {
        throw new NotImplementedException();
    }

    public Task<Notificacao?> ObterPorIdAsync(Guid id, CancellationToken ct = default)
    {
        throw new NotImplementedException();
    }

    public void Remover(Notificacao notificacao)
    {
        throw new NotImplementedException();
    }

    public Task SalvarAsync(CancellationToken ct = default)
    {
        throw new NotImplementedException();
    }
}