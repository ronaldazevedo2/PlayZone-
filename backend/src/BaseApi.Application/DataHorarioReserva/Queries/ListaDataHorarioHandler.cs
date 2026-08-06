using BaseApi.Application.Comum.Modelos;
using BaseApi.Domain.Interfaces.Repositorios;
using Mapster;
using MediatR;

namespace BaseApi.Application.DataHorarioReserva.Queries.ListarDataHorarioReserva;

public class ListarDataHorarioReservaHandler(IDataHorarioReservaRepositorio repositorio)
    : IRequestHandler<ListarDataHorarioReservaQuery, ResultadoPaginado<DataHorarioReservaListaDto>>
{
    public async Task<ResultadoPaginado<DataHorarioReservaListaDto>> Handle(
        ListarDataHorarioReservaQuery query,
        CancellationToken ct)
    {
        var (itens, total) = await repositorio.ListarAsync(
            query.Pagina,
            query.TamanhoPagina,
            ct
        );

        return new ResultadoPaginado<DataHorarioReservaListaDto>
        {
            Itens = itens.Adapt<IEnumerable<DataHorarioReservaListaDto>>(),
            Total = total,
            Pagina = query.Pagina,
            TamanhoPagina = query.TamanhoPagina
        };
    }
}