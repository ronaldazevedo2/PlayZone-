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
            .FirstOrDefaultAsync(t => t.Id == id, ct);

    public async Task<(IEnumerable<Notificacao> Itens, int Total)> ListarAsync(
        int pagina, int tamanhoPagina, string? busca, CancellationToken ct = default)
    {
        var query = contexto.Notificacoes
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

    public async Task AdicionarAsync(Notificacao notificacao, CancellationToken ct = default)
        => await contexto.Notificacoes.AddAsync(notificacao, ct);

    public void Atualizar(Notificacao notificacao)
        => contexto.Notificacoes.Update(notificacao);

    public void Remover(Notificacao notificacao)
        => contexto.Notificacoes.Remove(notificacao);

    public async Task SalvarAsync(CancellationToken ct = default)
        => await contexto.SaveChangesAsync(ct);
}