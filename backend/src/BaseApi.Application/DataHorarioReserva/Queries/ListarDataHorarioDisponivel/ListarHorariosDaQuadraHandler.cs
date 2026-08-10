using BaseApi.Application.DataHorarioReserva.Queries.ListarDataHorarioReserva;
using BaseApi.Domain.Interfaces.Repositorios;
using Mapster;
using MediatR;

namespace BaseApi.Application.DataHorarioReserva.Queries.ListarHorariosDisponiveis;

public class ListarHorariosDaQuadraHandler(IDataHorarioReservaRepositorio repositorio)
    : IRequestHandler<ListarHorariosDaQuadraQuery, IEnumerable<DataHorarioReservaListaDto>>
{
    public async Task<IEnumerable<DataHorarioReservaListaDto>> Handle(
        ListarHorariosDaQuadraQuery query,
        CancellationToken ct)
    {
        var itens = await repositorio.ObterPorQuadraAsync(query.QuadraId);
        return itens.Adapt<IEnumerable<DataHorarioReservaListaDto>>();
    }
}
