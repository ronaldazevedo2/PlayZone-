using BaseApi.Domain.Entidades;

namespace BaseApi.Domain.Interfaces.Repositorios;

/// <summary>
/// Contrato do repositório de reservas.
/// Define as operações de persistência sem acoplar ao banco de dados.
/// A implementação fica na camada Infrastructure.
/// </summary>
public interface IReservaRepositorio
{
    Task<Reserva?> ObterPorIdAsync(Guid id, CancellationToken ct = default);

    Task<IEnumerable<Reserva>> ObterPorQuadraAsync(Guid quadraId, CancellationToken ct = default);

    Task<IEnumerable<Reserva>> ObterPorDataAsync(Guid quadraId, DateTime data, CancellationToken ct = default);

    Task<bool> HorarioDisponivelAsync(Guid quadraId, DateTime dataAgendada, TimeSpan horarioAgendado, Guid? ignorarId = null, CancellationToken ct = default);

    Task<(IEnumerable<Reserva> Itens, int Total)> ListarAsync(int pagina, int tamanhoPagina, Guid? quadraId, DateTime? dataInicio, DateTime? dataFim, CancellationToken ct = default);

    Task AdicionarAsync(Reserva reserva, CancellationToken ct = default);

    void Atualizar(Reserva reserva);

    void Remover(Reserva reserva);

    Task SalvarAsync(CancellationToken ct = default);
}