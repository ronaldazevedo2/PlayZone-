using BaseApi.Domain.Entidades;

namespace BaseApi.Domain.Interfaces.Repositorios;

public interface IDataHorarioReservaRepositorio
{
    Task<DataHorarioReserva> AdicionarAsync(DataHorarioReserva entidade);

    Task<List<DataHorarioReserva>> ObterPorQuadraAsync(Guid quadraId);

    Task<List<DataHorarioReserva>> ObterPorDataAsync(Guid quadraId, DateTime data);

    Task<DataHorarioReserva?> ObterPorIdAsync(Guid id);

    Task AtualizarAsync(DataHorarioReserva entidade);

    Task RemoverAsync(Guid id);
    Task<(IEnumerable<DataHorarioReserva> itens, int total)> ListarAsync(int pagina,int tamanhoPagina,CancellationToken ct);
}