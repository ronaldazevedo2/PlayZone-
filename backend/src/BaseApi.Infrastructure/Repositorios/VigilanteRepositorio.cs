using BaseApi.Domain.Entidades;
using BaseApi.Domain.Interfaces.Repositorios;
using BaseApi.Infrastructure.Dados;
using Microsoft.EntityFrameworkCore;

namespace BaseApi.Infrastructure.Repositorios;

public class VigilanteRepositorio(AppDbContext contexto) : IVigilanteRepositorio
{
    public async Task<Vigilantes?> ObterPorIdAsync(Guid id, CancellationToken ct = default)
        => await contexto.Vigilantes
            .FirstOrDefaultAsync(v => v.Id == id, ct);

    public async Task<(IEnumerable<Vigilantes> Itens, int Total)> ListarAsync(
        int pagina,
        int tamanhoPagina,
        string? busca,
        CancellationToken ct = default)
    { 
        var query = contexto.Vigilantes
            .AsNoTracking();

        // Filtro de busca por nome, CPF ou e-mail
        if (!string.IsNullOrWhiteSpace(busca))
        {
            busca = busca.ToLower();

            query = query.Where(v =>
                v.NomeCompleto.ToLower().Contains(busca) ||
                v.Cpf.ToLower().Contains(busca) ||
                v.Email.ToLower().Contains(busca));
        }

        var total = await query.CountAsync(ct);

        var itens = await query
            .OrderBy(v => v.NomeCompleto)
            .Skip((pagina - 1) * tamanhoPagina)
            .Take(tamanhoPagina)
            .ToListAsync(ct);

        return (itens, total);
    }

    public async Task AdicionarAsync(Vigilantes vigilante, CancellationToken ct = default)
        => await contexto.Vigilantes.AddAsync(vigilante, ct);

    public void Atualizar(Vigilantes vigilante)
        => contexto.Vigilantes.Update(vigilante);

    public void Remover(Vigilantes vigilante)
        => contexto.Vigilantes.Remove(vigilante);

    public async Task SalvarAsync(CancellationToken ct = default)
        => await contexto.SaveChangesAsync(ct);

    public Task<bool> CpfExisteAsync(string cpf, CancellationToken ct = default)
    {
        throw new NotImplementedException();
    }

    public Task<bool> EmailExisteAsync(string email, CancellationToken ct = default)
    {
        throw new NotImplementedException();
    }
}