using BaseApi.Domain.Entidades;
using BaseApi.Domain.Interfaces.Repositorios;
using BaseApi.Infrastructure.Dados;
using Microsoft.EntityFrameworkCore;

namespace BaseApi.Infrastructure.Repositorios
{
    public class ReservaRepositorio(AppDbContext contexto) : IReservaRepositorio
    {
        public async Task AdicionarAsync(Reserva reserva, CancellationToken ct = default)
        {
            await contexto.Reserva.AddAsync(reserva, ct);
        }

        public void Atualizar(Reserva reserva)
        {
            contexto.Reserva.Update(reserva);
        }

        public void Remover(Reserva reserva)
        {
            contexto.Reserva.Remove(reserva);
        }

        public async Task SalvarAsync(CancellationToken ct = default)
        {
            await contexto.SaveChangesAsync(ct);
        }

        public async Task<Reserva?> ObterPorIdAsync(Guid id, CancellationToken ct = default)
        {
            return await contexto.Reserva
                .FirstOrDefaultAsync(x => x.Id == id, ct);
        }
            
        

        public async Task<IEnumerable<Reserva>> ObterPorQuadraAsync(Guid quadraId, CancellationToken ct = default)
        {
            return await contexto.Reserva
                .Where(x => x.QuadraId == quadraId)
                .ToListAsync(ct);
        }

        public async Task<IEnumerable<Reserva>> ObterPorDataAsync(Guid quadraId, DateTime data, CancellationToken ct = default)
        {
            return await contexto.Reserva
                .Where(x => x.QuadraId == quadraId &&
                            x.DataAgendada.Date == data.Date)
                .ToListAsync(ct);
        }

        public async Task<bool> HorarioDisponivelAsync(
            Guid quadraId,
            DateTime dataAgendada,
            TimeSpan horarioAgendado,
            Guid? ignorarId = null,
            CancellationToken ct = default)
        {
            return !await contexto.Reserva.AnyAsync(x =>
                x.QuadraId == quadraId &&
                x.DataAgendada.Date == dataAgendada.Date &&
                x.HorarioAgendado == horarioAgendado &&
                (!ignorarId.HasValue || x.Id != ignorarId.Value),
                ct);
        }

        public async Task<(IEnumerable<Reserva> Itens, int Total)> ListarAsync(
            int pagina,
            int tamanhoPagina,
            Guid? quadraId,
            DateTime? dataInicio,
            DateTime? dataFim,
            CancellationToken ct = default)
        {
            var query = contexto.Reserva.AsQueryable();

            if (quadraId.HasValue)
                query = query.Where(x => x.QuadraId == quadraId.Value);

            if (dataInicio.HasValue)
                query = query.Where(x => x.DataAgendada >= dataInicio.Value);

            if (dataFim.HasValue)
                query = query.Where(x => x.DataAgendada <= dataFim.Value);

            var total = await query.CountAsync(ct);

            var itens = await query
                .OrderBy(x => x.DataAgendada)
                .Skip((pagina - 1) * tamanhoPagina)
                .Take(tamanhoPagina)
                .ToListAsync(ct);

            return (itens, total);
        }
    }
}