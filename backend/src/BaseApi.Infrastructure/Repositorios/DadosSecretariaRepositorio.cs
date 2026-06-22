using BaseApi.Domain.Entidades;
using BaseApi.Infrastructure.Dados;
using Microsoft.EntityFrameworkCore;

public class DadosSecretariaRepositorio(AppDbContext contexto) : IDadosSecretariaRepositorio
{
    public async Task<DadosSecretaria?> ObterAsync(CancellationToken ct = default)
    {
        return await contexto.DadosSecretaria.FirstOrDefaultAsync(ct);
    }

    public async Task<DadosSecretaria?> ObterPorIdAsync(Guid secretariaId,CancellationToken ct = default)
    {
        return await contexto.DadosSecretaria.FirstOrDefaultAsync(x => x.SecretariaId == secretariaId,ct);
    }

    public async Task<bool> EmailExisteAsync(string email,Guid? ignorarId = null,CancellationToken ct = default)
    {
        return await contexto.DadosSecretaria.AnyAsync(x => x.Email == email &&(ignorarId == null ||x.SecretariaId != ignorarId),ct);
    }

    public async Task AdicionarAsync(DadosSecretaria dadosSecretaria,CancellationToken ct = default)
    {
        await contexto.DadosSecretaria.AddAsync(dadosSecretaria, ct);
    }

    public void Atualizar( DadosSecretaria dadosSecretaria)
    {
        contexto.DadosSecretaria.Update(dadosSecretaria);
    }

    public void Remover(DadosSecretaria secretaria)
    {
        contexto.DadosSecretaria.Remove(secretaria);
    }

    public async Task SalvarAsync(CancellationToken ct = default)
    {
        await contexto.SaveChangesAsync(ct);
    }

    public async Task<(object itens, int total)> ListarAsync(int pagina,int tamanhoPagina,string? busca,CancellationToken ct)
    {
        var query = contexto.DadosSecretaria.AsQueryable();

        if (!string.IsNullOrWhiteSpace(busca))
        {
            query = query.Where(x =>
                x.Nome.Contains(busca) ||
                x.Email.Contains(busca) ||
                x.Cidade.Contains(busca));
        }

        var total = await query.CountAsync(ct);

        var itens = await query
            .OrderBy(x => x.Nome)
            .Skip((pagina - 1) * tamanhoPagina)
            .Take(tamanhoPagina)
            .ToListAsync(ct);

        return (itens, total);
    }
}