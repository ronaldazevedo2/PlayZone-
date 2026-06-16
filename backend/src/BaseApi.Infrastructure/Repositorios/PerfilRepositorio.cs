using BaseApi.Domain.Entidades;
using BaseApi.Domain.Interfaces.Repositorios;
using BaseApi.Infrastructure.Dados;
using Microsoft.EntityFrameworkCore;

namespace BaseApi.Infrastructure.Repositorios;

public class PerfilRepositorio(AppDbContext contexto) : IPerfilRepositorio
{
    public async Task<Perfil?> ObterPorIdAsync(int id, CancellationToken ct = default)
        => await contexto.Perfis.FindAsync([id], ct);

    public async Task<Perfil?> ObterPorNomeAsync(string nome, CancellationToken ct = default)
        => await contexto.Perfis.FirstOrDefaultAsync(p => p.Nome == nome, ct);

    public async Task<IEnumerable<Perfil>> ListarTodosAsync(CancellationToken ct = default)
        => await contexto.Perfis.AsNoTracking().OrderBy(p => p.Nome).ToListAsync(ct);
}
