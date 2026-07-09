using BaseApi.Domain.Entidades;
using BaseApi.Domain.Interfaces.Repositorios;
using BaseApi.Infrastructure.Dados;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace BaseApi.Infrastructure.Repositorios
{
    public class QuadraRepositorio(AppDbContext contexto) : IQuadraRepositorio
    {
        public async Task AdicionarAsync(Quadra quadra, CancellationToken ct = default)
        {
            await contexto.Quadra.AddAsync(quadra, ct);
        }

        public void Atualizar(Quadra quadra)
        {
            contexto.Quadra.Update(quadra);
        }

        public void Remover(Quadra quadra)
        {
            contexto.Quadra.Remove(quadra);
        }

        public async Task SalvarAsync(CancellationToken ct = default)
        {
            await contexto.SaveChangesAsync(ct);
        }

        public async Task<Quadra?> ObterPorIdAsync(Guid id, CancellationToken ct = default)
        {
            return await contexto.Quadra
                .FirstOrDefaultAsync(x => x.Id == id, ct);
        }

        public async Task<Quadra?> ObterPorNomeAsync(string nome, CancellationToken ct = default)
        {
            return await contexto.Quadra
                .FirstOrDefaultAsync(x => x.Nome == nome, ct);
        }

        public async Task<bool> NomeExisteAsync(string nome, Guid? ignorarId = null, CancellationToken ct = default)
        {
            return await contexto.Quadra
                .AnyAsync(x => x.Nome == nome && (ignorarId == null || x.Id != ignorarId), ct);
        }

        public async Task<IEnumerable<Quadra>> FiltrarPorLocalizacaoAsync(string localizacao, CancellationToken ct = default)
        {
            return await contexto.Quadra
                .Where(x => x.Localizacao == localizacao)
                .ToListAsync(ct);
        }

        public async Task<IEnumerable<Quadra>> FiltrarPorModalidadeAsync(string modalidade, CancellationToken ct = default)
        {
            return await contexto.Quadra
                .Where(x => x.Modalidade == modalidade)
                .ToListAsync(ct);
        }

        public async Task<(IEnumerable<Quadra> Itens, int Total)> ListarAsync(
            int pagina,
            int tamanhoPagina,
            string? busca,
            CancellationToken ct = default)
        {
            var query = contexto.Quadra.AsQueryable();

            if (!string.IsNullOrWhiteSpace(busca))
            {
                query = query.Where(x =>
                    x.Nome.Contains(busca) ||
                    x.Localizacao.Contains(busca) ||
                    x.Modalidade.Contains(busca));
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
}