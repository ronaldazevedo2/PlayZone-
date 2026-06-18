using BaseApi.Domain.Entidades;
using BaseApi.Infrastructure.Dados;
using Microsoft.EntityFrameworkCore;

namespace BaseApi.Infrastructure.Repositorios;

public class DadosSecretariaRepositorio(AppDbContext contexto) : IDadosSecretariaRepositorio
{
    public async Task<DadosSecretaria?> ObterAsync( CancellationToken ct = default)
    {
        return await contexto.DadosSecretaria.FirstOrDefaultAsync(ct);
    }

    public async Task<DadosSecretaria?> ObterPorIdAsync( Guid id, CancellationToken ct = default)
    {
        return await contexto.DadosSecretaria.FirstOrDefaultAsync(x => x.Id == id, ct);
    }

    public async Task<bool> EmailExisteAsync( string email, Guid? ignorarId = null, CancellationToken ct = default)
    {
        return await contexto.DadosSecretaria.AnyAsync(x => x.Email == email && (ignorarId == null || x.Id != ignorarId), ct);
    }

    public async Task AdicionarAsync( DadosSecretaria dadosSecretaria, CancellationToken ct = default)
    {
        await contexto.DadosSecretaria.AddAsync(dadosSecretaria, ct);
    }

    public void Atualizar( DadosSecretaria dadosSecretaria)
    {
        contexto.DadosSecretaria.Update(dadosSecretaria);
    }

    public async Task SalvarAsync( CancellationToken ct = default)
    {
        await contexto.SaveChangesAsync(ct);
    }
}