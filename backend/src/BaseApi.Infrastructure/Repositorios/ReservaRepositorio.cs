using BaseApi.Domain.Entidades;
using BaseApi.Domain.Interfaces.Repositorios;
using BaseApi.Infrastructure.Dados;

namespace BaseApi.Infrastructure.Repositorios
{
    public class ReservaRepositorio(AppDbContext contexto) : IReservaRepositorio
    {
        public Task AdicionarAsync(Reserva reserva, CancellationToken ct = default)
        {
            throw new NotImplementedException();
        }

        public void Atualizar(Reserva reserva)
        {
            throw new NotImplementedException();
        }

        public Task<bool> HorarioDisponivelAsync(Guid quadraId, DateTime dataAgendada, TimeSpan horarioAgendado, Guid? ignorarId = null, CancellationToken ct = default)
        {
            throw new NotImplementedException();
        }

        public Task<(IEnumerable<Reserva> Itens, int Total)> ListarAsync(int pagina, int tamanhoPagina, Guid? quadraId, DateTime? dataInicio, DateTime? dataFim, CancellationToken ct = default)
        {
            throw new NotImplementedException();
        }

        public Task<IEnumerable<Reserva>> ObterPorDataAsync(Guid quadraId, DateTime data, CancellationToken ct = default)
        {
            throw new NotImplementedException();
        }

        public Task<Reserva?> ObterPorIdAsync(Guid id, CancellationToken ct = default)
        {
            throw new NotImplementedException();
        }

        public Task<IEnumerable<Reserva>> ObterPorQuadraAsync(Guid quadraId, CancellationToken ct = default)
        {
            throw new NotImplementedException();
        }

        public void Remover(Reserva reserva)
        {
            throw new NotImplementedException();
        }

        public Task SalvarAsync(CancellationToken ct = default)
        {
            throw new NotImplementedException();
        }
    }
}
