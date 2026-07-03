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
    public async Task<Notificacao?> ObterPorIdAsync(Guid id, CancellationToken ct = default)
        => await contexto.Notificacoes
            .FirstOrDefaultAsync(t => t.Id != null && Guid.Parse(t.Id.ToString()) == id, ct);

    public Task<(IEnumerable<Notificacao> Itens, int Total)> ListarAsync(
        int pagina, int tamanhoPagina, string? busca, CancellationToken ct = default)
    {
        var query = contexto.Notificacoes
            .AsNoTracking(); // AsNoTracking = mais performance para leitura

        if (!string.IsNullOrWhiteSpace(busca))
        {
            query = query.Where(n => EF.Functions.Like(n.Id.ToString(), $"%{busca}%"));
        }

        var total = query.Count();
        var itens = query
            .Skip((pagina - 1) * tamanhoPagina)
            .Take(tamanhoPagina)
            .ToList()
            .AsEnumerable(); // Convert List to IEnumerable to match the return type

        return Task.FromResult((itens, total));
    }

    public async Task AdicionarAsync(Notificacao Notificacao, CancellationToken ct = default)
        => await contexto.Notificacoes.AddAsync(Notificacao, ct);

    public void Atualizar(Notificacao Notificacao)
        => contexto.Notificacoes.Update(Notificacao);

    public void Remover(Notificacao Notificacao)
        => contexto.Notificacoes.Remove(Notificacao);

    public async Task SalvarAsync(CancellationToken ct = default)
        => await contexto.SaveChangesAsync(ct);

    public Task<IEnumerable<object>> ObterTodosAsync()
    {
        throw new NotImplementedException();
    }
}