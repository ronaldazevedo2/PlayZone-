using BaseApi.Domain.Entidades;
using BaseApi.Domain.Interfaces.Repositorios;
using BaseApi.Infrastructure.Dados;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BaseApi.Infrastructure.Repositorios;

public class VigilanteRepositorio(AppDbContext contexto) : IVigilanteRepositorio
{
    public async Task<Vigilante?> ObterPorIdAsync(int id, CancellationToken ct = default)
        => await contexto.Vigilantes
            .FirstOrDefaultAsync(v => v.Id == id, ct);

    public async Task<(IEnumerable<Vigilante> Itens, int Total)> ListarAsync(
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

    public async Task AdicionarAsync(Vigilante vigilante, CancellationToken ct = default)
        => await contexto.Vigilantes.AddAsync(vigilante, ct);

    public async Task<bool> CpfExisteAsync(string cpf, CancellationToken ct = default)
        => await contexto.Vigilantes.AnyAsync(v => v.Cpf == cpf, ct);

    public async Task<bool> EmailExisteAsync(string email, CancellationToken ct = default)
        => await contexto.Vigilantes.AnyAsync(v => v.Email.ToLower() == email.ToLower(), ct);

    public void Atualizar(Vigilante vigilante)
        => contexto.Vigilantes.Update(vigilante);

    public void Remover(Vigilante vigilante)
        => contexto.Vigilantes.Remove(vigilante);

    public async Task SalvarAsync(CancellationToken ct = default)
        => await contexto.SaveChangesAsync(ct);
}
